---
disable-model-invocation: true
name: jupyter-notebook-patterns
description: Jupyter notebook best practices — modular structure, reproducibility, CI testing with nbmake, output stripping before commit, and profiling.
origin: AMS
---

# Jupyter Notebook Patterns

Jupyter notebooks are for exploration and communication — not production code. Apply these patterns to keep notebooks reproducible, reviewable, and CI-testable.

## When to Activate

- Writing or reviewing Jupyter notebooks
- Setting up notebook CI pipelines
- Debugging non-reproducible notebook runs
- Converting notebooks to production scripts

## Notebook Structure

Organize every notebook with these top-level sections:

```
# 0. Setup & Imports
# 1. Data Loading
# 2. Exploratory Data Analysis
# 3. Feature Engineering
# 4. Modeling / Analysis
# 5. Results & Conclusions
```

The notebook must run top-to-bottom without errors after `Restart & Run All`. This is the single most important rule.

## Reproducibility

```python
# Cell 0: Always seed everything before any computation
import random
import numpy as np
import torch  # if using PyTorch

SEED = 42

random.seed(SEED)
np.random.seed(SEED)
torch.manual_seed(SEED)
torch.cuda.manual_seed_all(SEED)
torch.backends.cudnn.deterministic = True
```

```python
# Pin dependency versions — paste output of `pip freeze` into requirements.txt
# At minimum, capture key library versions at the top of the notebook
import importlib.metadata
for pkg in ["polars", "pandas", "sklearn", "torch", "mlflow"]:
    try:
        print(f"{pkg}=={importlib.metadata.version(pkg)}")
    except importlib.metadata.PackageNotFoundError:
        pass
```

## Output Stripping Before Commit

Large cell outputs (plots, DataFrames, model summaries) bloat git history. Strip them before committing.

```bash
# Install nbstripout once per repo
pip install nbstripout
nbstripout --install   # adds a git filter — outputs stripped automatically on git add

# Manual strip
nbstripout notebook.ipynb

# Check if outputs are present (fails if outputs found — use in CI)
nbstripout --dry-run notebook.ipynb
```

## CI Testing with nbmake

```bash
# Run all notebooks in repo (fail on any exception)
pip install nbmake
pytest --nbmake notebooks/ -v

# Timeout per cell (prevent infinite loops from blocking CI)
pytest --nbmake notebooks/ --nbmake-timeout=120

# Ignore specific notebooks
pytest --nbmake notebooks/ --ignore=notebooks/scratch/
```

```yaml
# .github/workflows/notebooks.yml
- name: Test notebooks
  run: |
    pip install nbmake
    pytest --nbmake notebooks/ --nbmake-timeout=120 -v
```

## Keep Logic Out of Notebooks

```python
# BAD — 200-line function defined in notebook
def preprocess(df):
    ...  # 50 lines

# GOOD — import from src/
from src.preprocessing import preprocess

df_clean = preprocess(df_raw)
```

Move reusable code to `src/` Python modules. The notebook calls the module; it doesn't define the logic. This enables:
- Unit tests on the logic (not just the notebook)
- Reuse in multiple notebooks
- Easier code review

## EDA with ydata-profiling

```python
# Fast one-line EDA report
from ydata_profiling import ProfileReport

report = ProfileReport(df, title="Dataset Profile", explorative=True)
report.to_notebook_iframe()   # inline in Jupyter
# report.to_file("report.html")  # save as HTML
```

## Parameterized Notebooks with papermill

```python
# Mark the parameters cell with the tag "parameters"
# In the cell:
data_path = "data/train.parquet"   # default
model_name = "xgb-v1"
n_estimators = 500
```

```bash
# Override parameters at runtime (great for CI sweeps)
pip install papermill
papermill notebook.ipynb output.ipynb \
  -p data_path "data/test.parquet" \
  -p model_name "xgb-v2" \
  -p n_estimators 1000
```

## Memory Profiling in Notebooks

```python
# Line-level memory profiling
%load_ext memory_profiler
%memit df.groupby("category").agg({"revenue": "sum"})

# Cell-level timing
%%time
result = heavy_computation(df)

# DataFrame memory usage
df.memory_usage(deep=True).sum() / 1e6   # MB
```

## Notebook Anti-Patterns Checklist

- [ ] Notebook runs `Restart & Run All` without errors
- [ ] `SEED` set in cell 0 before any random operation
- [ ] No production logic defined in the notebook — lives in `src/`
- [ ] Outputs stripped before git commit (nbstripout installed)
- [ ] No hardcoded absolute paths (`/home/user/...`) — use relative paths or config
- [ ] No credentials or API keys in notebooks (even in stripped outputs — they stay in git history)
- [ ] `requirements.txt` or `environment.yml` pinned and updated
- [ ] CI configured to run notebooks via nbmake
