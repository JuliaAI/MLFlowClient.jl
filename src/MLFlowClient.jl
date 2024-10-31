module MLFlowClient

using Dates
using UUIDs
using HTTP
using URIs
using JSON
using ShowCases
using FilePathsBase: AbstractPath

include("types/mlflow.jl")
export MLFlow

include("types/tag.jl")
export Tag

include("types/enums.jl")
export
    ViewType,
    RunStatus,
    ModelVersionStatus

include("types/dataset.jl")
export
    Dataset,
    DatasetInput

include("types/artifact.jl")
export FileInfo

include("types/model_version.jl")
export ModelVersion

include("types/registered_model.jl")
export
    RegisteredModel,
    RegisteredModelAlias

include("types/experiment.jl")
export Experiment

include("types/run.jl")
export
    Run,
    Param,
    Metric,
    RunData,
    RunInfo,
    RunInputs

include("utils.jl")
export refresh
include("api.jl")

include("services/experiment.jl")
export
    getexperiment,
    createexperiment,
    deleteexperiment,
    setexperimenttag,
    updateexperiment,
    restoreexperiment,
    searchexperiments,
    getexperimentbyname

include("services/run.jl")
export 
    getrun,
    createrun,
    deleterun,
    setruntag,
    restorerun,
    deleteruntag

include("services/loggers.jl")
export
    logbatch,
    loginputs,
    logmetric

end
