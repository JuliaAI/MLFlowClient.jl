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
    tags::MLFlowUpsertData{Tag}=Tag[])
    try
        result = mlfpost(instance, "runs/create"; experiment_id=experiment_id,
            run_name=run_name, start_time=start_time, tags=(tags |> parse))
        return result["run"] |> Run
    catch e
        throw(e)
    end
end
createrun(instance::MLFlow, experiment_id::Integer;
    run_name::Union{String, Missing}=missing,
    start_time::Union{Integer, Missing}=missing,
    tags::MLFlowUpsertData{Tag}=Tag[]) =
    createrun(instance, string(experiment_id); run_name=run_name,
        start_time=start_time, tags=tags)
createrun(instance::MLFlow, experiment::Experiment;
    run_name::Union{String, Missing}=missing,
    start_time::Union{Integer, Missing}=missing,
    tags::MLFlowUpsertData{Tag}=Tag[]) =
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
function deleterun(instance::MLFlow, run_id::String)
    endpoint = "runs/delete"
    try
        mlfpost(instance, endpoint; run_id=run_id)
        return true
    catch e
        throw(e)
    end
end
deleterun(instance::MLFlow, run::Run) = deleterun(instance, run.info.run_id)

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
function restorerun(instance::MLFlow, run_id::String)
    endpoint = "runs/restore"
    try
        mlfpost(instance, endpoint; run_id=run_id)
        return true
    catch e
        throw(e)
    end
end
restorerun(instance::MLFlow, run::Run) = restorerun(instance, run.info.run_id)

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
function getrun(instance::MLFlow, run_id::String)
    try
        arguments = (:run_id => run_id,)
        result = mlfget(instance, "runs/get"; arguments...)
        return result["run"] |> Run
    catch e
        throw(e)
    end
end
