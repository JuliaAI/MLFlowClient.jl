"""
    set_tracking_uri(uri::AbstractString)

Set the tracking server URI. This does not affect the currently active run (if one exists), but takes effect for successive runs.

# Arguments
- `uri::AbstractString`:
    - An empty string, or a local file path, prefixed with file:/. Data is stored locally at the provided file (or ./mlruns if empty).
    - An HTTP URI like https://my-tracking-server:5000.
    - A Databricks workspace, provided as the string “databricks” or, to use a Databricks CLI profile, “databricks://<profileName>”.
"""
function set_tracking_uri(uri::AbstractString)
    _mlflow.set_tracking_uri(uri)
    return nothing
end

"""
    get_tracking_uri()::String

Get the current tracking URI. This may not correspond to the tracking URI of the currently active run, since the tracking URI can be updated via [set_tracking_uri](@ref).

# Returns
The tracking URI.
"""
get_tracking_uri()::String = pyconvert(String, _mlflow.get_tracking_uri())

"""
    set_experiment(; experiment_name::Union{String,Nothing}=nothing, experiment_id::Union{String,Nothing}=nothing, trace_location::Union{UnityCatalog,Nothing}=nothing)

Set the given experiment as the active experiment. The experiment must either be specified by name via experiment_name or by ID via experiment_id. The experiment name and ID cannot both be specified.

!!! note
    If the experiment being set by name does not exist, a new experiment will be created with the given name. After the experiment has been created, it will be set as the active experiment. On certain platforms, such as Databricks, the experiment name must be an absolute path, e.g. "/Users/<username>/my-experiment".

# Arguments
- `experiment_name::Union{String,Nothing}`: Case sensitive name of the experiment to be activated.
- `experiment_id::Union{String,Nothing}`: ID of the experiment to be activated. If an experiment with this ID does not exist, an exception is thrown.
- `trace_location::Union{UnityCatalog,Nothing}`: Optional UC trace location used to configure the experiment-derived tracing destination.

# Returns
An instance of [Experiment](@ref) representing the new active experiment.
"""
function set_experiment(;
    experiment_name::Union{String,Nothing}=nothing,
    experiment_id::Union{String,Nothing}=nothing,
    trace_location::Union{UnityCatalog,Nothing}=nothing,
)::Experiment
    kwargs = Dict{Symbol,Any}()
    if !(experiment_name |> isnothing)
        kwargs[:experiment_name] = experiment_name
    end
    if !(experiment_id |> isnothing)
        kwargs[:experiment_id] = experiment_id
    end
    if !(trace_location |> isnothing)
        kwargs[:trace_location] = trace_location
    end

    py_exp = _mlflow.set_experiment(; kwargs...)

    return py_exp |> Experiment
end

"""
    start_run
"""
function start_run(;
    run_id::Union{String,Nothing}=nothing,
    experiment_id::Union{String,Nothing}=nothing,
    run_name::Union{String,Nothing}=nothing,
    nested::Bool=false,
    parent_run_id::Union{String,Nothing}=nothing,
    tags::Union{Dict{String,Any},Nothing}=nothing,
    description::Union{String,Nothing}=nothing,
    log_system_metrics::Union{Bool,Nothing}=nothing,
)::ActiveRun
    py_run = _mlflow.start_run(
        run_id=run_id,
        experiment_id=experiment_id,
        run_name=run_name,
        nested=nested,
        parent_run_id=parent_run_id,
        tags=tags,
        description=description,
        log_system_metrics=log_system_metrics
    )
    return py_run |> ActiveRun
end

"""
    active_run()

Get the currently active [Run](@ref), or `nothing` if no such run exists.
!!! note
    This API is thread-local and returns only the active run in the current thread. If your application is multi-threaded and a run is started in a different thread, this API will not retrieve that run.
"""
function active_run()::Union{ActiveRun,Nothing}
    py_run = _mlflow.active_run()

    if PythonCall.Core.pyisnone(py_run)
        return nothing
    end

    return py_run |> ActiveRun
end

"""
    end_run(; status::String="FINISHED")

End an active MLflow run (if there is one).
"""
function end_run(; status::String="FINISHED")
    _mlflow.end_run(status=status)
end
