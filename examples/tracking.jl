# tracking.jl — Basic experiment tracking
#
# Demonstrates: experiments, runs, parameters, metrics, tags, batch logging,
# metric history, and search.
#
# Usage:
#   1. Start an MLflow server:  mlflow server --host 0.0.0.0 --port 5000
#   2. Run this script:         julia --project=examples examples/tracking.jl

using MLFlowClient

mlf = MLFlow("http://localhost:5000")

# --- Experiment ---
experiment_id = createexperiment(mlf, "tracking-example";
    tags=Dict("team" => "data-science"))
println("Created experiment: $experiment_id")

# --- Run ---
run = createrun(mlf, experiment_id; run_name="gradient-descent")

# --- Parameters ---
logparam(mlf, run, "learning_rate", "0.01")
logparam(mlf, run, "optimizer", "sgd")
logparam(mlf, run, "epochs", "20")

# --- Metrics (logged per step) ---
for epoch in 1:20
    train_loss = 1.0 / epoch + 0.05 * rand()
    val_loss = 1.0 / epoch + 0.1 * rand()
    logmetric(mlf, run, "train_loss", train_loss; step=Int64(epoch))
    logmetric(mlf, run, "val_loss", val_loss; step=Int64(epoch))
end

# --- Batch logging ---
logbatch(mlf, run;
    metrics=[("final_accuracy", 0.93)],
    params=[("batch_size", "64")],
    tags=[("status", "complete")]
)

# --- Tags ---
setruntag(mlf, run, "model_type", "linear_regression")

# --- Complete the run ---
updaterun(mlf, run; status=RunStatus.FINISHED)
println("Run $(run.info.run_id) finished")

# --- Retrieve metric history ---
metrics, _ = getmetrichistory(mlf, run, "train_loss")
println("Logged $(length(metrics)) train_loss data points")

# --- Search ---
runs, _ = searchruns(mlf; experiment_ids=[experiment_id])
println("Found $(length(runs)) run(s) in experiment")

# --- Cleanup ---
deleteexperiment(mlf, experiment_id)
println("Done")
