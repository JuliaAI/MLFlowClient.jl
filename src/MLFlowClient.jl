"""
    MLFlowClient

[MLFlowClient](https://github.com/JuliaAI.jl) is a [Julia](https://julialang.org/) package for working with [MLFlow](https://mlflow.org/) using the REST [API v2.0](https://www.mlflow.org/docs/latest/rest-api.html).

`MLFlowClient` allows you to create and manage `MLFlow` experiments, runs, and log metrics and artifacts. If you are not familiar with `MLFlow` and its concepts, please refer to [MLFlow documentation](https://mlflow.org/docs/latest/index.html).

# Limitations

- no authentication support.
- when storing artifacts, the assumption is that MLFlow and this library run on the same server. Artifacts are stored using plain filesystem operations. Therefore, `/mlruns` or the specified `artifact_location` must be accessible to both the MLFlow server (read), and this library (write).
"""
module MLFlowClient

using Dates
using UUIDs
using HTTP
using URIs
using JSON
using ShowCases
using FilePathsBase: AbstractPath

include("types.jl")
export
    MLFlow,
    MLFlowExperiment,
    MLFlowRunStatus,
    MLFlowRunInfo,
    get_run_id,
    MLFlowRunData,
    get_params,
    MLFlowRunDataMetric,
    MLFlowRun,
    get_info,
    get_data,
    MLFlowArtifactFileInfo,
    MLFlowArtifactDirInfo,
    get_path,
    get_size

include("utils.jl")
export
    generatefilterfromparams

include("experiments.jl")
export
    createexperiment,
    getexperiment,
    getorcreateexperiment,
    deleteexperiment,
    listexperiments

include("runs.jl")
export
    createrun,
    getrun,
    updaterun,
    deleterun,
    searchruns,
    logparam,
    logmetric,
    logartifact,
    listartifacts

end
