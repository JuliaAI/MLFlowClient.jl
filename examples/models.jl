# models.jl — Registered models and model versions
#
# Demonstrates: creating registered models, model versions, tags, aliases,
# stage transitions, and search.
#
# Usage:
#   1. Start an MLflow server:  mlflow server --host 0.0.0.0 --port 5000
#   2. Run this script:         julia --project=examples examples/models.jl

using MLFlowClient

mlf = MLFlow("http://localhost:5000")

# --- Setup: create an experiment and run to get an artifact URI ---
experiment_id = createexperiment(mlf, "models-example")
run = createrun(mlf, experiment_id)
updaterun(mlf, run; status=RunStatus.FINISHED)

# --- Registered model ---
model = createregisteredmodel(mlf, "my-classifier";
    description="A demo classifier",
    tags=Dict("framework" => "flux"))
println("Created model: $(model.name)")

# --- Model version ---
version = createmodelversion(mlf, model.name, run.info.artifact_uri;
    run_id=run.info.run_id,
    description="Initial version",
    tags=[Tag("stage", "dev")])
println("Created version: $(version.version)")

# --- Tags ---
setmodelversiontag(mlf, model.name, version.version, "validated", "true")
setregisteredmodeltag(mlf, model.name, "owner", "ml-team")

# --- Aliases ---
setregisteredmodelalias(mlf, model.name, "champion", version.version)

retrieved = getmodelversionbyalias(mlf, model.name, "champion")
println("Champion alias points to version: $(retrieved.version)")

# --- Stage transition ---
transitionmodelversionstage(mlf, model.name, version.version, "Production", true)
println("Transitioned to Production")

# --- Search ---
models, _ = searchregisteredmodels(mlf; filter="name LIKE '%classifier%'")
println("Found $(length(models)) model(s) matching filter")

versions, _ = searchmodelversions(mlf; filter="name='my-classifier'")
println("Found $(length(versions)) version(s)")

# --- Download URI ---
uri = getdownloaduriformodelversionartifacts(mlf, model.name, version.version)
println("Artifact URI: $uri")

# --- Cleanup ---
deleteregisteredmodel(mlf, model.name)
deleteexperiment(mlf, experiment_id)
println("Done")
