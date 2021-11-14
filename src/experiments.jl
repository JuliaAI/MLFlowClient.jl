"""
    createexperiment(mlf::MLFlow; name=missing, artifact_location=missing, tags=missing)

Creates an MLFlow experiment.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `name`: experiment name. If not specified, MLFlow sets it.
- `artifact_location`: directory where artifacts of this experiment will be stored. If not specified, MLFlow uses its default configuration.
- `tags`: a Dictionary of key-values which tag the experiment.

# Returns
Experiment identifier (integer).

"""
function createexperiment(mlf::MLFlow; name=missing, artifact_location=missing, tags=missing)
    endpoint = "experiments/create"
    if ismissing(name)
        name = string(UUIDs.uuid4())
    end
    result = mlfpost(mlf, endpoint; name=name, artifact_location=artifact_location, tags=tags)
    parse(Int, result["experiment_id"])
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
    deleteexperiment(mlf::MLFlow, experiment_id)

Deletes an MLFlow experiment.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment_id`: experiment identifier.
"""
function deleteexperiment(mlf::MLFlow, experiment_id)
    endpoint = "experiments/delete"
    mlfpost(mlf, endpoint; experiment_id=experiment_id)
end

"""
    listexperiments(mlf::MLFlow)

Returns a list of MLFlow experiments.

TODO: not yet entirely implemented
"""
function listexperiments(mlf::MLFlow)
    endpoint = "experiments/list"
    mlfget(mlf, endpoint)
end
