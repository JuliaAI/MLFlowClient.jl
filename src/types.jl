"""
    MLFlow

Base type which defines location and version for MLFlow API service.

# Fields
- `baseuri::String`: base MLFlow tracking URI, e.g. `http://localhost:5000`
- `apiversion`: used API version, e.g. `2.0`

# Constructors

- `MLFlow(baseuri; apiversion=2.0)`
- `MLFlow()` - defaults to `MLFlow("http://localhost:5000")`

# Examples

```@example
mlf = MLFlow()
```

"""
struct MLFlow
    baseuri::String
    apiversion
end
MLFlow(baseuri; apiversion=2.0) = MLFlow(baseuri, apiversion)
MLFlow() = MLFlow("http://localhost:5000", 2.0)
Base.show(io::IO, t::MLFlow) = show(io, ShowCase(t, new_lines=true))

"""
    MLFlowExperiment

Represents an MLFlow experiment.

# Fields
- `name::String`: experiment name.
- `lifecycle_stage::String`: life cycle stage, one of ["active", "deleted"]
- `experiment_id::Integer`: experiment identifier.
- `tags::Any`: list of tags.
- `artifact_location::String`: where are experiment artifacts stored.

# Constructors

- `MLFlowExperiment(name, lifecycle_stage, experiment_id, tags, artifact_location)`
- `MLFlowExperiment(exp::Dict{String,Any})`

"""
struct MLFlowExperiment
    name::String
    lifecycle_stage::String
    experiment_id::Integer
    tags::Any
    artifact_location::String
end
function MLFlowExperiment(exp::Dict{String,Any})
    name = get(exp, "name", missing)
    lifecycle_stage = get(exp, "lifecycle_stage", missing)
    experiment_id = parse(Int, get(exp, "experiment_id", missing))
    tags = get(exp, "tags", missing)
    artifact_location = get(exp, "artifact_location", missing)
    MLFlowExperiment(name, lifecycle_stage, experiment_id, tags, artifact_location)
end
Base.show(io::IO, t::MLFlowExperiment) = show(io, ShowCase(t, new_lines=true))

"""
    MLFlowRunStatus

Represents the status of an MLFlow Run.

# Fields
- `status::String`: one of RUNNING/SCHEDULED/FINISHED/FAILED/KILLED

# Constructors

- `MLFlowRunStatus(status::String)`
"""
struct MLFlowRunStatus
    status::String
    function MLFlowRunStatus(status::String)
        acceptable_statuses = ["RUNNING", "SCHEDULED", "FINISHED", "FAILED", "KILLED"]
        status ∈ acceptable_statuses || error("Invalid status $status - choose one of $acceptable_statuses")
        new(status)
    end
end
Base.show(io::IO, t::MLFlowRunStatus) = show(io, ShowCase(t, new_lines=true))

"""
    MLFlowRunInfo

Represents run metadata.

# Fields
- `run_id::String`: run identifier.
- `experiment_id::Integer`: experiment identifier.
- `status::MLFlowRunStatus`: run status.
- `start_time::Union{Int64,Missing}`: when was the run started, UNIX time in milliseconds.
- `end_time::Union{Int64,Missing}`: when did the run end, UNIX time in milliseconds.
- `artifact_uri::String`: where are artifacts from this run stored.
- `lifecycle_stage::String`: one of `active` or `deleted`.

# Constructors

- `MLFlowRunInfo(run_id, experiment_id, status, start_time, end_time, artifact_uri, lifecycle_stage)`
- `MLFlowRunInfo(info::Dict{String,Any})`
"""
struct MLFlowRunInfo
    run_id::String
    experiment_id::Integer
    status::MLFlowRunStatus
    start_time::Union{Int64,Missing}
    end_time::Union{Int64,Missing}
    artifact_uri::String
    lifecycle_stage::String
end
function MLFlowRunInfo(info::Dict{String,Any})
    run_id = get(info, "run_id", missing)
    experiment_id = get(info, "experiment_id", missing)
    status = get(info, "status", missing)
    start_time = get(info, "start_time", missing)
    end_time = get(info, "end_time", missing)
    artifact_uri = get(info, "artifact_uri", "")
    lifecycle_stage = get(info, "lifecycle_stage", "")

    experiment_id = ismissing(experiment_id) ? experiment_id : parse(Int64, experiment_id)
    status = ismissing(status) ? status : MLFlowRunStatus(status)
    start_time = ismissing(start_time) ? start_time : parse(Int64, start_time)
    end_time = ismissing(end_time) ? end_time : parse(Int64, end_time)

    MLFlowRunInfo(run_id, experiment_id, status, start_time, end_time, artifact_uri, lifecycle_stage)
end
Base.show(io::IO, t::MLFlowRunInfo) = show(io, ShowCase(t, new_lines=true))
get_run_id(runinfo::MLFlowRunInfo) = runinfo.run_id

"""
    MLFlowRunDataMetric

Represents a metric.

# Fields
- `key::String`: metric identifier.
- `value::Float64`: metric value.
- `step::Int64`: step.
- `timestamp::Int64`: timestamp in UNIX time in milliseconds.

# Constructors

- `MLFlowRunDataMetric(d::Dict{String,Any})`

"""
struct MLFlowRunDataMetric
    key::String
    value::Float64
    step::Int64
    timestamp::Int64
end
function MLFlowRunDataMetric(d::Dict{String,Any})
    key = d["key"]
    value = d["value"]
    step = parse(Int64, d["step"])
    timestamp = parse(Int64, d["timestamp"])
    MLFlowRunDataMetric(key, value, step, timestamp)
end
Base.show(io::IO, t::MLFlowRunDataMetric) = show(io, ShowCase(t, new_lines=true))

"""
    MLFlowRunData

Represents run data.

# Fields
- `metrics::Dict{String,MLFlowRunDataMetric}`: run metrics.
- `params::Dict{String,String}`: run parameters.
- `tags`: list of run tags.

# Constructors

- `MLFlowRunData(data::Dict{String,Any})`

"""
struct MLFlowRunData
    metrics::Dict{String,MLFlowRunDataMetric}
    params::Union{Dict{String,String},Missing}
    tags
end
function MLFlowRunData(data::Dict{String,Any})
    metrics = Dict{String,MLFlowRunDataMetric}()
    if haskey(data, "metrics")
        for metric in data["metrics"]
            v = MLFlowRunDataMetric(metric)
            metrics[v.key] = v
        end
    end
    if haskey(data, "params")
        params = Dict{String,String}()
        for p in data["params"]
            params[p["key"]] = p["value"]
        end
    else
        params = Dict{String,String}()
    end
    tags = haskey(data, "tags") ? data["tags"] : missing
    MLFlowRunData(metrics, params, tags)
end
Base.show(io::IO, t::MLFlowRunData) = show(io, ShowCase(t, new_lines=true))
get_params(rundata::MLFlowRunData) = rundata.params

"""
    MLFlowRun

Represents an MLFlow run.

# Fields
- `info::MLFlowRunInfo`: Run metadata.
- `data::MLFlowRunData`: Run data.

# Constructors

- `MLFlowRun(rundata::MLFlowRunData)`
- `MLFlowRun(runinfo::MLFlowRunInfo)`
- `MLFlowRun(info::Dict{String,Any})`
- `MLFlowRun(info::Dict{String,Any}, data::Dict{String,Any})`

"""
struct MLFlowRun
    info::Union{MLFlowRunInfo,Missing}
    data::Union{MLFlowRunData,Missing}
end
MLFlowRun(rundata::MLFlowRunData) =
    MLFlowRun(missing, rundata)
MLFlowRun(runinfo::MLFlowRunInfo) =
    MLFlowRun(runinfo, missing)
MLFlowRun(info::Dict{String,Any}) =
    MLFlowRun(MLFlowRunInfo(info), missing)
MLFlowRun(info::Dict{String,Any}, data::Dict{String,Any}) =
    MLFlowRun(MLFlowRunInfo(info), MLFlowRunData(data))
Base.show(io::IO, t::MLFlowRun) = show(io, ShowCase(t, new_lines=true))
get_info(run::MLFlowRun) = run.info
get_data(run::MLFlowRun) = run.data
get_run_id(run::MLFlowRun) = get_run_id(run.info)
get_params(run::MLFlowRun) = get_params(run.data)

"""
    MLFlowArtifactFileInfo

Metadata of a single artifact file -- result of [`listartifacts`](@ref).

# Fields
- `filepath::String`: File path, including the root artifact directory of a run.
- `filesize::Int64`: Size in bytes.
"""
struct MLFlowArtifactFileInfo
    filepath::String
    filesize::Int64
end
Base.show(io::IO, t::MLFlowArtifactFileInfo) = show(io, ShowCase(t, new_lines=true))
get_path(mlfafi::MLFlowArtifactFileInfo) = mlfafi.filepath
get_size(mlfafi::MLFlowArtifactFileInfo) = mlfafi.filesize

"""
    MLFlowArtifactDirInfo

Metadata of a single artifact directory -- result of [`listartifacts`](@ref).

# Fields
- `dirpath::String`: Directory path, including the root artifact directory of a run.
"""
struct MLFlowArtifactDirInfo
    dirpath::String
end
Base.show(io::IO, t::MLFlowArtifactDirInfo) = show(io, ShowCase(t, new_lines=true))
get_path(mlfadi::MLFlowArtifactDirInfo) = mlfadi.dirpath
get_size(mlfadi::MLFlowArtifactDirInfo) = 0
