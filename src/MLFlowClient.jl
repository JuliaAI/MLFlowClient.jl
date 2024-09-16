module MLFlowClient

using Dates
using UUIDs
using HTTP
using URIs
using JSON
using ShowCases
using FilePathsBase: AbstractPath

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

include("types/mlflow.jl")
export MLFlow

include("utils.jl")
include("api.jl")

include("services/experiment.jl")
export
    getexperiment,
    createexperiment,
    deleteexperiment,
    updateexperiment,
    restoreexperiment,
    searchexperiments,
    getexperimentbyname

include("services/run.jl")
export 
    createrun,
    deleterun,
    restorerun,
    getrun
end
