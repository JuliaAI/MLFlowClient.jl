"""
    Metric <: LoggingData

Metric associated with a run, represented as a key-value pair.

# Fields
- `key::String`: Key identifying this metric.
- `value::Float64`: Value associated with this metric.
- `timestamp::Int64`: The timestamp at which this metric was recorded.
- `step::Union{Int64, Nothing}`: Step at which to log the metric.
"""
struct Metric <: LoggingData
    key::String
    value::Float64
    timestamp::Int64
    step::Union{Int64, Nothing}
end
Metric(data::Dict{String, Any}) = Metric(data["key"], data["value"], data["timestamp"],
    data["step"])
Base.show(io::IO, t::Metric) = show(io, ShowCase(t, new_lines=true))

"""
    Param <: LoggingData

Param associated with a run.

# Fields
- `key::String`: Key identifying this param.
- `value::String`: Value associated with this param.
"""
struct Param <: LoggingData
    key::String
    value::String
end
Param(data::Dict{String, Any}) = Param(data["key"], data["value"])
Base.show(io::IO, t::Param) = show(io, ShowCase(t, new_lines=true))

"""
    RunInfo

Metadata of a single run.

# Fields
- `run_id::String`: Unique identifier for the run.
- `run_name::String`: The name of the run.
- `experiment_id::String`: The experiment ID.
- `status::RunStatus`: Current status of the run.
- `start_time::Int64`: Unix timestamp of when the run started in milliseconds.
- `end_time::Int64`: Unix timestamp of when the run ended in milliseconds.
- `artifact_uri::String`: URI of the directory where artifacts should be uploaded. This can
    be a local path (starting with “/”), or a distributed file system (DFS) path,
    like s3://bucket/directory or dbfs:/my/directory. If not set, the local ./mlruns
    directory is chosen.
- `lifecycle_stage::String`: Current life cycle stage of the experiment: "active" or
    "deleted".
"""
struct RunInfo
    run_id::String
    run_name::String
    experiment_id::String
    status::RunStatus
    start_time::Int64
    end_time::Union{Int64, Nothing}
    artifact_uri::String
    lifecycle_stage::String
end
RunInfo(data::Dict{String, Any}) = RunInfo(data["run_id"], data["run_name"],
    data["experiment_id"], RunStatus(data["status"]), data["start_time"],
    get(data, "end_time", nothing), data["artifact_uri"], data["lifecycle_stage"])
Base.show(io::IO, t::RunInfo) = show(io, ShowCase(t, new_lines=true))

"""
    RunInputs

Run data (metrics, params, and tags).

# Fields
- `metrics::Array{Metric}`: Run metrics.
- `params::Array{Param}`: Run parameters.
- `tags::Array{Tag}`: Additional metadata key-value pairs.
"""
struct RunData
    metrics::Array{Metric}
    params::Array{Param}
    tags::Array{Tag}
end
RunData(data::Dict{String, Any}) = RunData(
    [Metric(metric) for metric in get(data, "metrics", [])],
    [Param(param) for param in get(data, "params", [])],
    [Tag(tag) for tag in get(data, "tags", [])])
Base.show(io::IO, t::RunData) = show(io, ShowCase(t, new_lines=true))

"""
    RunInputs

Run inputs.

# Fields
- `dataset_inputs::Array{DatasetInput}`: Dataset inputs to the Run.
"""
struct RunInputs
    dataset_inputs::Array{DatasetInput}
end
RunInputs(data::Dict{String, Any}) = RunInputs(
    [DatasetInput(dataset_input) for dataset_input in get(data, "dataset_inputs", [])])
Base.show(io::IO, t::RunInputs) = show(io, ShowCase(t, new_lines=true))

"""
    Run

A single run.

# Fields
- `info::RunInfo`: Metadata of the run.
- `data::RunData`: Run data (metrics, params, and tags).
- `inputs::RunInputs`: Run inputs.
"""
struct Run
    info::RunInfo
    data::RunData
    inputs::RunInputs
end
Run(data::Dict{String, Any}) = Run(RunInfo(data["info"]), RunData(data["data"]),
    RunInputs(data["inputs"]))
Base.show(io::IO, t::Run) = show(io, ShowCase(t, new_lines=true))
