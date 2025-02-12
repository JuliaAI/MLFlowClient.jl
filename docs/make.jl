push!(LOAD_PATH, "../src/")
using Documenter
using MLFlowClient

makedocs(;
    sitename="MLFlowClient.jl",
    authors="@deyandyankov and contributors",
    pages=["Home" => "index.md", "Tutorial" => "tutorial.md", "Reference" => [
        "Types" => "reference/types.md", "Artifact operations" => "reference/artifact.md",
        "Experiment operations" => "reference/experiment.md",
        "Logging operations" => "reference/logger.md",
        "Miscellaneous operations" => "reference/misc.md",
        "Run operations" => "reference/run.md",
        "Registered model operations" => "reference/registered_model.md",
        "Model version operations" => "reference/model_version.md",
        "User operations" => "reference/user.md",]])

deploydocs(; repo="github.com/JuliaAI/MLFlowClient.jl", devbranch="main")
