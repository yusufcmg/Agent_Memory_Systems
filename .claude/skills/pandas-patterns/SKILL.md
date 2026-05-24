---
disable-model-invocation: true
name: pandas-patterns
description: Pandas idioms, method chaining, .loc vs .iloc, groupby patterns, pyarrow backend, and iterrows anti-patterns for data manipulation.
origin: AMS
---

# Pandas Development Patterns

Pandas is widely used for tabular data. When performance matters, prefer Polars. When pandas is required (legacy code, sklearn integration, API compatibility), use these idioms.

## When to Activate

- Working with existing pandas codebases
- Integrating with sklearn, statsmodels, or other pandas-first libraries
- Migrating pandas code to Polars (reference for correct pandas patterns first)

## Prefer Polars

Before writing new pandas code, ask: "Can this be Polars?" Polars is 5–20× faster and uses less memory for files > 1 MB. Use pandas when:
- The downstream library requires a `pd.DataFrame` (sklearn, seaborn, statsmodels)
- You're maintaining existing code and the migration cost is not justified

## Indexing: .loc vs .iloc

```python
# .loc — label-based (column names, index labels)
df.loc[0, "name"]             # row with label 0, column "name"
df.loc[df["score"] > 90]      # boolean indexing
df.loc[:, ["a", "b"]]         # all rows, columns a and b

# .iloc — position-based (integer positions)
df.iloc[0, 2]                 # first row, third column
df.iloc[:5]                   # first 5 rows

# NEVER use df["col"] for row selection — raises KeyError or silent misuse
# NEVER use df.ix — removed in pandas 1.0
```

## Method Chaining

```python
# BAD — intermediate variables, can't parallelize, harder to read
df2 = df.dropna(subset=["revenue"])
df3 = df2.rename(columns={"rev": "revenue"})
df4 = df3.assign(margin=df3["profit"] / df3["revenue"])
df4 = df4[df4["margin"] > 0.1]

# GOOD — single chain, readable pipeline
result = (
    df
    .dropna(subset=["revenue"])
    .rename(columns={"rev": "revenue"})
    .assign(margin=lambda d: d["profit"] / d["revenue"])
    .query("margin > 0.1")
    .reset_index(drop=True)
)
```

## assign() for New Columns

```python
# Use assign() for new/derived columns in a chain
df = (
    df
    .assign(
        log_price=lambda d: np.log1p(d["price"]),
        price_bucket=lambda d: pd.cut(d["price"], bins=[0, 10, 50, 100, np.inf],
                                      labels=["cheap", "mid", "expensive", "premium"]),
        is_sale=lambda d: d["discount"] > 0,
    )
)
# assign() evaluates left-to-right — later columns can reference earlier ones
```

## groupby Patterns

```python
# agg with named columns (pandas >= 1.0)
result = (
    df
    .groupby("category", observed=True)   # observed=True for Categorical
    .agg(
        total_revenue=("revenue", "sum"),
        mean_margin=("margin", "mean"),
        n_orders=("order_id", "nunique"),
    )
    .reset_index()
)

# transform — adds aggregate back to original row count
df["category_mean"] = df.groupby("category")["revenue"].transform("mean")

# filter — keep only groups meeting a condition
df_filtered = df.groupby("category").filter(lambda g: g["revenue"].sum() > 1000)
```

## Never Use iterrows

```python
# BAD — row-by-row Python loop, extremely slow
for idx, row in df.iterrows():
    df.at[idx, "score"] = row["a"] * 2 + row["b"]

# GOOD — vectorized
df["score"] = df["a"] * 2 + df["b"]

# If you truly need element-wise logic with no vectorized equivalent:
df["result"] = df.apply(lambda row: complex_fn(row["a"], row["b"]), axis=1)
# Or use numpy.vectorize for numerical functions
```

## Categorical Dtype

```python
# For low-cardinality string columns: saves 10x+ memory, faster groupby
df["country"] = df["country"].astype("category")
df["status"] = pd.Categorical(df["status"], categories=["pending", "active", "closed"], ordered=True)

# Boolean filters on categoricals
df[df["country"] == "TR"]               # fast
df[df["status"] > "pending"]            # works with ordered=True
df.groupby("country", observed=True)    # always pass observed=True with Categorical
```

## PyArrow Backend (pandas >= 2.0)

```python
# Faster I/O, less memory, nullable types for all dtypes
import pandas as pd
pd.options.mode.dtype_backend = "pyarrow"

# Or per-DataFrame
df = pd.read_parquet("data.parquet", dtype_backend="pyarrow")
df = pd.read_csv("data.csv", dtype_backend="pyarrow")

# Explicit pyarrow dtypes
df = df.astype({"id": "int64[pyarrow]", "name": "string[pyarrow]"})
```

## I/O Best Practices

```python
# Parquet is preferred over CSV for any file > 1 MB
df = pd.read_parquet("data.parquet")
df.to_parquet("out.parquet", engine="pyarrow", compression="snappy")

# Reading large CSV — only load what you need
df = pd.read_csv(
    "large.csv",
    usecols=["id", "revenue", "date"],
    dtype={"id": "int32", "revenue": "float32"},
    parse_dates=["date"],
    chunksize=None,   # or a number to iterate in chunks
)
```

## Missing Data

```python
# Detect
df.isna().sum()
df.isna().any(axis=1)              # rows with any null

# Fill
df["val"].fillna(df["val"].median())   # impute with median
df.ffill()                             # forward fill time series

# Drop
df.dropna(subset=["required_col"])     # drop rows where col is null
df.dropna(thresh=len(df.columns) - 2) # keep rows with at most 2 nulls
```

## Anti-Patterns Checklist

- [ ] No `iterrows()` / `itertuples()` in hot paths — use vectorized operations
- [ ] No chained `[]` indexing (`df["a"]["b"]`) — use `.loc` or `.assign()`
- [ ] No `df[df["col"] > x]` on Categorical — use `.query()` or boolean mask via `.loc`
- [ ] No `inplace=True` — it doesn't save memory and returns `None`
- [ ] Use `observed=True` in `groupby` on Categorical columns
- [ ] Prefer parquet over CSV for any saved intermediate file
- [ ] Use `pd.read_csv(usecols=...)` to avoid loading unused columns
