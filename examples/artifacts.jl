# artifacts.jl — Working with artifacts
#
# Demonstrates: uploading, downloading, listing, and deleting artifacts
# through the mlflow-artifacts proxy.
#
# Usage:
#   1. Start an MLflow server:  mlflow server --host 0.0.0.0 --port 5000
#   2. Run this script:         julia --project=examples examples/artifacts.jl

using MLFlowClient

mlf = MLFlow("http://localhost:5000")

# --- Upload artifacts ---
# Artifacts are stored as raw bytes.
csv_content = "epoch,loss\n1,0.9\n2,0.7\n3,0.4\n"
uploadartifact(mlf, "results/metrics.csv", Vector{UInt8}(codeunits(csv_content)))
println("Uploaded results/metrics.csv")

config_json = """{"model": "resnet50", "lr": 0.001}"""
uploadartifact(mlf, "results/config.json", Vector{UInt8}(codeunits(config_json)))
println("Uploaded results/config.json")

# --- List artifacts ---
files = listartifactsdirect(mlf; path="results")
for f in files
    kind = f.is_dir ? "dir" : "file ($(f.file_size) bytes)"
    println("  $(f.path) — $kind")
end

# --- Download an artifact ---
data = downloadartifact(mlf, "results/metrics.csv")
println("\nDownloaded metrics.csv:")
println(String(data))

# --- Delete artifacts ---
deleteartifact(mlf, "results/metrics.csv")
deleteartifact(mlf, "results/config.json")
println("Artifacts deleted")
