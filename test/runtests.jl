if ~haskey(ENV, "MLFLOW_TRACKING_URI")
    error("WARNING: MLFLOW_TRACKING_URI is not set. To run this tests, you need to set the URI of your MLFlow server API")
end

include("base.jl")

include("services/experiment.jl")
include("services/run.jl")
include("services/loggers.jl")
include("services/misc.jl")
