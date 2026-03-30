"""
    MLFlowClient

[MLFlowClient](https://github.com/JuliaAI.jl) is a [Julia](https://julialang.org/) package
for working with [MLFlow](https://mlflow.org/) using the REST
[API v2.0](https://www.mlflow.org/docs/latest/rest-api.html).

`MLFlowClient` allows you to create and manage `MLFlow` experiments, runs, and log metrics
and artifacts. If you are not familiar with `MLFlow` and its concepts, please refer to
[MLFlow documentation](https://mlflow.org/docs/latest/index.html).
"""
module MLFlowClient

using PythonCall

const _mlflow = PythonCall.pynew()

function __init__()
    PythonCall.pycopy!(_mlflow, pyimport("mlflow"))
end

include("types/enums.jl")
include("types/entities.jl")

include("bindings/utils.jl")
include("bindings/mlflow.jl")
export get_tracking_uri, set_tracking_uri, set_experiment, start_run, active_run, end_run

end
