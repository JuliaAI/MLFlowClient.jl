if ~haskey(ENV, "MLFLOW_TRACKING_URI")
    error("WARNING: MLFLOW_TRACKING_URI is not set. To run this tests, you need to set the URI of your MLFlow server API")
end

include("base.jl")

include("services/run.jl")
include("services/misc.jl")
include("services/loggers.jl")
include("services/artifact.jl")
include("services/experiment.jl")
include("services/registered_model.jl")
