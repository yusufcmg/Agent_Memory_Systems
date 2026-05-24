---
disable-model-invocation: true
name: sklearn-patterns
description: Scikit-learn pipelines, transformers, model selection, cross-validation, and leakage prevention patterns for production ML.
origin: AMS
---

# Scikit-learn Patterns

Scikit-learn is the standard library for classical ML. Every production workflow uses Pipeline to prevent leakage and ensure reproducibility.

## When to Activate

- Building classification, regression, or clustering models
- Feature engineering and preprocessing
- Model selection and hyperparameter tuning
- Integrating Polars or pandas with sklearn

## The Golden Rule: Always Use Pipeline

```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier

# WRONG — leaks test statistics into training
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)   # but the scaler saw train data first — fine
# Problem: if you do this INSIDE a cross-validation loop, each fold fits on the full training set

# CORRECT — Pipeline handles fit/transform sequencing automatically
pipeline = Pipeline([
    ("scaler", StandardScaler()),
    ("clf", RandomForestClassifier(n_estimators=100, random_state=42)),
])
pipeline.fit(X_train, y_train)
score = pipeline.score(X_test, y_test)
```

## ColumnTransformer for Mixed Data

```python
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer

numeric_features = ["age", "income", "credit_score"]
categorical_features = ["occupation", "region"]

preprocessor = ColumnTransformer(
    transformers=[
        ("num", Pipeline([
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler", StandardScaler()),
        ]), numeric_features),
        ("cat", Pipeline([
            ("imputer", SimpleImputer(strategy="most_frequent")),
            ("encoder", OneHotEncoder(handle_unknown="ignore", sparse_output=False)),
        ]), categorical_features),
    ],
    remainder="drop",   # drop unlisted columns
)

full_pipeline = Pipeline([
    ("preprocessor", preprocessor),
    ("classifier", RandomForestClassifier(random_state=42)),
])
```

## Cross-Validation

```python
from sklearn.model_selection import cross_val_score, StratifiedKFold

cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

scores = cross_val_score(
    full_pipeline,
    X, y,
    cv=cv,
    scoring="roc_auc",
    n_jobs=-1,   # parallel folds
)
print(f"AUC: {scores.mean():.4f} ± {scores.std():.4f}")

# For multiple metrics at once
from sklearn.model_selection import cross_validate

results = cross_validate(
    full_pipeline, X, y,
    cv=cv,
    scoring=["roc_auc", "f1", "precision", "recall"],
    return_train_score=True,
)
```

## Hyperparameter Tuning

```python
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV
from scipy.stats import randint, uniform

# Grid search (exhaustive, small param space)
param_grid = {
    "classifier__n_estimators": [100, 300, 500],
    "classifier__max_depth": [None, 5, 10],
    "preprocessor__num__imputer__strategy": ["mean", "median"],
}
grid_search = GridSearchCV(full_pipeline, param_grid, cv=5, scoring="roc_auc", n_jobs=-1)
grid_search.fit(X_train, y_train)
print(f"Best params: {grid_search.best_params_}")
print(f"Best AUC:    {grid_search.best_score_:.4f}")

# Randomized search (large param space)
param_dist = {
    "classifier__n_estimators": randint(100, 1000),
    "classifier__max_features": uniform(0.1, 0.9),
}
random_search = RandomizedSearchCV(
    full_pipeline, param_dist,
    n_iter=50, cv=5, scoring="roc_auc",
    random_state=42, n_jobs=-1
)
```

## Polars Integration

```python
# set_config enables Polars output from transformers (sklearn >= 1.4)
from sklearn import set_config
set_config(transform_output="polars")

# Now transformers return Polars DataFrames
transformed = preprocessor.fit_transform(X_train)
# transformed is a polars.DataFrame — use polars expressions downstream

# Or convert Polars → numpy for older sklearn APIs
import polars as pl
X_np = pl.DataFrame(X_polars).to_numpy()
```

## Custom Transformers

```python
from sklearn.base import BaseEstimator, TransformerMixin

class LogTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, columns: list[str]):
        self.columns = columns

    def fit(self, X, y=None):
        return self   # stateless — nothing to learn

    def transform(self, X):
        X = X.copy()   # immutable — never modify in place
        for col in self.columns:
            X[col] = np.log1p(X[col])
        return X
```

## Leakage Prevention Checklist

- [ ] ALL preprocessing steps inside `Pipeline` — never fit on the full dataset outside CV
- [ ] `StandardScaler`, `SimpleImputer`, `TargetEncoder` — must be inside pipeline
- [ ] Date features derived from `ts` column: compute BEFORE the split, not inside the pipeline (no future information)
- [ ] Target encoding: use `TargetEncoder` inside the pipeline (it handles CV folds correctly)
- [ ] Oversampling (SMOTE): apply ONLY to training folds, never before CV split → use `imblearn.pipeline.Pipeline`

## Model Persistence

```python
import joblib

# Save
joblib.dump(full_pipeline, "model.joblib")

# Load
pipeline = joblib.load("model.joblib")
preds = pipeline.predict(X_new)
```

## Common Estimators Reference

| Task | Estimator | Notes |
|------|-----------|-------|
| Binary classification | `LogisticRegression`, `RandomForestClassifier`, `GradientBoostingClassifier` | Use `class_weight="balanced"` for imbalance |
| Regression | `Ridge`, `Lasso`, `RandomForestRegressor` | `Ridge` for correlated features |
| Clustering | `KMeans`, `DBSCAN` | `DBSCAN` for arbitrary shapes |
| Dim reduction | `PCA`, `TruncatedSVD` | `TruncatedSVD` for sparse matrices |
| Feature selection | `SelectKBest`, `RFE` | Wrap in pipeline |

## Imbalanced Classes

```python
# Use class_weight for tree models
RandomForestClassifier(class_weight="balanced")

# Or oversample in pipeline (imblearn)
from imblearn.pipeline import Pipeline as ImbPipeline
from imblearn.over_sampling import SMOTE

imbpipeline = ImbPipeline([
    ("preprocessor", preprocessor),
    ("smote", SMOTE(random_state=42)),
    ("classifier", RandomForestClassifier()),
])
```
