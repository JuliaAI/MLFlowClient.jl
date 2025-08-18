"""
    ModelInput

Represents a logged model or [`RegisteredModel`](@ref) version input to a
[`Run`](@ref).

# Fields
- `model_id::String`: The unique identifier of the model.
"""
struct ModelInput
    model_id::String
end

"""
    ModelMetric

[`Metric`](@ref) associated with a model, represented as a key-value pair.

# Fields
- `key::String`: Key identifying this metric.
- `value::Float64`: Value associated with this metric.
- `timestamp::Int64`: The timestamp at which this metric was recorded.
- `step::Union{Int64, Nothing}`: Step at which to log the metric.
"""
struct ModelMetric
    key::String
    value::Float64
    timestamp::Int64
    step::Union{Int64,Nothing}
end

"""
    ModelOutput

Represents a logged model output of a [`Run`](@ref).

# Fields
- `model_id::String`: The unique identifier of the model.
- `step::Int64`: Step at which the model was produced.
"""
struct ModelOutput
    model_id::String
    step::Int64
end

"""
    ModelParam

Param for a model version.

# Fields
- `name::String`: Name of the param.
- `value::String`: Value of the param associated with the name
"""
struct ModelParam
    name::String
    value::String
end

"""
    ModelVersion

# Fields
- `name::String`: Unique name of the model.
- `version::String`: Model’s version number.
- `creation_timestamp::Int64`: Timestamp recorded when this model_version was created.
- `last_updated_timestamp::Int64`: Timestamp recorded when metadata for this model_version
    was last updated.
- `user_id::Union{String, Nothing}`: User that created this model_version.
- `current_stage::String`: Current stage for this model_version.
- `description::String`: Description of this model_version.
- `source::String`: URI indicating the location of the source model artifacts, used when
    creating model_version.
- `run_id::String`: MLflow run ID used when creating model_version, if source was generated
    by an experiment run stored in MLflow tracking server.
- `status::ModelVersionStatusEnum`: Current status of model_version.
- `status_message::String`: Details on current status, if it is pending or failed.
- `tags::Array{Tag}`: Additional metadata key-value pairs.
- `run_link::String`: Direct link to the run that generated this version. This field is set
    at model version creation time only for model versions whose source run is from a
    tracking server that is different from the registry server.
- `aliases::Array{String}`: Aliases pointing to this model_version.
- `model_id::String`: Optional `model_id` for [`ModelVersion`](@ref) that is used to link
    the [`RegisteredModel`](@ref) to the source logged model.
- `model_params::Array{ModelParam}`: Optional parameters for the model.
- `model_metrics::Array{ModelMetric}`: Optional metrics for the model.
- `deployment_job_state::ModelVersionDeploymentJobState`: Deployment job state for this
    [`ModelVersion`](@ref).
"""
struct ModelVersion
    name::String
    version::String
    creation_timestamp::Int64
    last_updated_timestamp::Int64
    user_id::Union{String,Nothing}
    current_stage::String
    description::String
    source::String
    run_id::String
    status::ModelVersionStatus.ModelVersionStatusEnum
    status_message::Union{String,Nothing}
    tags::Array{Tag}
    run_link::String
    aliases::Array{String}
end
ModelVersion(data::Dict{String,Any}) = ModelVersion(data["name"], data["version"],
    data["creation_timestamp"], data["last_updated_timestamp"],
    get(data, "user_id", nothing), data["current_stage"], data["description"],
    data["source"], data["run_id"], data["status"] |> ModelVersionStatus.parse,
    get(data, "status_message", nothing), [Tag(tag) for tag in get(data, "tags", [])],
    data["run_link"], get(data, "aliases", []))
Base.show(io::IO, t::ModelVersion) = show(io, ShowCase(t, new_lines=true))

struct ModelVersionDeploymentJobState
    job_id::String
    run_id::String
    job_state::State.StateEnum
    run_state::DeploymentJobRunState.DeploymentJobRunStateEnum
    current_task_name::String
end
