# Project overview
...

# Installation

1. **Install Git LFS** (needed before cloning — the raw Home Credit CSVs
   in `data/raw/` and `data/clean/` are tracked with Git LFS since they're
   too large for regular Git):

   - macOS: `brew install git-lfs`
   - Windows: download the installer from [git-lfs.com](https://git-lfs.com/) and run it (or `winget install GitHub.GitLFS` / `choco install git-lfs` if you use one of those)
   - Linux (Debian/Ubuntu): `sudo apt install git-lfs`

   Then, **once per machine** (not once per repo):

   ```bash
   git lfs install
   ```

2. **Clone the repository**:

```bash
git clone https://github.com/aroaxinping/first_project.git
cd first_project
git checkout aroa
```

   If you already cloned the repo *before* installing Git LFS, the CSVs
   in `data/raw/`/`data/clean/` will show up as tiny placeholder files
   instead of the real data. Fix it by running this after installing
   Git LFS (step 1):

   ```bash
   git lfs pull
   ```

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
