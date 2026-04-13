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
ModelInput(data::AbstractDict{String}) = ModelInput(data["model_id"])
Base.show(io::IO, t::ModelInput) = show(io, ShowCase(t, new_lines=true))

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
ModelMetric(data::AbstractDict{String}) = ModelMetric(
    data["key"], data["value"], data["timestamp"], get(data, "step", nothing))
Base.show(io::IO, t::ModelMetric) = show(io, ShowCase(t, new_lines=true))

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
ModelOutput(data::AbstractDict{String}) = ModelOutput(data["model_id"], data["step"])
Base.show(io::IO, t::ModelOutput) = show(io, ShowCase(t, new_lines=true))

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
ModelParam(data::AbstractDict{String}) = ModelParam(data["name"], data["value"])
Base.show(io::IO, t::ModelParam) = show(io, ShowCase(t, new_lines=true))

"""
    ModelVersionDeploymentJobState

Deployment job state for a model version.

# Fields
- `job_id::String`: The job ID.
- `run_id::String`: The run ID.
- `job_state::State.StateEnum`: The state of the job.
- `run_state::DeploymentJobRunState.DeploymentJobRunStateEnum`: The state of the run.
- `current_task_name::String`: The current task name.
"""
struct ModelVersionDeploymentJobState
    job_id::String
    run_id::String
    job_state::State.StateEnum
    run_state::DeploymentJobRunState.DeploymentJobRunStateEnum
    current_task_name::String
end
ModelVersionDeploymentJobState(data::AbstractDict{String}) = ModelVersionDeploymentJobState(
    get(data, "job_id", ""),
    get(data, "run_id", ""),
    haskey(data, "job_state") ? State.parse(data["job_state"]) : State.NOT_SET_UP,
    haskey(data, "run_state") ? DeploymentJobRunState.parse(data["run_state"]) : DeploymentJobRunState.DEPLOYMENT_JOB_RUN_STATE_UNSPECIFIED,
    get(data, "current_task_name", ""))
Base.show(io::IO, t::ModelVersionDeploymentJobState) = show(io, ShowCase(t, new_lines=true))

"""
    ModelVersion

# Fields
- `name::String`: Unique name of the model.
- `version::String`: Model's version number.
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
- `run_link::Union{String, Nothing}`: Direct link to the run that generated this version.
- `aliases::Array{String}`: Aliases pointing to this model_version.
- `model_id::Union{String, Nothing}`: Optional `model_id` for [`ModelVersion`](@ref).
- `model_params::Array{ModelParam}`: Optional parameters for the model.
- `model_metrics::Array{ModelMetric}`: Optional metrics for the model.
- `deployment_job_state::Union{ModelVersionDeploymentJobState, Nothing}`: Deployment job state.
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
    run_link::Union{String,Nothing}
    aliases::Array{String}
    model_id::Union{String,Nothing}
    model_params::Array{ModelParam}
    model_metrics::Array{ModelMetric}
    deployment_job_state::Union{ModelVersionDeploymentJobState,Nothing}
end
ModelVersion(data::AbstractDict{String}) = ModelVersion(data["name"], data["version"],
    data["creation_timestamp"], data["last_updated_timestamp"],
    get(data, "user_id", nothing), data["current_stage"], data["description"],
    data["source"], data["run_id"], data["status"] |> ModelVersionStatus.parse,
    get(data, "status_message", nothing), [Tag(tag) for tag in get(data, "tags", [])],
    get(data, "run_link", nothing), get(data, "aliases", []),
    get(data, "model_id", nothing),
    [ModelParam(param) for param in get(data, "model_params", [])],
    [ModelMetric(metric) for metric in get(data, "model_metrics", [])],
    haskey(data, "deployment_job_state") && !isnothing(data["deployment_job_state"]) ?
        ModelVersionDeploymentJobState(data["deployment_job_state"]) : nothing)
Base.show(io::IO, t::ModelVersion) = show(io, ShowCase(t, new_lines=true))
