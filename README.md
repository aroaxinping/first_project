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
git clone https://github.com/YourUsername/repository_name.git
```

2. **Install UV**

If you're a MacOS/Linux user type:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

If you're a Windows user open an Anaconda Powershell Prompt and type :

```bash
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

3. **Create an environment**

```bash
uv venv 
```

3. **Activate the environment**

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

4. **Install dependencies**:

```bash
uv pip install -r requirements.txt
```

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
...

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
