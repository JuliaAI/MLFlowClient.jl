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
``` julia-repl
julia> mlf = MLFlow()
MLFlow("http://localhost:5000", 2.0)
```

"""
struct MLFlow
    baseuri::String
    apiversion
    MLFlow(baseuri; apiversion=2.0) = new(baseuri, apiversion)
end
MLFlow() = MLFlow("http://localhost:5000")

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
    function MLFlowRunDataMetric(d::Dict{String,Any})
        key = d["key"]
        value = d["value"]
        step = parse(Int64, d["step"])
        timestamp = parse(Int64, d["timestamp"])
        new(key, value, step, timestamp)
    end
end


"""
    MLFlowRunData

Represents run data.

# Fields
- `metrics::Vector{MLFlowRunDataMetric}`: run metrics.
- `params::Dict{String,String}`: run parameters.
- `tags`: list of run tags.

# Constructors

- `MLFlowRunData(data::Dict{String,Any})`

"""
struct MLFlowRunData
    metrics::Vector{MLFlowRunDataMetric}
    params::Union{Dict{String,String},Missing}
    tags
    function MLFlowRunData(data::Dict{String,Any})
        metrics = haskey(data, "metrics") ? MLFlowRunDataMetric.(data["metrics"]) : MLFlowRunDataMetric[]
        if haskey(data, "params")
            params = Dict{String,String}()
            for p in data["params"]
                params[p["key"]] = p["value"]
            end
        else
            params = Dict{String,String}()
        end
        tags = haskey(data, "tags") ? data["tags"] : missing
        new(metrics, params, tags)
    end
end

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

    function MLFlowRun(rundata::MLFlowRunData)
        info = missing
        new(info, rundata)
    end
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
