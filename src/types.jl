"""
    MLFlow(baseuri; apiversion)

Base type which defines location and version for MLFlow API service.

# Fields
- `baseuri::String`: base MLFlow tracking URI, e.g. `http://localhost:5000`
- `apiversion`: used API version, e.g. `2.0`

# Examples
``` julia-repl
julia> mlf = MLFlow("http://localhost:5000")
MLFlow("http://localhost:5000", 2.0)
```
"""
struct MLFlow
    baseuri::String
    apiversion
    MLFlow(baseuri; apiversion=2.0) = new(baseuri, apiversion)
end

"""
    MLFlowExperiment

Represents an MLFlow experiment.

# Fields
- `name::String`: experiment name.
- `lifecycle_stage::String`: life cycle stage, one of ["active", "deleted"]
- `experiment_id::Integer`: experiment identifier.
- `tags::Any`: list of tags.
- `artifact_location::String`: where are experiment artifacts stored.
"""
struct MLFlowExperiment
    name::String
    lifecycle_stage::String
    experiment_id::Integer
    tags::Any
    artifact_location::String

    MLFlowExperiment(name, lifecycle_stage, experiment_id, tags, artifact_location) =
        new(name, lifecycle_stage, experiment_id, tags, artifact_location)
   
    function MLFlowExperiment(exp::Dict{String,Any})
        name = get(exp, "name", missing)
        lifecycle_stage = get(exp, "lifecycle_stage", missing)
        experiment_id = parse(Int, get(exp, "experiment_id", missing))
        tags = get(exp, "tags", missing)
        artifact_location = get(exp, "artifact_location", missing)
        MLFlowExperiment(name, lifecycle_stage, experiment_id, tags, artifact_location)
    end
end


"""
    MLFlowRunStatus

Represents the status of an MLFlow Run.

# Fields
- `status::String`: one of RUNNING/SCHEDULED/FINISHED/FAILED/KILLED

"""
struct MLFlowRunStatus
    status::String

    function MLFlowRunStatus(status)
        acceptable_statuses = ["RUNNING", "SCHEDULED", "FINISHED", "FAILED", "KILLED"]
        status ∈ acceptable_statuses || error("Invalid status $status - choose one of $acceptable_statuses")
        new(status)
    end
end

"""
    MLFlowRunInfo

Represents run metadata.

# Fields
- `run_id::String`
- `experiment_id::Integer`
- `status::MLFlowRunStatus` 
- `start_time::Union{Int64,Missing}`
- `end_time::Union{Int64,Missing}`
- `artifact_uri::String`
- `lifecycle_stage::String`
"""
struct MLFlowRunInfo
    run_id::String
    experiment_id::Integer
    status::MLFlowRunStatus
    start_time::Union{Int64,Missing}
    end_time::Union{Int64,Missing}
    artifact_uri::String
    lifecycle_stage::String

    function MLFlowRunInfo(run_id, experiment_id, status, start_time, end_time, artifact_uri, lifecycle_stage)
        new(run_id, experiment_id, status, start_time, end_time, artifact_uri, lifecycle_stage)
    end

    function MLFlowRunInfo(info::Dict{String,Any})
        run_id = get(info, "run_id", missing)
        experiment_id = get(info, "experiment_id", missing)
        status = get(info, "status", missing)
        start_time = get(info, "start_time", missing)
        end_time = get(info, "end_time", missing)
        artifact_uri = get(info, "artifact_uri", "")
        lifecycle_stage = get(info, "lifecycle_stage", "")

        if !ismissing(experiment_id)
            experiment_id = parse(Int64, experiment_id)
        end

        if !ismissing(status)
            status = MLFlowRunStatus(status)
        end

        if !ismissing(start_time)
            start_time = parse(Int64, start_time)
        end

        if !ismissing(end_time)
            end_time = parse(Int64, end_time)
        end

        MLFlowRunInfo(run_id, experiment_id, status, start_time, end_time, artifact_uri, lifecycle_stage)
    end
end

"""
    MLFlowRunData

Represents run data.

# Fields
- `metrics`
- `params`
- `tags`

# TODO
Incomplete functionality.

"""
struct MLFlowRunData
    metrics
    params
    tags
    function MLFlowRunData(data::Dict{String,Any})
        new([], [], []) # TODO: add functionality
    end
end

"""
    MLFlowRun

Represents an MLFlow run.

# Fields
- `info::MLFlowRunInfo`: Run metadata.
- `data::MLFlowRunData`: Run data.
"""
struct MLFlowRun
    info::MLFlowRunInfo
    data::Union{MLFlowRunData,Missing}

    function MLFlowRun(runinfo::MLFlowRunInfo)
        data = missing
        new(runinfo, data)
    end
    function MLFlowRun(info::Dict{String,Any})
        info = MLFlowRunInfo(info)
        data = missing
        new(info, data)
    end
    function MLFlowRun(info::Dict{String,Any}, data::Dict{String,Any})
        info = MLFlowRunInfo(info)
        data = MLFlowRunData(data)
        new(info, data)
    end
end
