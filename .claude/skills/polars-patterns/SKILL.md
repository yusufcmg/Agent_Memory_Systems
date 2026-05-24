---
disable-model-invocation: true
name: polars-patterns
description: Polars DataFrame idioms, lazy API, expression contexts, pandas migration anti-patterns, and performance patterns for high-throughput data processing.
origin: AMS
---

# Polars Development Patterns

High-performance DataFrame library built on Apache Arrow with a parallel-by-default execution engine.

## When to Activate

- Writing or reviewing Polars code
- Migrating pandas code to Polars
- Designing data pipelines with DataFrames
- Debugging Polars performance issues

## Core Mental Model: The Four Contexts

Expressions only execute inside a context. Choosing the wrong context is the most common Polars mistake.

| Context | Usage | Expression constraint |
|---------|-------|----------------------|
| `select(...)` | Project/compute columns | Must return equal-length or scalar Series |
| `with_columns(...)` | Add/override columns | Must return row-count-matching Series |
| `filter(...)` | Keep rows | Must return boolean Series |
| `group_by(...).agg(...)` | Aggregate per group | Returns variable-length per group |

## Eager vs Lazy API

```python
# EAGER — use for interactive/small data
df = pl.DataFrame({"a": [1, 2, 3]})
df.filter(pl.col("a") > 1)  # executes immediately

# LAZY — use for pipelines and large files
lf = pl.scan_csv("large.csv")           # no I/O yet
result = (
    lf
    .filter(pl.col("revenue") > 1000)   # predicate pushdown
    .select("customer_id", "revenue")   # projection pushdown
    .group_by("customer_id")
    .agg(pl.col("revenue").sum())
    .collect()                          # execute once, optimized
)

# 8 automatic optimizations on lazy plans:
# predicate pushdown, projection pushdown, slice pushdown,
# common subplan elimination, simplify expressions,
# join ordering, type coercion, cardinality estimation
```

## Pandas → Polars Migration Table

| Operation | Pandas | Polars |
|-----------|--------|--------|
| Select column | `df["col"]` | `df.select("col")` |
| Filter rows | `df[df["col"] > 10]` | `df.filter(pl.col("col") > 10)` |
| Add column | `df.assign(x=...)` | `df.with_columns(x=...)` |
| Multiple adds | `.assign(a=...).assign(b=...)` | `.with_columns(a=..., b=...)` (parallel) |
| Group + agg | `df.groupby("c").agg(...)` | `df.group_by("c").agg(...)` |
| Window/transform | `df.groupby("c")["x"].transform(len)` | `pl.col("x").count().over("c")` |
| Conditional | `df["a"].mask(cond, other)` | `pl.when(cond).then(other).otherwise(pl.col("a"))` |
| Lazy read | `pd.read_csv(usecols=...)` | `pl.scan_csv(...).select(...).collect()` |
| Rename | `df.rename({"old": "new"})` | `df.rename({"old": "new"})` ← same |
| Drop duplicates | `df.drop_duplicates()` | `df.unique()` |
| Melt | `df.melt(...)` | `df.unpivot(...)` |
| Pivot | `df.pivot_table(...)` | `df.pivot(...)` |

## Six Canonical Anti-Patterns

### 1. Square-bracket access (blocks optimization)
```python
# BAD
result = df["revenue"]
mask = df["revenue"] > 1000

# GOOD
result = df.select("revenue")
mask = df.filter(pl.col("revenue") > 1000)
```

### 2. Chained assigns (sequential, not parallel)
```python
# BAD — separate contexts, sequential evaluation
df = df.with_columns(a=pl.col("x") * 2)
df = df.with_columns(b=pl.col("y") + 1)

# GOOD — single context, parallel evaluation
df = df.with_columns(
    a=pl.col("x") * 2,
    b=pl.col("y") + 1,
)
```

### 3. `.pipe()` chains (creates separate contexts)
```python
# BAD
df.pipe(add_feature_a).pipe(add_feature_b)

# GOOD — compose expressions inside one with_columns
df.with_columns(feature_a_expr, feature_b_expr)
```

### 4. Eager read on large files
```python
# BAD
df = pl.read_csv("10gb.csv")
df = df.filter(pl.col("country") == "TR").select("id", "country")

# GOOD — reads only matching rows + needed columns
df = pl.scan_csv("10gb.csv").filter(pl.col("country") == "TR").select("id", "country").collect()
```

### 5. Python lambdas in hot paths
```python
# BAD — exits Rust engine, single-threaded
df.with_columns(pl.col("name").map_elements(lambda x: x.lower()))

# GOOD — stays in Rust engine, parallel
df.with_columns(pl.col("name").str.to_lowercase())
```

### 6. iterrows() / iter_rows()
```python
# BAD
for row in df.iter_rows(named=True):
    process(row["value"])

# GOOD — vectorized
df.with_columns(processed=your_expression)
# or if truly element-wise with no expression equivalent:
df.with_columns(pl.col("value").map_elements(fn, return_dtype=pl.Int64))
```

## Expression Patterns

```python
# String operations
pl.col("name").str.to_lowercase()
pl.col("email").str.contains("@gmail")
pl.col("text").str.extract(r"(\d+)", group_index=1)
pl.col("date_str").str.to_date("%Y-%m-%d")

# Numeric
pl.col("price").round(2)
pl.col("revenue").fill_null(0)
pl.col("value").clip(lower_bound=0, upper_bound=100)
pl.col("amount").log(base=10)

# Date/time
pl.col("ts").dt.year()
pl.col("ts").dt.truncate("1d")
pl.col("ts").dt.offset_by("7d")

# Expression expansion
pl.col("weight", "height").mean().name.prefix("avg_")
pl.col("^.*_amount$").sum()

# Conditional
pl.when(pl.col("score") >= 90).then(pl.lit("A"))
  .when(pl.col("score") >= 80).then(pl.lit("B"))
  .otherwise(pl.lit("C"))
  .alias("grade")
```

## Data I/O

```python
# Preferred: lazy scan + collect
pl.scan_parquet("data/*.parquet").filter(...).collect()
pl.scan_csv("data.csv", schema=MY_SCHEMA)

# Write
df.write_parquet("out.parquet", compression="zstd")
df.write_csv("out.csv")

# Partitioned write
df.write_parquet("out/", partition_by=["year", "month"])

# Streaming for data > RAM
pl.scan_parquet("huge.parquet").group_by("col").agg(...).collect(streaming=True)

# Database
pl.read_database_uri("SELECT * FROM t", "postgresql://user:pass@host/db")
```

## Type System

```python
# Prefer explicit schema on read
schema = {"id": pl.Int64, "name": pl.String, "price": pl.Float64}
df = pl.scan_csv("data.csv", schema=schema)

# Categorical for low-cardinality strings (saves memory, faster joins)
df.with_columns(pl.col("country").cast(pl.Categorical))

# Null vs NaN — they are different in Polars
df.with_columns(pl.col("val").fill_null(0))   # fill missing
df.with_columns(pl.col("val").fill_nan(0.0))  # fill NaN (float only)
df.filter(pl.col("val").is_null())            # check null
df.filter(pl.col("val").is_nan())             # check NaN (float only)
```

## Debugging & Inspection

```python
# Inspect lazy plan (pre-optimization)
lf.explain()

# Inspect optimized plan
lf.explain(optimized=True)

# Profile execution
result, duration = lf.profile()

# Quick shape check
df.shape   # (rows, cols)
df.schema  # {col: dtype, ...}
```

## Anti-Patterns Checklist

- [ ] No `df["col"]` — use `df.select("col")` or `pl.col("col")` in expressions
- [ ] No `.map_elements(lambda ...)` on large columns without profiling
- [ ] No `.iter_rows()` in hot paths
- [ ] Lazy API used for files > 10 MB
- [ ] `streaming=True` for files > available RAM
- [ ] No chained `.with_columns()` for independent expressions (merge into one)
