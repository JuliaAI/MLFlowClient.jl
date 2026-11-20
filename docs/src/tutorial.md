# Tutorial

This tutorial covers the common MLflow tracking workflow with `MLFlowClient`: creating experiments, logging parameters, metrics, and artifacts, and managing runs.

!!! note
    This tutorial assumes you have an MLflow server running locally. Start one with:
    ```bash
    mlflow server --host 0.0.0.0 --port 5000
    ```


## Connecting to MLflow

```julia
using MLFlowClient

# Connect to a local MLflow server
mlf = MLFlow("http://localhost:5000")

# Or with authentication
mlf = MLFlow("http://localhost:5000"; username="admin", password="password")
```


### Connecting to DagsHub

DagsHub provides a hosted MLflow tracking server for logging experiments remotely.

Create a repository on [DagsHub](https://dagshub.com) and obtain its MLflow tracking URI and an access token.

Set your DagsHub access token in the `DAGSHUB_TOKEN` environment variable before starting Julia. Then connect using:

```julia
mlf = MLFlow("https://dagshub.com/USERNAME/REPOSITORY.mlflow";
    username="USERNAME",
    password=ENV["DAGSHUB_TOKEN"]
)
```

Replace `USERNAME` and `REPOSITORY` with your DagsHub details.

Verify the connection:

```julia
experiments, _ = searchexperiments(mlf)
println("Experiments found: ", length(experiments))
```

An empty experiment list is normal for a new repository.

!!! note
    `MLFLOW_TRACKING_URI`, `MLFLOW_TRACKING_USERNAME`, and `MLFLOW_TRACKING_PASSWORD` override the corresponding arguments passed to the `MLFlow` constructor when set.

    Artifact upload and download functionality has not been tested against DagsHub.


## Creating an experiment and a run

```julia
# Create a new experiment
experiment_id = createexperiment(mlf, "my-experiment")

# Create a run within the experiment
run = createrun(mlf, experiment_id; run_name="training-run-1")
```

## Logging parameters

Parameters are string key-value pairs, typically used for hyperparameters.

```julia
# Log individual parameters
logparam(mlf, run, "learning_rate", "0.01")
logparam(mlf, run, "epochs", "100")
logparam(mlf, run, "model", "linear_regression")
```

## Logging metrics

Metrics are numeric key-value pairs with timestamps. They can be logged multiple times to track progress over time.

```julia
# Log a single metric
logmetric(mlf, run, "accuracy", 0.85)

# Log metrics at specific steps (e.g., per epoch)
for epoch in 1:10
    loss = 1.0 / epoch  # simulated loss
    logmetric(mlf, run, "loss", loss; step=epoch)
end
```

## Logging in batch

For efficiency, you can log multiple metrics, parameters, and tags in a single call.

```julia
logbatch(mlf, run;
    metrics=[("rmse", 0.12), ("mae", 0.08)],
    params=[("optimizer", "adam"), ("batch_size", "32")],
    tags=[("version", "v1.0")]
)
```

## Logging artifacts

Upload and download files associated with a run.

```julia
# Upload an artifact
data = Vector{UInt8}(codeunits("model weights or any binary data"))
uploadartifact(mlf, "models/weights.bin", data)

# Download it back
downloaded = downloadartifact(mlf, "models/weights.bin")

# List artifacts
root_uri, files, _ = listartifacts(mlf, run)
```

## Tagging runs

Tags are mutable metadata on runs, useful for labeling and filtering.

```julia
# Set a tag
setruntag(mlf, run, "environment", "production")

# Remove a tag
deleteruntag(mlf, run, "environment")
```

## Completing a run

```julia
updaterun(mlf, run; status=RunStatus.FINISHED)
```

## Searching experiments and runs

```julia
# Search all active experiments
experiments, _ = searchexperiments(mlf)

# Search runs with a filter
runs, _ = searchruns(mlf;
    experiment_ids=[experiment_id],
    filter="metrics.accuracy > 0.8"
)
```

## Retrieving metric history

```julia
metrics, _ = getmetrichistory(mlf, run, "loss")
for m in metrics
    println("step=$(m.step), value=$(m.value)")
end
```

## Cleaning up

```julia
deleteexperiment(mlf, experiment_id)
```
