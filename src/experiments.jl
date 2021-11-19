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
    result = mlfpost(mlf, endpoint; name=name, artifact_location=artifact_location, tags=tags)
    experiment_id = parse(Int, result["experiment_id"])
    getexperiment(mlf, experiment_id)
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
        result = _getexperimentbyid(mlf, experiment_id)
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
        result = _getexperimentbyname(mlf, experiment_name)
        return MLFlowExperiment(result)
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 404
            return missing
        end
        throw(e)
    end
end
function _getexperimentbyid(mlf::MLFlow, experiment_id::Integer)
    endpoint = "experiments/get"
    arguments = (:experiment_id => experiment_id, )
    mlfget(mlf, endpoint; arguments...)["experiment"]
end
function _getexperimentbyname(mlf::MLFlow, experiment_name::String)
    endpoint = "experiments/get-by-name"
    arguments = (:experiment_name => experiment_name, )
    mlfget(mlf, endpoint; arguments...)["experiment"]
end

"""
    getorcreateexperiment(mlf::MLFlow, experiment_name::String)

Gets an experiment if one alrady exists, or creates a new one.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment_name`: Experiment name.

# Returns
An instance of type [`MLFlowExperiment`](@ref)

"""
function getorcreateexperiment(mlf::MLFlow, experiment_name::String)
    exp = getexperiment(mlf, experiment_name)
    if ismissing(exp)
        exp = createexperiment(mlf, name=experiment_name)
    end
    exp
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
        result = mlfpost(mlf, endpoint; experiment_id=experiment_id)
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 404
            # experiment already deleted
            return true
        end
        throw(e)
    end
    true
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
    listexperiments(mlf::MLFlow)

Returns a list of MLFlow experiments.

TODO: not yet entirely implemented
"""
function listexperiments(mlf::MLFlow)
    endpoint = "experiments/list"
    mlfget(mlf, endpoint)
end
