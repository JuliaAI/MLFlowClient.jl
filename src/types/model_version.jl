"""
    ModelVersion

# Fields
- `name::String`: Unique name of the model.
- `version::String`: Model’s version number.
- `creation_timestamp::Int64`: Timestamp recorded when this model_version was created.
- `last_updated_timestamp::Int64`: Timestamp recorded when metadata for this model_version
    was last updated.
- `user_id::String`: User that created this model_version.
- `current_stage::String`: Current stage for this model_version.
- `description::String`: Description of this model_version.
- `source::String`: URI indicating the location of the source model artifacts, used when
    creating model_version.
- `run_id::String`: MLflow run ID used when creating model_version, if source was generated
    by an experiment run stored in MLflow tracking server.
- `status::ModelVersionStatus`: Current status of model_version.
- `status_message::String`: Details on current status, if it is pending or failed.
- `tags::Array{Tag}`: Additional metadata key-value pairs.
- `run_link::String`: Direct link to the run that generated this version. This field is set
    at model version creation time only for model versions whose source run is from a
    tracking server that is different from the registry server.
- `aliases::Array{String}`: Aliases pointing to this model_version.
"""
struct ModelVersion
    name::String
    version::String
    creation_timestamp::Int64
    last_updated_timestamp::Int64
    user_id::String
    current_stage::String
    description::String
    source::String
    run_id::String
    status::ModelVersionStatus
    status_message::String
    tags::Array{Tag}
    run_link::String
    aliases::Array{String}
end
ModelVersion(data::Dict{String, Any}) = ModelVersion(data["name"], data["version"],
    data["creation_timestamp"], data["last_updated_timestamp"], data["user_id"],
    data["current_stage"], data["description"], data["source"], data["run_id"],
    ModelVersionStatus(data["status"]), data["status_message"],
    [Tag(tag) for tag in get(data, "tags", [])], data["run_link"],
    get(data, "aliases", []))
Base.show(io::IO, t::ModelVersion) = show(io, ShowCase(t, new_lines=true))
