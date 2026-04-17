# MLFlowClient.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaai.github.io/MLFlowClient.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaai.github.io/MLFlowClient.jl/dev)
[![Build Status](https://github.com/JuliaAI/MLFlowClient.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaAI/MLFlowClient.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaAI/MLFlowClient.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaAI/MLFlowClient.jl)

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

## What's covered

MLFlowClient implements the full [MLflow REST API](https://mlflow.org/docs/latest/api_reference/rest-api.html) (v2.0 and v3.0) and the [Authentication REST API](https://mlflow.org/docs/latest/api_reference/auth/rest-api.html):

| Area | Operations |
|---|---|
| **Experiments** | Create, get, search, update, delete, restore, tags |
| **Runs** | Create, get, search, update, delete, restore, tags |
| **Logging** | Metrics, parameters, batch, model, inputs |
| **Artifacts** | List, upload, download, delete, multipart upload, presigned URLs |
| **Registered models** | Create, get, search, rename, update, delete, tags, aliases |
| **Model versions** | Create, get, search, update, delete, transition stage, tags |
| **Scorers** | Register, list, get, delete (v3.0) |
| **Gateway** | Secrets, model definitions, endpoints, bindings, tags, budgets (v3.0) |
| **Prompt optimization** | Create, get, search, cancel, delete jobs (v3.0) |
| **Webhooks** | Create, get, list, update, delete, test |
| **Users & permissions** | Create, get, update, delete users; experiment and model permissions |

## Authentication

```julia
# Basic auth
mlf = MLFlow("http://localhost:5000"; username="admin", password="password")

# Token-based auth
mlf = MLFlow("http://localhost:5000"; headers=Dict("Authorization" => "Bearer <token>"))
```

Environment variables `MLFLOW_TRACKING_URI`, `MLFLOW_TRACKING_USERNAME`, and `MLFLOW_TRACKING_PASSWORD` are respected when set.

## Documentation

See the [full documentation](https://juliaai.github.io/MLFlowClient.jl) for the complete API reference and tutorial.
