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

**Team**: Aroa, Carla, Paul

# Installation

1. **Clone the repository**:

```bash
git clone https://github.com/aroaxinping/first_project.git
cd first_project
git checkout aroa
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

If you're a Windows user type:

```bash
.venv\Scripts\activate
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

# Questions

1. **Which applicant profiles concentrate the risk of default?**
   Which criteria to use when approving, rejecting, or requiring additional
   guarantees.

2. **How does prior credit history relate to default risk?**
   Whether different levels of credit history need different treatment —
   verified as a 3-tier gradient: clean history 7.62% default, no history
   10.12%, troubled history 15.78%.

3. **Is a returning client a better client than a new one?**
   Whether to invest in retention or in acquisition — verified,
   counter-intuitively, new clients default *less* (5.94%) than clients
   with previously approved loans (8.19%).

4. **Were past rejections the right call?**
   Whether current rejection criteria are well calibrated or are turning
   away profitable business.

5. **Which products and channels concentrate the risk?**
   Which products to push, which to restrict, and which sales channels
   need tighter controls.

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

The conceptual model behind that schema, in Chen notation — entities as
rectangles, attributes as ellipses, relationships as diamonds:

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
