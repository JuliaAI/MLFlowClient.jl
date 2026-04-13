"""
    registerscorer(instance::MLFlow, experiment_id::String, name::String, serialized_scorer::String)

Register a scorer for an experiment.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: The experiment ID.
- `name`: The scorer name.
- `serialized_scorer`: The serialized scorer string (JSON).

# Returns
A dictionary containing:
- `version`: The new version number for the scorer.
- `scorer_id`: The unique identifier for the scorer.
- `experiment_id`: The experiment ID.
- `name`: The scorer name.
- `serialized_scorer`: The serialized scorer string.
- `creation_time`: The creation time in milliseconds since epoch.
"""
function registerscorer(instance::MLFlow, experiment_id::String, name::String, serialized_scorer::String)::Dict{String,Any}
    result = mlfpost_v3(instance, "scorers/register";
        experiment_id=experiment_id, name=name, serialized_scorer=serialized_scorer)
    return result
end

"""
    listscorers(instance::MLFlow, experiment_id::String)

List all scorers for an experiment.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: The experiment ID.

# Returns
Vector of [`Scorer`](@ref) entities (latest version for each scorer name).
"""
function listscorers(instance::MLFlow, experiment_id::String)::Array{Scorer}
    result = mlfget_v3(instance, "scorers/list"; experiment_id=experiment_id)
    return get(result, "scorers", []) |> (x -> [Scorer(y) for y in x])
end

"""
    listscorerversions(instance::MLFlow, experiment_id::String, name::String)

List all versions of a specific scorer for an experiment.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: The experiment ID.
- `name`: The scorer name.

# Returns
Vector of [`Scorer`](@ref) entities for all versions of the scorer.
"""
function listscorerversions(instance::MLFlow, experiment_id::String, name::String)::Array{Scorer}
    result = mlfget_v3(instance, "scorers/versions"; experiment_id=experiment_id, name=name)
    return get(result, "scorers", []) |> (x -> [Scorer(y) for y in x])
end

"""
    getscorer(instance::MLFlow, experiment_id::String, name::String; version::Union{Int32, Missing}=missing)

Get a specific scorer for an experiment.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: The experiment ID.
- `name`: The scorer name.
- `version`: The scorer version. If not specified, returns the scorer with maximum version.

# Returns
The [`Scorer`](@ref) entity.
"""
function getscorer(instance::MLFlow, experiment_id::String, name::String; version::Union{Int64,Missing}=missing)::Scorer
    parameters = Dict{Symbol,Any}(:experiment_id => experiment_id, :name => name)
    if !ismissing(version)
        parameters[:version] = version
    end
    result = mlfget_v3(instance, "scorers/get"; parameters...)
    return result["scorer"] |> Scorer
end

"""
    deletescorer(instance::MLFlow, experiment_id::String, name::String; version::Union{Int32, Missing}=missing)

Delete a scorer for an experiment.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: The experiment ID.
- `name`: The scorer name.
- `version`: The scorer version to delete. If not specified, deletes all versions.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletescorer(instance::MLFlow, experiment_id::String, name::String; version::Union{Int64,Missing}=missing)::Bool
    parameters = Dict{Symbol,Any}(:experiment_id => experiment_id, :name => name)
    if !ismissing(version)
        parameters[:version] = version
    end
    mlfdelete_v3(instance, "scorers/delete"; parameters...)
    return true
end
