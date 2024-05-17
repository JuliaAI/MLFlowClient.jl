if ~haskey(ENV, "MLFLOW_TRACKING_URI")
    error("WARNING: MLFLOW_TRACKING_URI is not set. To run this tests, you need to set the URI of your MLFlow server API")
end

include("base.jl")

include("test_functional.jl")
include("test_experiments.jl")
include("test_runs.jl")
include("test_loggers.jl")
