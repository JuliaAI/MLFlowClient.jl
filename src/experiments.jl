"""
    createexperiment(mlf::MLFlow; name=missing, artifact_location=missing, tags=missing)

Creates an MLFlow experiment.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `name`: experiment name. If not specified, MLFlow sets it.
- `artifact_location`: directory where artifacts of this experiment will be stored. If not specified, MLFlow uses its default configuration.
- `tags`: a Dictionary of key-values which tag the experiment.

# Returns
An object of type [`MLFlowExperiment`](@ref).

"""
function createexperiment(mlf::MLFlow; name=missing, artifact_location=missing, tags=missing)
    endpoint = "experiments/create"

    if ismissing(name)
        name = string(UUIDs.uuid4())
    end

    try
        result = mlfpost(mlf, endpoint; name=name, artifact_location=artifact_location, tags=tags)
        experiment_id = parse(Int, result["experiment_id"])
        return getexperiment(mlf, experiment_id)
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 400
            error_code = JSON.parse(String(e.response.body))["error_code"]
            if error_code == MLFLOW_ERROR_CODES.RESOURCE_ALREADY_EXISTS
                error("Experiment with name \"$name\" already exists")
            end
        end
        throw(e)
    end
end

"""
    getexperiment(mlf::MLFlow, experiment_id::Integer)

Retrieves an MLFlow experiment by id.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment_id`: Experiment identifier.

# Returns
An instance of type [`MLFlowExperiment`](@ref)

"""
function getexperiment(mlf::MLFlow, experiment_id::Integer)
    try
        endpoint = "experiments/get"
        arguments = (:experiment_id => experiment_id,)
        result = mlfget(mlf, endpoint; arguments...)["experiment"]
        return MLFlowExperiment(result)
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 404
            return missing
        end
        throw(e)
    end
end
"""
    getexperiment(mlf::MLFlow, experiment_name::String)

Retrieves an MLFlow experiment by name.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment_name`: Experiment name.

# Returns
An instance of type [`MLFlowExperiment`](@ref)

"""
function getexperiment(mlf::MLFlow, experiment_name::String)
    try
        endpoint = "experiments/get-by-name"
        arguments = (:experiment_name => experiment_name,)
        result = mlfget(mlf, endpoint; arguments...)["experiment"]
        return MLFlowExperiment(result)
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 404
            return missing
        end
        throw(e)
    end
end

"""
    getorcreateexperiment(mlf::MLFlow, experiment_name::String; artifact_location=missing, tags=missing)

Gets an experiment if one alrady exists, or creates a new one.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment_name`: Experiment name.
- `artifact_location`: directory where artifacts of this experiment will be stored. If not specified, MLFlow uses its default configuration.
- `tags`: a Dictionary of key-values which tag the experiment.

# Returns
An instance of type [`MLFlowExperiment`](@ref)

"""
function getorcreateexperiment(mlf::MLFlow, experiment_name::String; artifact_location=missing, tags=missing)
    experiment = getexperiment(mlf, experiment_name)

    if ismissing(experiment)
        return createexperiment(mlf, name=experiment_name, artifact_location=artifact_location, tags=tags)
    end
    return experiment
end

"""
    deleteexperiment(mlf::MLFlow, experiment_id::Integer)

Deletes an MLFlow experiment.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment_id`: experiment identifier.

# Returns

`true` if successful. Otherwise, raises exception.
"""
function deleteexperiment(mlf::MLFlow, experiment_id::Integer)
    endpoint = "experiments/delete"
    try
        mlfpost(mlf, endpoint; experiment_id=experiment_id)
        return true
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 404
            # experiment already deleted
            return true
        end
        throw(e)
    end
end

"""
    deleteexperiment(mlf::MLFlow, experiment::MLFlowExperiment)

Deletes an MLFlow experiment.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment`: an object of type [`MLFlowExperiment`](@ref)

Dispatches to `deleteexperiment(mlf::MLFlow, experiment_id::Integer)`.

"""
deleteexperiment(mlf::MLFlow, experiment::MLFlowExperiment) =
    deleteexperiment(mlf, experiment.experiment_id)

"""
    restoreexperiment(mlf::MLFlow, experiment_id::Integer)

Restores a deleted MLFlow experiment.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment_id`: experiment identifier.

# Returns

`true` if successful. Otherwise, raises exception.
"""
function restoreexperiment(mlf::MLFlow, experiment_id::Integer)
    endpoint = "experiments/restore"
    try
        mlfpost(mlf, endpoint; experiment_id=experiment_id)
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

restoreexperiment(mlf::MLFlow, experiment::MLFlowExperiment) =
    restoreexperiment(mlf, experiment.experiment_id)

"""
    searchexperiments(mlf::MLFlow)

Searches for experiments in an MLFlow instance.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.

# Keywords
- `filter::String`: filter as defined in [MLFlow documentation](https://mlflow.org/docs/latest/rest-api.html#search-experiments)
- `filter_attributes::AbstractDict{K,V}`: if provided, `filter` is automatically generated based on `filter_attributes` using [`generatefilterfromattributes`](@ref). One can only provide either `filter` or `filter_attributes`, but not both.
- `run_view_type::String`: one of `ACTIVE_ONLY`, `DELETED_ONLY`, or `ALL`.
- `max_results::Integer`: 50,000 by default.
- `order_by::String`: as defined in [MLFlow documentation](https://mlflow.org/docs/latest/rest-api.html#search-experiments)
- `page_token::String`: paging functionality, handled automatically. Not meant to be passed by the user.

# Returns
- vector of [`MLFlowExperiment`](@ref) experiments that were found in the MLFlow instance

"""
function searchexperiments(mlf::MLFlow;
    filter::String="",
    filter_attributes::AbstractDict{K,V}=Dict{}(),
    run_view_type::String="ACTIVE_ONLY",
    max_results::Int64=50000,
    order_by::AbstractVector{<:String}=["attribute.last_update_time"],
    page_token::String=""
) where {K,V}
    endpoint = "experiments/search"
    run_view_type ∈ ["ACTIVE_ONLY", "DELETED_ONLY", "ALL"] || error("Unsupported run_view_type = $run_view_type")

    if length(filter_attributes) > 0 && length(filter) > 0
        error("Cannot specify both filter and filter_attributes")
    end

    if length(filter_attributes) > 0
        filter = generatefilterfromattributes(filter_attributes)
    end

    kwargs = (; filter, run_view_type, max_results, order_by)
    if !isempty(page_token)
        kwargs = (; kwargs..., page_token=page_token)
    end

    result = mlfpost(mlf, endpoint; kwargs...)
    haskey(result, "experiments") || return MLFlowExperiment[]

    experiments = map(x -> MLFlowExperiment(x), result["experiments"])

    if haskey(result, "next_page_token") && !isempty(result["next_page_token"])
        kwargs = (; filter, run_view_type, max_results, order_by, page_token=result["next_page_token"])
        next_experiments = searchexperiments(mlf; kwargs...)
        return vcat(experiments, next_experiments)
    end

    experiments
end
