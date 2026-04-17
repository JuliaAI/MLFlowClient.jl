using Test
using Dates
using UUIDs
using Base64
using MLFlowClient

# --- Unit tests (no server required) ---

include("mocks.jl")

include("types/mlflow.jl")
include("types/enums.jl")
include("types/tag.jl")
include("types/artifact.jl")
include("types/dataset.jl")
include("types/model.jl")
include("types/experiment.jl")
include("types/registered_model.jl")
include("types/run.jl")
include("types/user.jl")
include("types/webhook.jl")
include("types/scorer.jl")
include("types/gateway.jl")
include("types/prompt_optimization.jl")
include("types/api.jl")
include("types/utils.jl")

# --- Integration tests (require running MLflow server) ---

if haskey(ENV, "MLFLOW_TRACKING_URI")
    include("base.jl")

    include("services/run.jl")
    include("services/misc.jl")
    include("services/logger.jl")
    include("services/artifact.jl")
    include("services/experiment.jl")
    include("services/registered_model.jl")
    include("services/model_version.jl")
    include("services/user.jl")
    include("services/webhook.jl")
    include("services/scorer.jl")
    include("services/gateway.jl")
    include("services/prompt_optimization.jl")
    include("services/api_errors.jl")
else
    @warn "MLFLOW_TRACKING_URI is not set. Skipping integration tests. " *
        "To run integration tests, set MLFLOW_TRACKING_URI to the URI of your MLFlow server API."
end
