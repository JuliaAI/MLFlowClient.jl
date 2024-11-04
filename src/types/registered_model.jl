"""
    RegisteredModelAlias

Alias for a registered model.

# Fields
- `alias::String`: The name of the alias.
- `version::String`: The model version number that the alias points to.
"""
struct RegisteredModelAlias
    alias::String
    version::String
end
RegisteredModelAlias(data::Dict{String, Any}) = RegisteredModelAlias(data["alias"],
    data["version"])
Base.show(io::IO, t::RegisteredModelAlias) = show(io, ShowCase(t, new_lines=true))

"""
    RegisteredModel

# Fields
- `name::String`: Unique name for the model.
- `creation_timestamp::Int64`: Timestamp recorded when this RegisteredModel was created.
- `last_updated_timestamp::Int64`: Timestamp recorded when metadata for this
    RegisteredModel was last updated.
- `user_id::Union{String, Nothing}`: User that created this RegisteredModel.
- `description::Union{String, Nothing}`: Description of this RegisteredModel.
- `latest_versions::Array{ModelVersion}`: Collection of latest model versions for each
    stage. Only contains models with current READY status.
- `tags::Array{Tag}`: Additional metadata key-value pairs.
- `aliases::Array{RegisteredModelAlias}`: Aliases pointing to model versions associated
    with this RegisteredModel.
"""
struct RegisteredModel
    name::String
    creation_timestamp::Int64
    last_updated_timestamp::Int64
    user_id::Union{String, Nothing}
    description::Union{String, Nothing}
    latest_versions::Array{ModelVersion}
    tags::Array{Tag}
    aliases::Array{RegisteredModelAlias}
end
RegisteredModel(data::Dict{String, Any}) = RegisteredModel(data["name"],
    data["creation_timestamp"], data["last_updated_timestamp"],
    get(data, "user_id", nothing), get(data, "description", nothing),
    [ModelVersion(version) for version in get(data, "latest_versions", [])],
    [Tag(tag) for tag in get(data, "tags", [])],
    [RegisteredModelAlias(alias) for alias in get(data, "aliases", [])])
Base.show(io::IO, t::RegisteredModel) = show(io, ShowCase(t, new_lines=true))
