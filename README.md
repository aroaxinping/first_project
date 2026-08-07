# Project overview
...

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

# Questions 
...

# Dataset 
...

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
