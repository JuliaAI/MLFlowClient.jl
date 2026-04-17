```@meta
CurrentModule = MLFlowClient
```

# MLFlowClient.jl

```@docs
MLFlowClient
```

A Julia client for the [MLflow](https://mlflow.org/) REST API. Track experiments, log metrics and parameters, manage models, and more — directly from Julia.

Tested against MLflow 3.11.1.

## Installation

```julia
using Pkg
Pkg.add("MLFlowClient")
```

## Quick start

```julia
using MLFlowClient

# Connect to an MLflow server
mlf = MLFlow("http://localhost:5000")

# Create an experiment and a run
experiment_id = createexperiment(mlf, "my-experiment")
run = createrun(mlf, experiment_id)

# Log parameters, metrics, and tags
logparam(mlf, run, "learning_rate", "0.01")
logmetric(mlf, run, "accuracy", 0.95)
setruntag(mlf, run, "model_type", "linear")

# Complete the run
updaterun(mlf, run; status=RunStatus.FINISHED)
```

## API coverage

MLFlowClient implements the full [MLflow REST API](https://mlflow.org/docs/latest/api_reference/rest-api.html) (v2.0 and v3.0) and the [Authentication REST API](https://mlflow.org/docs/latest/api_reference/auth/rest-api.html):

- **Experiments** — create, get, search, update, delete, restore, tags
- **Runs** — create, get, search, update, delete, restore, tags
- **Logging** — metrics, parameters, batch, model, inputs
- **Artifacts** — list, upload, download, delete, multipart upload, presigned URLs
- **Registered models** — create, get, search, rename, update, delete, tags, aliases
- **Model versions** — create, get, search, update, delete, transition stage, tags
- **Scorers** — register, list, get, delete (v3.0)
- **Gateway** — secrets, model definitions, endpoints, bindings, tags, budgets (v3.0)
- **Prompt optimization** — create, get, search, cancel, delete jobs (v3.0)
- **Webhooks** — create, get, list, update, delete, test
- **Users & permissions** — create, get, update, delete users; experiment and model permissions

## Authentication

```julia
# Basic auth
mlf = MLFlow("http://localhost:5000"; username="admin", password="password")

# Token-based auth (e.g., Databricks)
mlf = MLFlow("https://my-server.cloud.databricks.com";
    headers=Dict("Authorization" => "Bearer <token>"))
```

The environment variables `MLFLOW_TRACKING_URI`, `MLFLOW_TRACKING_USERNAME`, and `MLFLOW_TRACKING_PASSWORD` are respected when set, and will override the corresponding constructor arguments.

## Next steps

Head to the [Tutorial](@ref) for a walkthrough of the common tracking workflow, or browse the [API Reference](reference/types.md) for the full list of types and operations.
