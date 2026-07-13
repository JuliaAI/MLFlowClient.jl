# Use a shared, persistent CondaPkg environment so MLflow is provisioned once and can be
# cached (locally and in CI) instead of rebuilt on every run. Must be set before CondaPkg
# or PythonCall load (see server.jl).
get!(ENV, "JULIA_CONDAPKG_ENV", "@mlflowclient")

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
include("types/role.jl")
include("types/workspace.jl")
include("types/webhook.jl")
include("types/scorer.jl")
include("types/gateway.jl")
include("types/prompt_optimization.jl")
include("types/label_schema.jl")
include("types/review_queue.jl")
include("types/api.jl")
include("types/utils.jl")

# --- Integration tests (managed MLflow server with basic auth) ---

include("server.jl")

server = start_mlflow_server()
ENV["MLFLOW_TRACKING_URI"] = server.uri
try
    include("base.jl")

    include("services/run.jl")
    include("services/misc.jl")
    include("services/logger.jl")
    include("services/artifact.jl")
    include("services/experiment.jl")
    include("services/registered_model.jl")
    include("services/model_version.jl")
    include("services/user.jl")
    include("services/workspace.jl")
    include("services/webhook.jl")
    include("services/scorer.jl")
    include("services/gateway.jl")
    include("services/prompt_optimization.jl")
    include("services/label_schema.jl")
    include("services/review_queue.jl")
    include("services/api_errors.jl")
finally
    delete!(ENV, "MLFLOW_TRACKING_URI")
    stop_mlflow_server(server)
end
