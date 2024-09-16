"""
    createexperiment(instance::MLFlow, name::String;
        artifact_location::String="",
        tags::Union{Dict{<:Any}, Array{<:Any}}=[])

Create an experiment with a name. Returns the newly created experiment.
Validates that another experiment with the same name does not already exist and
fails if another experiment with the same name already exists.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: Experiment name. This field is required.
- `artifact_location`: Location where all artifacts for the experiment
are stored. If not provided, the remote server will select an appropriate
default.
- `tags`: A collection of tags to set on the experiment.

# Returns
The ID of the newly created experiment.
"""
function createexperiment(instance::MLFlow, name::String;
    artifact_location::Union{String, Missing}=missing,
    tags::Union{Dict{<:Any}, Array{<:Any}}=[])::String
    tags = tags |> parsetags

    try
        result = mlfpost(instance, "experiments/create"; name=name,
            artifact_location=artifact_location, tags=tags)
        return result["experiment_id"]
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 400
            error_code = (e.response.body |> String |> JSON.parse)["error_code"]
            if error_code == MLFLOW_ERROR_CODES.RESOURCE_ALREADY_EXISTS
                error("Experiment with name \"$name\" already exists")
            end
        end
        throw(e)
    end
end

"""
    getexperiment(instance::MLFlow, experiment_id::String)
    getexperiment(instance::MLFlow, experiment_id::Integer)

Get metadata for an experiment. This method works on deleted experiments.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: ID of the associated experiment.

# Returns
An instance of type [`Experiment`](@ref).
"""
function getexperiment(instance::MLFlow, experiment_id::String)
    try
        arguments = (:experiment_id => experiment_id,)
        result = mlfget(instance, "experiments/get"; arguments...)
        return result["experiment"] |> Experiment
    catch e
        throw(e)
    end
end
getexperiment(instance::MLFlow, experiment_id::Integer) =
    getexperiment(instance, string(experiment_id))

"""
    getexperimentbyname(instance::MLFlow, experiment_name::String)

Get metadata for an experiment.

This endpoint will return deleted experiments, but prefers the active
experiment if an active and deleted experiment share the same name. If multiple
deleted experiments share the same name, the API will return one of them.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_name`: Name of the associated experiment.

# Returns
An instance of type [`Experiment`](@ref).
"""
function getexperimentbyname(instance::MLFlow, experiment_name::String)
    try
        arguments = (:experiment_name => experiment_name,)
        result = mlfget(instance, "experiments/get-by-name"; arguments...)
        return result["experiment"] |> Experiment
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 404
            return missing
        end
        throw(e)
    end
end

"""
    deleteexperiment(instance::MLFlow, experiment_id::String)
    deleteexperiment(instance::MLFlow, experiment_id::Integer)
    deleteexperiment(instance::MLFlow, experiment::Experiment)

Mark an experiment and associated metadata, runs, metrics, params, and tags for
deletion. If the experiment uses FileStore, artifacts associated with
experiment are also deleted.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: ID of the associated experiment.

# Returns

`true` if successful. Otherwise, raises exception.
"""
function deleteexperiment(instance::MLFlow, experiment_id::String)
    endpoint = "experiments/delete"
    try
        mlfpost(instance, endpoint; experiment_id=experiment_id)
        return true
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 404
            # experiment already deleted
            return true
        end
        throw(e)
    end
end
deleteexperiment(instance::MLFlow, experiment_id::Integer) =
    deleteexperiment(instance, string(experiment_id))
deleteexperiment(instance::MLFlow, experiment::Experiment) =
    deleteexperiment(instance, experiment.experiment_id)

"""
    restoreexperiment(instance::MLFlow, experiment_id::String)
    restoreexperiment(instance::MLFlow, experiment_id::Integer)
    restoreexperiment(instance::MLFlow, experiment::Experiment)

Restore an experiment marked for deletion. This also restores associated
metadata, runs, metrics, params, and tags. If experiment uses FileStore,
underlying artifacts associated with experiment are also restored.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: ID of the associated experiment.

# Returns

`true` if successful. Otherwise, raises exception.
"""
function restoreexperiment(instance::MLFlow, experiment_id::String)
    endpoint = "experiments/restore"
    try
        mlfpost(instance, endpoint; experiment_id=experiment_id)
        return true
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 404
            error_code = JSON.parse(String(e.response.body))["error_code"]
            if error_code == MLFLOW_ERROR_CODES.RESOURCE_DOES_NOT_EXIST
                error("Experiment with id \"$experiment_id\" does not exist")
            end
        end
        throw(e)
    end
end
restoreexperiment(instance::MLFlow, experiment_id::Integer) =
    restoreexperiment(instance, string(experiment_id))
restoreexperiment(instance::MLFlow, experiment::Experiment) =
    restoreexperiment(instance, experiment.experiment_id)

"""
    updateexperiment(instance::MLFlow, experiment_id::String, new_name::String)
    updateexperiment(instance::MLFlow, experiment_id::Integer,
        new_name::String)
    updateexperiment(instance::MLFlow, experiment::Experiment,
        new_name::String)

Update experiment metadata.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: ID of the associated experiment.
- `new_name`: If provided, the experiment’s name is changed to the new name.
The new name must be unique.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function updateexperiment(instance::MLFlow, experiment_id::String,
    new_name::String)
    endpoint = "experiments/update"
    try
        mlfpost(instance, endpoint; experiment_id=experiment_id, new_name=new_name)
        return true
    catch e
        throw(e)
    end
end
updateexperiment(instance::MLFlow, experiment_id::Integer, new_name::String) =
    updateexperiment(instance, string(experiment_id), new_name)
updateexperiment(instance::MLFlow, experiment::Experiment, new_name::String) =
    updateexperiment(instance, experiment.experiment_id, new_name::String)

"""
    searchexperiments(instance::MLFlow; max_results::Integer=20000,
        page_token::String="", filter::String="", order_by::Array{String}=[],
        view_type::ViewType=ACTIVE_ONLY)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `max_results`: Maximum number of experiments desired.
- `page_token`: Token indicating the page of experiments to fetch.
- `filter`: A filter expression over experiment attributes and tags that allows
returning a subset of experiments. See [MLFlow documentation](https://mlflow.org/docs/latest/rest-api.html#search-experiments).
- `order_by`: List of columns for ordering search results, which can include
experiment name and id with an optional “DESC” or “ASC” annotation, where “ASC”
is the default.
- `view_type`: Qualifier for type of experiments to be returned. If
unspecified, return only active experiments.

# Returns
- vector of [`MLFlowExperiment`](@ref) experiments that were found in the MLFlow instance
"""
function searchexperiments(instance::MLFlow; max_results::Integer=20000,
    page_token::String="", filter::String="", order_by::Array{String}=String[],
    view_type::ViewType=ACTIVE_ONLY)::Tuple{Array{Experiment}, Union{String, Nothing}}
    endpoint = "experiments/search"
    parameters = (; max_results, page_token, filter,
        :view_type => view_type |> Integer)

    if order_by |> !isempty
        parameters = (; order_by, parameters...)
    end

    try
        result = mlfget(instance, endpoint; parameters...)

        experiments = result["experiments"] |> (x -> [Experiment(y) for y in x])
        next_page_token = get(result, "next_page_token", nothing)

        return experiments, next_page_token
    catch e
        throw(e)
    end
end
