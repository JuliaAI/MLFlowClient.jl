if ~haskey(ENV, "MLFLOW_TRACKING_URI")
    error(
        "WARNING: MLFLOW_TRACKING_URI is not set. To run tests, "*
            "you need to set thito the URI of your MLFlow server API. "*
            "It's value will look something like \"http://localhost:5000/api\". "
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
