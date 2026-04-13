if ~haskey(ENV, "MLFLOW_TRACKING_URI")
    error(
        "WARNING: MLFLOW_TRACKING_URI is not set. To run tests, "*
            "you need to set this to the URI of your MLFlow server API. "*
            "Setting this in Julia will look something like\n"*
            "`ENV[\"MLFLOW_TRACKING_URI\"] = \"http://127.0.0.1:5000/api\"` "
    )
end

include("base.jl")

include("types/mlflow.jl")

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
