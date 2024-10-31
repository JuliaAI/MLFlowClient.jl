"""
    createrun(instance::MLFlow, experiment_id::String;
        run_name::Union{String, Missing}=missing,
        start_time::Union{Int64, Missing}=missing,
        tags::Union{Dict{<:Any}, Array{<:Any}}=[])

Create a new run within an experiment. A run is usually a single execution of a
machine learning or data ETL pipeline.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: ID of the associated experiment.
- `run_name`: Name of the run.
- `start_time`: Unix timestamp in milliseconds of when the run started.
- `tags`: Additional metadata for run.

# Returns
An instance of type [`Run`](@ref).
"""
function createrun(instance::MLFlow, experiment_id::String;
    run_name::Union{String, Missing}=missing,
    start_time::Union{Int64, Missing}=missing,
    tags::MLFlowUpsertData{Tag}=Tag[])::Run
    result = mlfpost(instance, "runs/create"; experiment_id=experiment_id,
        run_name=run_name, start_time=start_time, tags=parse(Tag, tags))
    return result["run"] |> Run
end
createrun(instance::MLFlow, experiment_id::Integer;
    run_name::Union{String, Missing}=missing,
    start_time::Union{Integer, Missing}=missing,
    tags::MLFlowUpsertData{Tag}=Tag[])::Run =
    createrun(instance, string(experiment_id); run_name=run_name,
        start_time=start_time, tags=tags)
createrun(instance::MLFlow, experiment::Experiment;
    run_name::Union{String, Missing}=missing,
    start_time::Union{Integer, Missing}=missing,
    tags::MLFlowUpsertData{Tag}=Tag[])::Run =
    createrun(instance, string(experiment.experiment_id); run_name=run_name,
        start_time=start_time, tags=tags)

"""
    deleterun(instance::MLFlow, run_id::String)
    deleterun(instance::MLFlow, run::Run)

Mark a run for deletion.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the run to delete.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deleterun(instance::MLFlow, run_id::String)::Bool
    mlfpost(instance, "runs/delete"; run_id=run_id)
    return true
end
deleterun(instance::MLFlow, run::Run)::Bool =
    deleterun(instance, run.info.run_id)

"""
    restorerun(instance::MLFlow, run_id::String)
    restorerun(instance::MLFlow, run::Run)

Restore a deleted run.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the run to restore.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function restorerun(instance::MLFlow, run_id::String)::Bool
    mlfpost(instance, "runs/restore"; run_id=run_id)
    return true
end
restorerun(instance::MLFlow, run::Run)::Bool =
    restorerun(instance, run.info.run_id)

"""
    getrun(instance::MLFlow, run_id::String)

Get metadata, metrics, params, and tags for a run. In the case where multiple
metrics with the same key are logged for a run, return only the value with the
latest timestamp. If there are multiple values with the latest timestamp,
return the maximum of these values.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the run to fetch.

# Returns
An instance of type [`Run`](@ref).
"""
function getrun(instance::MLFlow, run_id::String)::Run
    result = mlfget(instance, "runs/get"; run_id=run_id)
    return result["run"] |> Run
end

"""
    setruntag(instance::MLFlow, run_id::String, key::String, value::String)
    setruntag(instance::MLFlow, run::Run, key::String, value::String)

Set a tag on a run. Tags are run metadata that can be updated during a run and
after a run completes.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the run under which to log the tag.
- `key`: Name of the tag.
- `value`: String value of the tag being logged.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function setruntag(instanceL::MLFlow, run_id::String, key::String,
    value::String):Bool
    mlfpost(instanceL, "runs/set-tag"; run_id=run_id, key=key, value=value)
    return true
end
setruntag(instance::MLFlow, run::Run, key::String, value::String)::Bool =
    setruntag(instance, run.info.run_id, key, value)
