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
Base.show(io::IO, t::RegisteredModelAlias) = show(io, ShowCase(t, new_lines=true))

"""
    RegisteredModel

# Fields
- `name::String`: Unique name for the model.
- `creation_timestamp::Int64`: Timestamp recorded when this RegisteredModel was created.
- `last_updated_timestamp::Int64`: Timestamp recorded when metadata for this
    RegisteredModel was last updated.
- `user_id::String`: User that created this RegisteredModel.
- `description::String`: Description of this RegisteredModel.
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
    user_id::String
    description::String
    latest_versions::Array{ModelVersion}
    tags::Array{Tag}
    aliases::Array{RegisteredModelAlias}
end
Base.show(io::IO, t::RegisteredModel) = show(io, ShowCase(t, new_lines=true))
