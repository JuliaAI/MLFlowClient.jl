"""
    createrun(instance::MLFlow, experiment_id::String;
        run_name::Union{String, Missing}=missing,
        start_time::Union{Int64, Missing}=missing,
        tags::Union{Dict{<:Any}, Array{<:Any}}=[])

Create a new run within an experiment. A run is usually a single execution of a machine
learning or data ETL pipeline.

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
    run_name::Union{String, Missing}=missing, start_time::Union{Int64, Missing}=missing,
    tags::MLFlowUpsertData{Tag}=Tag[])::Run
    result = mlfpost(instance, "runs/create"; experiment_id=experiment_id,
        run_name=run_name, start_time=start_time, tags=parse(Tag, tags))
    return result["run"] |> Run
end
createrun(instance::MLFlow, experiment_id::Integer;
    run_name::Union{String, Missing}=missing, start_time::Union{Integer, Missing}=missing,
    tags::MLFlowUpsertData{Tag}=Tag[])::Run =
    createrun(instance, string(experiment_id); run_name=run_name, start_time=start_time,
        tags=tags)
createrun(instance::MLFlow, experiment::Experiment;
    run_name::Union{String, Missing}=missing, start_time::Union{Integer, Missing}=missing,
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

Get metadata, metrics, params, and tags for a run. In the case where multiple metrics with
the same key are logged for a run, return only the value with the latest timestamp. If
there are multiple values with the latest timestamp, return the maximum of these values.

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
    setruntag(instance::MLFlow, run::Run, tag::Tag)

Set a tag on a run.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the run under which to log the tag.
- `key`: Name of the tag.
- `value`: String value of the tag being logged.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function setruntag(instance::MLFlow, run_id::String, key::String, value::String):Bool
    mlfpost(instance, "runs/set-tag"; run_id=run_id, key=key, value=value)
    return true
end
setruntag(instance::MLFlow, run::Run, key::String, value::String)::Bool =
    setruntag(instance, run.info.run_id, key, value)
setruntag(instance::MLFlow, run::Run, tag::Tag)::Bool =
    setruntag(instance, run.info.run_id, tag.key, tag.value)

"""
    deletetag(instance::MLFlow, run_id::String, key::String)
    deletetag(instance::MLFlow, run::Run, key::String)
    deletetag(instance::MLFlow, run::Run, tag::Tag)

Delete a tag on a run.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the run that the tag was logged under.
- `key`: Name of the tag.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deleteruntag(instance::MLFlow, run_id::String, key::String)::Bool
    mlfpost(instance, "runs/delete-tag"; run_id=run_id, key=key)
    return true
end
deleteruntag(instance::MLFlow, run::Run, key::String)::Bool =
    deleteruntag(instance, run.info.run_id, key)
deleteruntag(instance::MLFlow, run::Run, tag::Tag)::Bool =
    deleteruntag(instance, run.info.run_id, tag.key)

"""
    searchruns(instance::MLFlow; experiment_ids::Array{String}=String[], filter::String="",
        run_view_type::ViewType=ACTIVE_ONLY, max_results::Int=1000,
        order_by::Array{String}=String[], page_token::String="")

Search for runs that satisfy expressions. Search expressions can use Metric and Param keys.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_ids`: List of experiment IDs to search over.
- `filter`: A filter expression over params, metrics, and tags, that allows returning a
subset of runs. See [MLFlow documentation](https://mlflow.org/docs/latest/rest-api.html#search-runs).
- `run_view_type`: Whether to display only active, only deleted, or all runs. Defaults to
only active runs.
- `max_results`: Maximum number of runs desired.
- `order_by`: List of columns to be ordered by, including attributes, params, metrics, and
tags with an optional “DESC” or “ASC” annotation, where “ASC” is the default.
- `page_token`: Token indicating the page of runs to fetch.

# Returns
- Vector of [`Run`](@ref) that were found in the specified experiments.
- The next page token if there are more results.
"""
function searchruns(instance::MLFlow; experiment_ids::Array{String}=String[],
    filter::String="", run_view_type::ViewType=ACTIVE_ONLY, max_results::Int=1000,
    order_by::Array{String}=String[],
    page_token::String="")::Tuple{Array{Run}, Union{String, Nothing}}
    parameters = (; experiment_ids, filter, :run_view_type => run_view_type |> Integer,
        max_results, page_token)

    if order_by |> !isempty
        parameters = (; order_by, parameters...)
    end

    result = mlfpost(instance, "runs/search"; parameters...)

    runs = get(result, "runs", []) |> (x -> [Run(y) for y in x])
    next_page_token = get(result, "next_page_token", nothing)

    return runs, next_page_token
end

"""
    updaterun(instance::MLFlow, run_id::String; status::Union{RunStatus, Missing}=missing,
        end_time::Union{Int64, Missing}=missing, run_name::Union{String, Missing}=missing)
    updaterun(instance::MLFlow, run::Run; status::Union{RunStatus, Missing}=missing,
        end_time::Union{Int64, Missing}=missing, run_name::Union{String, Missing}=missing)

Update run metadata.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the run to update.
- `status`: Updated status of the run.
- `end_time`: Unix timestamp in milliseconds of when the run ended.
- `run_name`: Updated name of the run.

# Returns
- An instance of type [`RunInfo`](@ref) with the updated metadata.
"""
function updaterun(instance::MLFlow, run_id::String;
    status::Union{RunStatus, Missing}=missing, end_time::Union{Int64, Missing}=missing,
    run_name::Union{String, Missing})::RunInfo
    result = mlfpost(instance, "runs/update"; run_id=run_id, status=(status |> Integer),
        end_time=end_time, run_name=run_name)
    return result["run_info"] |> RunInfo
end
updaterun(instance::MLFlow, run::Run; status::Union{RunStatus, Missing}=missing,
    end_time::Union{Int64, Missing}=missing, run_name::Union{String, Missing})::RunInfo =
    updaterun(instance, run.info.run_id; status=status, end_time=end_time,
        run_name=run_name)
