"""
    UnityCatalog

Represents a Databricks Unity Catalog location with a table prefix.

# Fields
- `catalog_name::String`: The name of the Unity Catalog catalog.
- `schema_name::String`: The name of the Unity Catalog schema.
- `table_prefix::String`: The prefix for tables in this location.
"""
struct UnityCatalog
    catalog_name::String
    schema_name::String
    table_prefix::String
    _otel_spans_table_name::Union{String,Nothing}
    _otel_logs_table_name::Union{String,Nothing}
    _annotations_table_name::Union{String,Nothing}
end
function UnityCatalog(py_trace::Py)::UnityCatalog
    return UnityCatalog(
        get_py_attr(py_trace, :catalog_name, String),
        get_py_attr(py_trace, :schema_name, String),
        get_py_attr(py_trace, :table_prefix, String),
        get_py_attr(py_trace, :_otel_spans_table_name, String),
        get_py_attr(py_trace, :_otel_logs_table_name, String),
        get_py_attr(py_trace, :_annotations_table_name, String),
    )
end

"""
    Experiment

Represents an MLflow experiment.

# Fields
- `experiment_id::String`: ID of the experiment.
- `name::String`: Name of the experiment.
- `artifact_location::String`: String corresponding to the root artifact URI for the experiment.
- `lifecycle_stage::String`: Lifecycle stage of the experiment. Can either be ‘active’ or ‘deleted’.
- `tags::Union{Dict{String,String},Nothing}`: Tags that have been set on the experiment.
- `creation_time::Union{Int64,Nothing}`.
- `last_update_time::Union{Int64,Nothing}`.
- `workspace::Union{String,Nothing}`: Workspace that owns the experiment, if known.
- `trace_location::Union{UnityCatalog,Nothing}`: Trace storage location, if configured.
"""
struct Experiment
    experiment_id::String
    name::String
    artifact_location::String
    lifecycle_stage::String
    tags::Union{Dict{String,String},Nothing}
    creation_time::Union{Int64,Nothing}
    last_update_time::Union{Int64,Nothing}
    workspace::Union{String,Nothing}
    trace_location::Union{UnityCatalog,Nothing}
end
function Experiment(py_exp::Py)::Experiment
    py_trace = get_py_attr(py_exp, :trace_location, Py)
    julia_trace = (py_trace |> isnothing) ? nothing : (py_trace |> UnityCatalog)

    return Experiment(
        get_py_attr(py_exp, :experiment_id, String),
        get_py_attr(py_exp, :name, String),
        get_py_attr(py_exp, :artifact_location, String),
        get_py_attr(py_exp, :lifecycle_stage, String),
        get_py_attr(py_exp, :tags, Dict{String,String}),
        get_py_attr(py_exp, :creation_time, Int64),
        get_py_attr(py_exp, :last_update_time, Int64),
        get_py_attr(py_exp, :workspace, String),
        julia_trace,
    )
end

"""
    RunInfo

Metadata about a run.

# Fields
- `run_id::String`: Containing the run ID.
- `experiment_id::String`: ID of the experiment for the current run.
- `user_id::String`: ID of the user who initiated this run.
- `status::RunStatus`: One of the values in [`RunStatus`](@ref) describing the status of the run.
- `start_time::Int64`: Start time of the run, in number of milliseconds since the UNIX epoch.
- `end_time::Int64`: End time of the run, in number of milliseconds since the UNIX epoch.
- `lifecycle_stage::LifecycleStage`: One of the values in [`LifecycleStage`](@ref) describing the lifecycle stage of the run.
- `artifact_uri::Union{String,Nothing}`: Root artifact URI of the run.
- `run_name::Union{String,Nothing}`: Containing the run name.
"""
struct RunInfo
    run_id::String
    experiment_id::String
    user_id::String
    status::RunStatus
    start_time::Int64
    end_time::Union{Int64,Nothing}
    lifecycle_stage::LifecycleStage
    artifact_uri::Union{String,Nothing}
    run_name::Union{String,Nothing}
end
function RunInfo(py_info::Py)::RunInfo
    status_str = get_py_attr(py_info, :status, String)
    lifecycle_str = get_py_attr(py_info, :lifecycle_stage, String)

    return RunInfo(
        get_py_attr(py_info, :run_id, String),
        get_py_attr(py_info, :experiment_id, String),
        get_py_attr(py_info, :user_id, String),
        parse(RunStatus, status_str),
        get_py_attr(py_info, :start_time, Int64),
        get_py_attr(py_info, :end_time, Int64),
        parse(LifecycleStage, lifecycle_str),
        get_py_attr(py_info, :artifact_uri, String),
        get_py_attr(py_info, :run_name, String),
    )
end

"""
    RunData

Run data (metrics and parameters).

# Fields
- `metrics::Dict{String,Float64}`: Dictionary of string key -> metric value for the current run. For each metric key, the metric value with the latest timestamp is returned. In case there are multiple values with the same latest timestamp, the maximum of these values is returned.
- `params::Dict{String,String}`: Dictionary of param key (string) -> param value for the current run.
- `tags::Dict{String,String}`: Dictionary of tag key (string) -> tag value for the current run.
"""
struct RunData
    metrics::Dict{String,Float64}
    params::Dict{String,String}
    tags::Dict{String,String}
end
function RunData(py_data::Py)::RunData
    metrics = get_py_attr(py_data, :metrics, Dict{String,Float64})
    params = get_py_attr(py_data, :params, Dict{String,String})
    tags = get_py_attr(py_data, :tags, Dict{String,String})

    return RunData(
        (metrics |> isnothing) ? Dict{String,Float64}() : metrics,
        (params |> isnothing) ? Dict{String,String}() : params,
        (tags |> isnothing) ? Dict{String,String}() : tags,
    )
end

"""
    Dataset

Dataset object associated with an experiment.

# Fields
- `name::String`: Name of the dataset.
- `digest::String`: Digest of the dataset.
- `source_type::String`: Source type of the dataset.
- `source::String`: Source of the dataset.
- `schema::Union{String,Nothing}`: Schema of the dataset.
- `profile::Union{String,Nothing}`: Profile of the dataset.
"""
struct Dataset
    name::String
    digest::String
    source_type::String
    source::String
    schema::Union{String,Nothing}
    profile::Union{String,Nothing}
end
function Dataset(py_ds::Py)::Dataset
    return Dataset(
        get_py_attr(py_ds, :name, String),
        get_py_attr(py_ds, :digest, String),
        get_py_attr(py_ds, :source_type, String),
        get_py_attr(py_ds, :source, String),
        get_py_attr(py_ds, :schema, String),
        get_py_attr(py_ds, :profile, String),
    )
end

"""
    InputTag

Input tag object associated with a dataset.

# Fields
- `key::String`: Name of the input tag.
- `value::String`: Value of the input tag.
"""
struct InputTag
    key::String
    value::String
end
function InputTag(py_tag::Py)::InputTag
    return InputTag(get_py_attr(py_tag, :key, String), get_py_attr(py_tag, :value, String))
end

"""
    DatasetInput

DatasetInput object associated with an experiment.

# Fields
- `dataset::Dataset`
- `tags::Vector{InputTag}`: Array of input tags.
"""
struct DatasetInput
    dataset::Dataset
    tags::Vector{InputTag}
end
function DatasetInput(py_di::Py)::DatasetInput
    py_ds = get_py_attr(py_di, :dataset, Py)
    dataset = py_ds |> Dataset

    py_tags = get_py_attr(py_di, :tags, Py)
    tags = (py_tags |> isnothing) ? InputTag[] : [(t |> InputTag) for t in py_tags]

    return DatasetInput(dataset, tags)
end

"""
    LoggedModelInput

ModelInput object associated with a Run.

# Fields
- `model_id::String`
"""
struct LoggedModelInput
    model_id::String
end
function LoggedModelInput(py_lmi::Py)::LoggedModelInput
    return LoggedModelInput(get_py_attr(py_lmi, :model_id, String))
end

"""
    RunInputs

RunInputs object.

# Fields
- `dataset_inputs::Vector{DatasetInput}`: Array of dataset inputs.
- `model_inputs::Union{Vector{LoggedModelInput},Nothing}`: Array of model inputs.
"""
struct RunInputs
    dataset_inputs::Vector{DatasetInput}
    model_inputs::Union{Vector{LoggedModelInput},Nothing}
end
function RunInputs(py_ri::Py)::RunInputs
    py_di = get_py_attr(py_ri, :dataset_inputs, Py)
    dataset_inputs = (py_di |> isnothing) ? DatasetInput[] : [(d |> DatasetInput) for d in py_di]

    py_mi = get_py_attr(py_ri, :model_inputs, Py)
    model_inputs = (py_mi |> isnothing) ? nothing : [(m |> LoggedModelInput) for m in py_mi]

    return RunInputs(dataset_inputs, model_inputs)
end

"""
    LoggedModelOutput

ModelOutput object associated with a Run.

# Fields
- `model_id::String`
- `step::String`: Step at which the model was logged.
"""
struct LoggedModelOutput
    model_id::String
    step::String
end
function LoggedModelOutput(py_lmo::Py)::LoggedModelOutput
    return LoggedModelOutput(
        get_py_attr(py_lmo, :model_id, String),
        get_py_attr(py_lmo, :step, String),
    )
end

"""
    RunOutputs

RunOutputs object.

# Fields
- `model_outputs::Vector{LoggedModelOutput}`: Array of model outputs.
"""
struct RunOutputs
    model_outputs::Vector{LoggedModelOutput}
end
function RunOutputs(py_ro::Py)::RunOutputs
    py_mo = get_py_attr(py_ro, :model_outputs, Py)
    model_outputs = (py_mo |> isnothing) ? LoggedModelOutput[] : [(m |> LoggedModelOutput) for m in py_mo]

    return RunOutputs(model_outputs)
end

"""
    Run

Run object.

# Fields
- `run_info::RunInfo`: The run metadata, such as the run id, start time, and status.
- `run_data::RunData`: The run data, including metrics, parameters, and tags.
- `run_inputs::Union{RunInputs,Nothing}`: The run inputs, including dataset inputs.
- `run_outputs::Union{RunOutputs,Nothing}`: The run outputs, including model outputs.
"""
struct Run
    run_info::RunInfo
    run_data::RunData
    run_inputs::Union{RunInputs,Nothing}
    run_outputs::Union{RunOutputs,Nothing}
end
function Run(py_run::Py)::Run
    run_info = RunInfo(get_py_attr(py_run, :info, Py))
    run_data = RunData(get_py_attr(py_run, :data, Py))

    py_inputs = get_py_attr(py_run, :inputs, Py)
    run_inputs = (py_inputs |> isnothing) ? nothing : (py_inputs |> RunInputs)

    py_outputs = get_py_attr(py_run, :outputs, Py)
    run_outputs = (py_outputs |> isnothing) ? nothing : (py_outputs |> RunOutputs)

    return Run(run_info, run_data, run_inputs, run_outputs)
end
const ActiveRun = Run

"""
    RunTag

Tag object associated with a run.

# Fields
- `key::String`: Name of the tag.
- `value::String`: Value of the tag.
"""
struct RunTag
    key::String
    value::String
end
function RunTag(py_tag::Py)::RunTag
    return RunTag(get_py_attr(py_tag, :key, String), get_py_attr(py_tag, :value, String))
end
