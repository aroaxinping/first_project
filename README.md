# Project overview

**Credit Crunchers** is a data analytics consultancy specialized in banking
and consumer credit risk. This project simulates us being brought in by a
consumer credit lender that serves clients with little or no formal banking
history. They need to better understand default risk to decide who to lend
to, on what terms, and which products to grow or restrict.

Using the [Home Credit Default Risk](https://www.kaggle.com/competitions/home-credit-default-risk)
dataset, we designed a relational database, cleaned and modeled the data,
and answered five business questions with SQL and Python to support that
decision-making.

## Team Members

- Carla — Data Analyst
- Paul — Data Analyst
- Aroa — Project Manager

# Installation

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
which creates the `home_credit` database and its three tables
(`application`, `bureau`, `previous_application`) with the columns and
foreign keys described in [Dataset](#dataset) below:

```bash
mysql -u root -p < sql_scripts/create_database.sql
```

(`-u root` matches the `database.user` in `config.yaml` — change it if your
local MySQL user is different. It'll prompt for your MySQL password.)

8. **Populate the tables**

Run these three notebooks, **in this order** — `bureau` and
`previous_application` both have a foreign key to `application.SK_ID_CURR`,
so if you run them before `application` is loaded, they'll filter out every
row and load nothing:

1. `notebooks/explore_clean_data_aroa.ipynb` (`application`)
2. `notebooks/explore_clean_data_paul.ipynb` (`bureau`)
3. `notebooks/explore_clean_data_carla.ipynb` (`previous_application`)

Each one reads its raw CSV, cleans it, and loads it into MySQL — no extra
setup needed beyond steps 1–7 above.

**Run each notebook only once.** `application` and `previous_application`
will throw a duplicate-key error on a second run; `bureau` won't error, it
will just duplicate every row. To start clean:

```bash
mysql -u root -p -e "USE home_credit; DELETE FROM bureau; DELETE FROM previous_application; DELETE FROM application;"
```

# Questions

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
   (canceled). Ruled out application count and unused offers as
   explanations for the remaining gap — with this trimmed schema (no
   amounts or dates) it's likely a selection effect rather than a specific
   red flag we can point to. ([`q3_returning_clients.sql`](sql_scripts/q3_returning_clients.sql))

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

# Dataset 

Three tables from [Home Credit Default Risk](https://www.kaggle.com/competitions/home-credit-default-risk),
trimmed to the columns the 5 questions above actually need. Schema in
[`sql_scripts/create_database.sql`](sql_scripts/create_database.sql), column
selection reasoning in
[`notebooks/column_selection_combined.ipynb`](notebooks/column_selection_combined.ipynb).

ERD, generated with MySQL Workbench's Database → Reverse Engineer directly from
the live `home_credit` database (not hand-drawn):

![ERD](figures/home_credit_erd_mysql.png)

Both are one-to-many from `application`, joined on `SK_ID_CURR`: one applicant
can have many prior credits at other institutions (`bureau`) and many prior
applications with Home Credit itself (`previous_application`). `bureau` keeps
no surrogate key of its own — it's trimmed down to just what Q2 needs.

Conceptual model (ERM, Chen notation) of the three tables we're using and how
they relate through `SK_ID_CURR`:

![ERM](figures/home_credit_erm.png)

## Main dataset issues

- ...
- ...
- ...

## Solutions for the dataset issues
...

# Conclussions
...

# Next steps
...
