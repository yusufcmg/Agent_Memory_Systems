---
disable-model-invocation: true
name: mlflow-patterns
description: MLflow experiment tracking, model registry, autologging, and deployment patterns for reproducible ML workflows.
origin: AMS
---

# MLflow Patterns

MLflow is the standard experiment tracking and model registry for production ML. Every training run must be tracked; every production model must be registered.

## When to Activate

- Training or evaluating ML models
- Setting up experiment tracking infrastructure
- Managing model versions and promotions
- Deploying models via MLflow serving

## Core Concepts

| Concept | Description |
|---------|-------------|
| **Experiment** | Named group of runs (e.g., "fraud-detection-v2") |
| **Run** | Single training execution with params, metrics, artifacts |
| **Artifact** | Files saved to a run: model, plots, confusion matrix, feature importance |
| **Model Registry** | Versioned model store with lifecycle stages: None → Staging → Production → Archived |

## Experiment Tracking

```python
import mlflow
import mlflow.sklearn  # or mlflow.pytorch, mlflow.xgboost, etc.

mlflow.set_experiment("my-project/fraud-detection")

with mlflow.start_run(run_name="xgb-v3-polars-features") as run:
    # Log hyperparameters
    mlflow.log_params({
        "learning_rate": 0.01,
        "max_depth": 6,
        "n_estimators": 500,
        "subsample": 0.8,
    })

    # Train model
    model.fit(X_train, y_train)

    # Log metrics
    mlflow.log_metrics({
        "train_auc": roc_auc_score(y_train, model.predict_proba(X_train)[:, 1]),
        "val_auc": roc_auc_score(y_val, model.predict_proba(X_val)[:, 1]),
        "train_f1": f1_score(y_train, model.predict(X_train)),
    })

    # Log artifacts
    mlflow.log_figure(fig, "confusion_matrix.png")
    mlflow.log_dict(feature_importance_dict, "feature_importance.json")

    # Log model (with signature and input example)
    signature = mlflow.models.infer_signature(X_train, model.predict(X_train))
    mlflow.sklearn.log_model(model, "model", signature=signature, input_example=X_train[:5])

    print(f"Run ID: {run.info.run_id}")
```

## Autologging (Zero-Config Tracking)

```python
# Enable autologging before training — logs params, metrics, model automatically
mlflow.sklearn.autolog()
mlflow.pytorch.autolog()
mlflow.xgboost.autolog()
mlflow.lightgbm.autolog()

# Or enable all supported frameworks at once
mlflow.autolog()

# Autologging captures:
# - All hyperparameters passed to fit()
# - Training and validation metrics per epoch
# - The model artifact with signature
# - Cross-validation results (sklearn)
```

## Logging Metrics Over Time

```python
with mlflow.start_run():
    for epoch in range(num_epochs):
        train_loss = train_one_epoch(model, loader)
        val_loss = evaluate(model, val_loader)

        # step= enables time-series charts in MLflow UI
        mlflow.log_metrics({
            "train_loss": train_loss,
            "val_loss": val_loss,
        }, step=epoch)
```

## Model Registry

```python
from mlflow.tracking import MlflowClient

client = MlflowClient()

# Register model from a run
result = mlflow.register_model(
    f"runs:/{run_id}/model",
    "fraud-detection-xgb"
)

# Transition to staging after validation
client.transition_model_version_stage(
    name="fraud-detection-xgb",
    version=result.version,
    stage="Staging",
    archive_existing_versions=False,
)

# Promote to production (after canary validation)
client.transition_model_version_stage(
    name="fraud-detection-xgb",
    version=result.version,
    stage="Production",
    archive_existing_versions=True,  # archive previous production
)

# Load production model
model = mlflow.sklearn.load_model("models:/fraud-detection-xgb/Production")
```

## Tagging Runs for Searchability

```python
with mlflow.start_run():
    mlflow.set_tags({
        "team": "data-science",
        "dataset_version": "v2024-05",
        "git_commit": subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip(),
        "feature_set": "polars-pipeline-v3",
    })
```

## Querying Experiments

```python
# Find best runs
runs = mlflow.search_runs(
    experiment_names=["fraud-detection"],
    filter_string="metrics.val_auc > 0.95 AND params.max_depth = '6'",
    order_by=["metrics.val_auc DESC"],
    max_results=10,
)
print(runs[["run_id", "metrics.val_auc", "params.learning_rate"]])
```

## Reproducibility Checklist

- [ ] `mlflow.set_experiment(...)` called before every training script
- [ ] All hyperparameters logged with `mlflow.log_params()`
- [ ] Metrics logged per epoch/fold with `step=`
- [ ] Model logged with `signature` and `input_example`
- [ ] `git_commit` tag set on every run
- [ ] Dataset version or hash logged as a tag or artifact
- [ ] Run name is descriptive (`model-features-date` format)

## MLflow UI

```bash
# Start local tracking server
mlflow ui --port 5000

# Start with remote backend (Postgres + S3)
mlflow server \
  --backend-store-uri postgresql://user:pass@host/mlflow \
  --default-artifact-root s3://my-bucket/mlflow-artifacts \
  --port 5000
```
