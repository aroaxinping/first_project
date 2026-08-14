# Home Credit Default Risk: Applicant, Bureau History and Prior-Application Analysis

## Team Members

- Carla — Data Analyst
- Paul — Data Analyst
- Aroa — Project Manager

## Business Overview

**Credit Crunchers** is a data analytics consultancy specialized in banking
and consumer credit risk. This project simulates us being brought in by a
consumer credit lender that serves clients with little or no formal banking
history. They need to better understand default risk to decide who to lend
to, on what terms, and which products to grow or restrict.

Using the [Home Credit Default Risk](https://www.kaggle.com/competitions/home-credit-default-risk)
dataset, we designed a relational database, cleaned and modeled the data,
and answered five business questions with SQL and Python to support that
decision-making.

## Business Questions

1. Which applicant profiles concentrate the risk of default?
2. How does prior credit history relate to default risk?
3. Is a returning client a better client than a new one?
4. Were past rejections the right call?
5. Which products and channels concentrate the risk?

## Dataset

Three tables from [Home Credit Default Risk](https://www.kaggle.com/competitions/home-credit-default-risk),
trimmed to the columns the 5 questions above actually need: `application`
(one row per applicant, from `application_train.csv`), `bureau` (prior
credits at other institutions), and `previous_application` (prior
applications with Home Credit itself). Column selection reasoning is in
[`notebooks/column_selection_combined.ipynb`](notebooks/column_selection_combined.ipynb).

The raw CSVs are **not** in the repo (~740MB combined, over GitHub's 100MB
file limit) — each teammate downloads their own copy from Kaggle, see
[How to Run the Project](#how-to-run-the-project).

## Database Design

Schema in [`sql_scripts/create_database.sql`](sql_scripts/create_database.sql).
Four tables in MySQL, all one-to-many from `application`, joined on
`SK_ID_CURR`:

- `application` — root table, one row per applicant, primary key `SK_ID_CURR`.
- `bureau` — prior credits at other institutions, reported to the credit
  bureau. Trimmed down to just what Q2 needs, so it keeps no surrogate key
  from the raw data; `id` is an auto-increment PK just so the table has one.
- `previous_application` — prior applications with Home Credit itself
  (approved, refused, canceled...), primary key `SK_ID_PREV`.
- `previous_application_extended` — a separate table, not a replacement for
  `previous_application`, added for the Q3 deep-dive: same source CSV, but
  keeps the amount and date columns (`AMT_CREDIT`, `AMT_ANNUITY`,
  `DAYS_DECISION`) that were trimmed out of the main table.

ERD, generated with MySQL Workbench's Database → Reverse Engineer directly
from the live `home_credit` database (not hand-drawn):

![ERD](figures/home_credit_erd_mysql.png)

Conceptual model (ERM, Chen notation) of the tables and how they relate
through `SK_ID_CURR`:

![ERM](figures/home_credit_erm.png)

## Data Preparation

**Issues found in the raw data:**

- `application`: `CODE_GENDER` had 4 `'XNA'` rows, `OCCUPATION_TYPE` had
  96,391 nulls (31% of the table, but 100% tied to Pensioner/Unemployed
  applicants — structural, not random), and `DAYS_EMPLOYED` had a known
  placeholder bug (`365243`) for that same population.
- `bureau` and `previous_application` both include applicants outside
  `application_train.csv` (Kaggle's held-out test set) — about 251K and
  256K rows respectively reference a `SK_ID_CURR` that doesn't exist in
  `application`, which would violate the foreign key if loaded as-is.
- The team's local setups weren't uniform: some MySQL installs had a root
  password and some didn't, and `<` file redirection doesn't work the same
  way in Windows PowerShell as in bash — both broke the load step for part
  of the team before being fixed.

**How we handled them:**

- Dropped the negligible bad rows (XNA gender, a handful of nulls) and
  filled `OCCUPATION_TYPE` nulls with `"Not Employed"` instead of dropping
  31% of the table; replaced the `365243` placeholder with `NaN`.
- Filtered `bureau` and `previous_application` to only the `SK_ID_CURR`
  values already loaded in `application` before inserting, so the foreign
  key is never violated.
- Switched the MySQL connection to prompt for a password (`getpass`)
  instead of assuming it's empty, and documented the PowerShell equivalent
  for commands that use `<` redirection.

Cleaning and loading logic lives in one notebook per table:
[`explore_clean_data_aroa.ipynb`](notebooks/explore_clean_data_aroa.ipynb)
(`application`),
[`explore_clean_data_paul.ipynb`](notebooks/explore_clean_data_paul.ipynb)
(`bureau`),
[`explore_clean_data_carla.ipynb`](notebooks/explore_clean_data_carla.ipynb)
(`previous_application`), and
[`explore_clean_data_previous_extended_aroa.ipynb`](notebooks/explore_clean_data_previous_extended_aroa.ipynb)
(`previous_application_extended`).

## SQL Analysis

1. **Which applicant profiles concentrate the risk of default?**
   Risk concentrates in low-skill occupations, unstable housing, and lower
   education — all clearly above the 8.07% portfolio baseline. Top
   segments: Low-skill Laborers 17.16%, Rented apartment 12.32%, Lower
   secondary education 10.93%. Same signal from three different angles,
   likely correlated with each other — the clearest candidates for extra
   guarantees. ([`q1_default_profiles.sql`](sql_scripts/q1_default_profiles.sql))

2. **How does prior credit history relate to default risk?**
   Bureau history isn't just present-or-absent — splitting it into a
   3-tier gradient by overdue status reveals: clean history 7.62% default,
   no bureau history 10.13%, troubled history 15.79%. Having no history at
   all sits closer to "troubled" than "clean," so it's worth pricing risk
   in three tiers, not two. ([`q2_credit_history.sql`](sql_scripts/q2_credit_history.sql))

3. **Is a returning client a better client than a new one?**
   Counter-intuitively, no — returning clients default *more* (8.19%) than
   brand-new ones (5.96%). Mostly driven by refusal history: clients who
   were previously refused default at 10.32%, vs. 7.13% (clean) and 6.94%
   (canceled). Application count and unused offers were ruled out as
   explanations for the remaining gap in the trimmed schema.
   ([`q3_returning_clients.sql`](sql_scripts/q3_returning_clients.sql))

   A follow-up query went back to the raw CSV for the amount/date columns
   trimmed out of `previous_application`, to explain that remaining gap:
   a large total of previously approved credit is a *trust* signal (lowest
   quartile 9.58% default vs. highest 5.53%), while a very recent previous
   decision is a *pressure* signal (8.85% for the most recent bucket vs.
   6.29% for the oldest). ([`q3_extended_repeat_client_drivers.sql`](sql_scripts/q3_extended_repeat_client_drivers.sql))

4. **Were past rejections the right call?**
   Yes — a past refusal still predicts more risk today, even on a loan
   that did get approved (10.32% vs. 6.98% never-refused). Risk climbs
   with every extra refusal (6.98% → 8.84% → 11.61%), and the reject
   reason `SCOFR` stands out at 20.93%, more than double the baseline.
   The rejection criteria is picking up a real, persistent signal, not
   turning away good business by mistake. ([`q4_past_rejections.sql`](sql_scripts/q4_past_rejections.sql))

5. **Which products and channels concentrate the risk?**
   The `AP+ (Cash loan)` channel (11.28%) and `Cards` product (9.55%)
   carry the most risk individually; the riskiest combination is `XNA`
   product through the `AP+` channel at 14.45%. Default rate also climbs
   steadily with yield group, from 6.38% (low) to 9.01% (high) — pricing
   already tracks risk here, which is reassuring. ([`q5_products_channels.sql`](sql_scripts/q5_products_channels.sql))

## Python Analysis

Python (pandas, in Jupyter notebooks) was used for exploration and
cleaning ahead of loading into MySQL, not as a separate analysis stage —
each per-table notebook listed in [Data Preparation](#data-preparation)
does its own EDA before writing the clean CSV:

- Shape, `.info()`, and dtype checks per table.
- Null counts per column (`.isna().sum()`), including tracing
  `OCCUPATION_TYPE`'s 96,391 nulls back to the Pensioner/Unemployed
  population rather than treating them as random.
- Duplicate-row checks (`.duplicated()`).
- Category counts (`.value_counts()`) to catch placeholder/bug values like
  `CODE_GENDER = 'XNA'` and the `DAYS_EMPLOYED = 365243` sentinel.
- Cross-table `SK_ID_CURR` membership checks against `application`, to size
  the foreign-key mismatch documented in Data Preparation.

We did not produce a separate charting/visualization notebook — the only
visual outputs are the two charts built directly for the presentation
([`slides/q1_applicant_profiles_chart.png`](slides/q1_applicant_profiles_chart.png),
[`slides/q4_rejection_escalation_chart.png`](slides/q4_rejection_escalation_chart.png)).
All quantitative findings (percentages, gradients) were computed in SQL,
not pandas.

## Key Findings

Risk isn't scattered randomly across this portfolio — it concentrates
predictably. Low-skill occupations, unstable housing, and low education
all point the same direction (Q1). A troubled or absent bureau history
roughly doubles default risk compared to a clean one (Q2). Certain
channels and products — especially `AP+ (Cash loan)` and `Cards` — run
well above the portfolio average (Q5). Current rejection criteria are
working, not overcautious: past refusals, especially reason `SCOFR`, keep
predicting real risk even after approval (Q4). The one assumption this
data pushes back on is loyalty: returning clients are *not* safer than
new ones, and the reason is a blend of two opposing signals — a large
prior credit history lowers risk, a very recent prior decision raises it
(Q3).

## Business Recommendations

**Where to tighten (keep doing this, sharpen it further):**

- Screen for the overlap of low-skill occupation, unstable housing, and
  low education together, not one factor at a time — they concentrate
  risk as a combination (Q1).
- Keep the current rejection criteria as-is. Reason code `SCOFR` predicts
  real, persistent risk even after a later approval, at more than double
  the baseline (Q4).
- Move bureau history from a 2-tier to a 3-tier pricing model: clean,
  no-history, and troubled span 7.62% to 15.79% default, and no-history
  behaves like troubled, not clean (Q2).

**Where to rethink current assumptions:**

- Drop any blanket loyalty discount for returning clients — they default
  more than brand-new ones (8.19% vs. 5.96%). Score them instead on the
  size of their prior approved credit and how recently their last decision
  happened, which explain the gap in opposite directions (Q3).
- Restrict or re-price the `XNA` product sold through the `AP+ (Cash
  loan)` channel specifically — at 14.45% default it's disproportionately
  risky even though each factor looks more moderate on its own (Q5).

**Further work:**

- Combine the five findings into a single risk score instead of reading
  them independently, so an application can be scored on all signals at
  once.
- Pilot tiered pricing or guarantees on the highest-risk segments
  identified here (Q1 profiles, Q2's troubled-history tier, Q4's
  SCOFR-refused applicants) before a full rollout.

## Repository Structure

```
first_project/
├── README.md
├── config.yaml                  # DB connection + input/output CSV paths
├── pyproject.toml, uv.lock       # Python dependencies (managed with uv)
├── data/
│   ├── raw/                      # Downloaded Kaggle CSVs (gitignored)
│   └── clean/                    # Cleaned CSVs written by the notebooks
├── notebooks/
│   ├── explore_clean_data_aroa.ipynb            # application: EDA + clean + load
│   ├── explore_clean_data_paul.ipynb             # bureau: EDA + clean + load
│   ├── explore_clean_data_carla.ipynb            # previous_application: EDA + clean + load
│   ├── explore_clean_data_previous_extended_aroa.ipynb  # previous_application_extended
│   ├── column_selection_combined.ipynb           # which columns to keep, and why
│   └── column_trimming_aroa.ipynb
├── sql_scripts/
│   ├── create_database.sql       # schema: all 4 tables + foreign keys
│   ├── q1_default_profiles.sql .. q5_products_channels.sql
│   └── q3_extended_repeat_client_drivers.sql
├── figures/
│   ├── home_credit_erd_mysql.png # ERD, reverse-engineered from MySQL
│   └── home_credit_erm.png       # ERM, Chen notation
└── slides/
    ├── README.md
    ├── project_presentation.pptx # branded deck skeleton
    ├── build_deck.js             # generates the .pptx (pptxgenjs)
    └── q1_applicant_profiles_chart.png, q4_rejection_escalation_chart.png
```

## How to Run the Project

1. **Clone the repository**:

```bash
git clone https://github.com/aroaxinping/first_project.git
cd first_project
```

2. **Download the Home Credit dataset yourself** from
   [Kaggle](https://www.kaggle.com/competitions/home-credit-default-risk/data)
   (join the competition first) and place `application_train.csv`,
   `bureau.csv`, `previous_application.csv` and
   `HomeCredit_columns_description.csv` in `data/raw/`. These files are
   **not** in the repo (~740MB combined, over GitHub's 100MB file limit) —
   each teammate needs their own local copy.

3. **Install UV**

If you're a MacOS/Linux user type:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

If you're a Windows user open an Anaconda Powershell Prompt and type :

```bash
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

4. **Create an environment**

```bash
uv venv 
```

5. **Activate the environment**

If you're a MacOS/Linux user type (if you're using a bash shell):

```bash
source .venv/bin/activate
```

If you're a MacOS/Linux user type (if you're using a csh/tcsh shell):

```bash
source .venv/bin/activate.csh
```

If you're a Windows user in Command Prompt:

```bash
.venv\Scripts\activate
```

If you're a Windows user in PowerShell (e.g. Anaconda Powershell Prompt):

```powershell
.\.venv\Scripts\Activate.ps1
```

If that fails with a message about script execution being disabled, run this
once first:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

6. **Install dependencies**:

```bash
uv sync
```

7. **Create the database**

You need MySQL installed and running locally. Then run the schema script,
which creates the `home_credit` database and its tables
(`application`, `bureau`, `previous_application`,
`previous_application_extended`) with the columns and foreign keys
described in [Database Design](#database-design) above:

If you're a MacOS/Linux user:

```bash
mysql -u root -p < sql_scripts/create_database.sql
```

If you're a Windows user in PowerShell, `<` redirection isn't supported —
use this instead:

```powershell
Get-Content sql_scripts/create_database.sql | mysql -u root -p
```

(`-u root` matches the `database.user` in `config.yaml` — change it if your
local MySQL user is different. It'll prompt for your MySQL password.)

8. **Populate the tables**

Run these notebooks, **in this order** — `bureau`, `previous_application`
and `previous_application_extended` all have a foreign key to
`application.SK_ID_CURR`, so if you run them before `application` is
loaded, they'll filter out every row and load nothing:

1. `notebooks/explore_clean_data_aroa.ipynb` (`application`)
2. `notebooks/explore_clean_data_paul.ipynb` (`bureau`)
3. `notebooks/explore_clean_data_carla.ipynb` (`previous_application`)
4. `notebooks/explore_clean_data_previous_extended_aroa.ipynb` (`previous_application_extended`)

Each one reads its raw CSV, cleans it, and loads it into MySQL — no extra
setup needed beyond steps 1–7 above.

**Run each notebook only once.** `application` and `previous_application`
will throw a duplicate-key error on a second run; `bureau` won't error, it
will just duplicate every row. To start clean:

```bash
mysql -u root -p -e "USE home_credit; DELETE FROM previous_application_extended; DELETE FROM bureau; DELETE FROM previous_application; DELETE FROM application;"
```
