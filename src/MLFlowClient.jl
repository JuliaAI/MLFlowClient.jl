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

using Dates
using UUIDs
using HTTP
using URIs
using JSON
using ShowCases

include("types/mlflow.jl")
export MLFlow

include("types/tag.jl")
export Tag

include("types/enums.jl")
export ViewType, RunStatus, ModelVersionStatus

include("types/dataset.jl")
export Dataset, DatasetInput

include("types/artifact.jl")
export FileInfo

include("types/model_version.jl")
export ModelVersion

include("types/registered_model.jl")
export RegisteredModel, RegisteredModelAlias

include("types/experiment.jl")
export Experiment

include("types/run.jl")
export Run, Param, Metric, RunData, RunInfo, RunInputs

include("api.jl")

include("utils.jl")

include("services/experiment.jl")
export getexperiment, createexperiment, deleteexperiment, setexperimenttag,
    updateexperiment, restoreexperiment, searchexperiments, getexperimentbyname

include("services/run.jl")
export getrun, createrun, deleterun, setruntag, updaterun, restorerun, searchruns,
    deleteruntag

include("services/loggers.jl")
export logbatch, loginputs, logmetric, logparam

include("services/artifact.jl")
export listartifacts

include("services/misc.jl")
export refresh, getmetrichistory

include("services/registered_model.jl")
export getregisteredmodel, createregisteredmodel, deleteregisteredmodel,
    renameregisteredmodel, updateregisteredmodel

end
