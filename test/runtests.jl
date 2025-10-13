if ~haskey(ENV, "MLFLOW_TRACKING_URI")
    error("WARNING: MLFLOW_TRACKING_URI is not set. To run this tests, you need to set the URI of your MLFlow server API")
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
include("doctests.jl")
