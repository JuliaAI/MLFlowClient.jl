"""
    createexperiment(instance::MLFlow; name=missing, artifact_location=missing,
        tags=[])

Create an experiment with a name. Returns the newly created experiment.
Validates that another experiment with the same name does not already exist and
fails if another experiment with the same name already exists.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name::String`: Experiment name. This field is required.
- `artifact_location::String`: Location where all artifacts for the experiment
are stored. If not provided, the remote server will select an appropriate
default.
- `tags`: A collection of tags to set on the experiment.

# Returns
An object of type [`Experiment`](@ref).
"""
function createexperiment(instance::MLFlow; name::String=missing,
    artifact_location::String=missing, tags::Array{Dict{Any, Any}}=[])
    if ismissing(name)
        name = string(UUIDs.uuid4())
    end

    try
        result = mlfpost(instance, "experiments/create"; name=name,
            artifact_location=artifact_location, tags=tags)
        return getexperiment(instance, result["experiment_id"])
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
createexperiment(instance::MLFlow; name::String=missing,
    artifact_location::String=missing, tags::Array{Pair{Any, Any}}=[]) =
    createexperiment(instance, name=name, artifact_location=artifact_location,
        tags=tags |> transform_pair_array_to_dict_array)
createexperiment(instance::MLFlow; name::String=missing,
    artifact_location::String=missing, tags::Dict{Any, Any}=[]) =
    createexperiment(instance, name=name, artifact_location=artifact_location,
        tags=tags |> transform_dict_to_dict_array)
createexperiment(instance::MLFlow; name::String=missing,
    artifact_location::String=missing, tags::Array{Tag}=[]) =
    createexperiment(instance, name=name, artifact_location=artifact_location,
        tags=tags |> transform_tag_array_to_dict_array)

"""
    getexperiment(instance::MLFlow, experiment_id::String)

Get metadata for an experiment. This method works on deleted experiments.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: ID of the associated experiment.

# Returns
An object of type [`Experiment`](@ref).
"""
function getexperiment(instance::MLFlow, experiment_id::String)
    try
        arguments = (:experiment_id => experiment_id,)
        result = mlfget(instance, "experiments/get"; arguments...)
        return Experiment(result["experiment"])
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError) && e.status == 404
            return missing
        end
        throw(e)
    end
end
getexperiment(instance::MLFlow, experiment_id::Integer) =
    getexperiment(instance, experiment_id)
