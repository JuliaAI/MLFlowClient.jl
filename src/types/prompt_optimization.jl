"""
    PromptOptimizationJobTag

Represents a tag for a prompt optimization job.

# Fields
- `key`: Tag key.
- `value`: Tag value.
"""
struct PromptOptimizationJobTag
    key::String
    value::String
end

function PromptOptimizationJobTag(data::AbstractDict)
    PromptOptimizationJobTag(
        get(data, "key", ""),
        get(data, "value", "")
    )
end

"""
    PromptOptimizationJobConfig

Configuration for a prompt optimization job.

# Fields
- `optimizer_type`: The optimizer type to use.
- `dataset_id`: ID of the EvaluationDataset containing training data.
- `scorers`: List of scorer names.
- `optimizer_config_json`: JSON-serialized optimizer-specific configuration.
"""
struct PromptOptimizationJobConfig
    optimizer_type::String
    dataset_id::String
    scorers::Array{String}
    optimizer_config_json::String
end

function PromptOptimizationJobConfig(data::AbstractDict)
    PromptOptimizationJobConfig(
        get(data, "optimizer_type", ""),
        get(data, "dataset_id", ""),
        get(data, "scorers", String[]),
        get(data, "optimizer_config_json", "")
    )
end

"""
    InitialEvalScoresEntry

Represents an initial evaluation scores entry.

# Fields
- `scorer_name`: Name of the scorer.
- `score`: Score value.
"""
struct InitialEvalScoresEntry
    scorer_name::String
    score::Float64
end

function InitialEvalScoresEntry(data::AbstractDict)
    InitialEvalScoresEntry(
        get(data, "scorer_name", ""),
        get(data, "score", 0.0)
    )
end

"""
    FinalEvalScoresEntry

Represents a final evaluation scores entry.

# Fields
- `scorer_name`: Name of the scorer.
- `score`: Score value.
"""
struct FinalEvalScoresEntry
    scorer_name::String
    score::Float64
end

function FinalEvalScoresEntry(data::AbstractDict)
    FinalEvalScoresEntry(
        get(data, "scorer_name", ""),
        get(data, "score", 0.0)
    )
end

"""
    JobStateInfo

Represents the state of a job.

# Fields
- `state`: Current state (PENDING, RUNNING, COMPLETED, FAILED, CANCELED).
- `message`: Optional error or status message.
"""
struct JobStateInfo
    state::String
    message::String
end

function JobStateInfo(data::AbstractDict)
    JobStateInfo(
        get(data, "state", ""),
        get(data, "message", "")
    )
end

"""
    PromptOptimizationJob

Represents a prompt optimization job entity.

# Fields
- `job_id`: Unique identifier for the optimization job.
- `run_id`: MLflow run ID where optimization metrics are stored.
- `state`: Current state of the job.
- `experiment_id`: ID of the MLflow experiment.
- `source_prompt_uri`: URI of the source prompt.
- `optimized_prompt_uri`: URI of the optimized prompt (only set if completed).
- `config`: Configuration for the optimization job.
- `creation_timestamp_ms`: Creation timestamp in milliseconds.
- `completion_timestamp_ms`: Completion timestamp in milliseconds.
- `tags`: Tags associated with the job.
- `initial_eval_scores`: Initial evaluation scores before optimization.
- `final_eval_scores`: Final evaluation scores after optimization.
"""
struct PromptOptimizationJob
    job_id::String
    run_id::String
    state::JobStateInfo
    experiment_id::String
    source_prompt_uri::String
    optimized_prompt_uri::String
    config::PromptOptimizationJobConfig
    creation_timestamp_ms::Int64
    completion_timestamp_ms::Int64
    tags::Array{PromptOptimizationJobTag}
    initial_eval_scores::Array{InitialEvalScoresEntry}
    final_eval_scores::Array{FinalEvalScoresEntry}
end

function PromptOptimizationJob(data::AbstractDict)
    PromptOptimizationJob(
        get(data, "job_id", ""),
        get(data, "run_id", ""),
        get(data, "state", Dict{String,Any}()) |> JobStateInfo,
        get(data, "experiment_id", ""),
        get(data, "source_prompt_uri", ""),
        get(data, "optimized_prompt_uri", ""),
        get(data, "config", Dict{String,Any}()) |> PromptOptimizationJobConfig,
        get(data, "creation_timestamp_ms", 0),
        get(data, "completion_timestamp_ms", 0),
        get(data, "tags", []) .|> PromptOptimizationJobTag,
        get(data, "initial_eval_scores", []) .|> InitialEvalScoresEntry,
        get(data, "final_eval_scores", []) .|> FinalEvalScoresEntry
    )
end
