"""
    logmetric(instance::MLFlow, run_id::String, key::String, value::Float64;
        timestamp::Int64=round(Int, now() |> datetime2unix),
        step::Union{Int64, Missing}=missing)
    logmetric(instance::MLFlow, run::Run, key::String, value::Float64;
        timestamp::Int64=round(Int, now() |> datetime2unix),
        step::Union{Int64, Missing}=missing)

Log a [`Metric`](@ref) for a [`Run`](@ref). A [`Metric`](@ref) is a key-value pair (string
key, float value) with an associated timestamp. Examples include the various metrics that
represent ML model accuracy. A [`Metric`](@ref) can be logged multiple times.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the [`Run`](@ref) under which to log the [`Metric`](@ref).
- `key`: Name of the [`Metric`](@ref).
- `value`: Double value of the [`Metric`](@ref) being logged.
- `timestamp`: Unix timestamp in milliseconds at the time [`Metric`](@ref) was logged.
- `step`: Step at which to log the [`Metric`](@ref).

# Returns
`true` if successful. Otherwise, raises exception.
"""
function logmetric(instance::MLFlow, run_id::String, key::String, value::Float64;
    timestamp::Int64=round(Int, now() |> datetime2unix),
    step::Union{Int64, Missing}=missing)::Bool
    mlfpost(instance, "runs/log-metric"; run_id=run_id, key=key, value=value,
        timestamp=timestamp, step=step)
    return true
end
logmetric(instance::MLFlow, run::Run, key::String, value::Float64;
    timestamp::Int64=round(Int, now() |> datetime2unix),
    step::Union{Int64, Missing}=missing)::Bool =
    logmetric(instance, run.info.run_id, key, value; timestamp=timestamp, step=step)
logmetric(instance::MLFlow, run_id::String, metric::Metric)::Bool =
    logmetric(instance, run_id, metric.key, metric.value, timestamp=metric.timestamp,
        step=metric.step)
logmetric(instance::MLFlow, run::Run, metric::Metric)::Bool =
    logmetric(instance, run.info.run_id, metric.key, metric.value,
        timestamp=metric.timestamp, step=metric.step)

"""
    logbatch(instance::MLFlow, run_id::String; metrics::MLFlowUpsertData{Metric},
        params::MLFlowUpsertData{Param}, tags::MLFlowUpsertData{Tag})
    logbatch(instance::MLFlow, run::Run; metrics::Array{Metric},
        params::MLFlowUpsertData{Param}, tags::MLFlowUpsertData{Tag})

Log a batch of metrics, params, and tags for a [`Run`](@ref). In case of error, partial
data may be written.

For more information about this function, check [MLFlow official documentation](https://mlflow.org/docs/latest/rest-api.html#log-batch).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the [`Run`](@ref) to log under.
- `metrics`: A collection of [`Metric`](@ref) to log.
- `params`: A collection of [`Param`](@ref) to log.
- `tags`: A collection of [`Tag`](@ref) to log.

**Note**: A single request can contain up to 1000 metrics, and up to 1000 metrics, params,
and tags in total.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function logbatch(instance::MLFlow, run_id::String;
    metrics::MLFlowUpsertData{Metric}=Metric[], params::MLFlowUpsertData{Param}=Param[],
    tags::MLFlowUpsertData{Tag}=Tag[])::Bool
    mlfpost(instance, "runs/log-batch"; run_id=run_id, metrics=parse(Metric, metrics),
        params=parse(Param, params), tags=parse(Tag, tags))
    return true
end
logbatch(instance::MLFlow, run::Run; metrics::MLFlowUpsertData{Metric}=Metric[],
    params::MLFlowUpsertData{Param}=Param[], tags::MLFlowUpsertData{Tag}=Tag[])::Bool =
    logbatch(instance, run.info.run_id; metrics=metrics, params=params, tags=tags)

"""
    loginputs(instance::MLFlow, run_id::String; datasets::Array{DatasetInput})
    loginputs(instance::MLFlow, run::Run; datasets::Array{DatasetInput})

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the [`Run`](@ref) to log under this field is required.
- `datasets`: A collection of [`DatasetInput`](@ref) to log.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function loginputs(instance::MLFlow, run_id::String, datasets::Array{DatasetInput})::Bool
    mlfpost(instance, "runs/log-inputs"; run_id=run_id, datasets=datasets)
    return true
end
loginputs(instance::MLFlow, run::Run, datasets::Array{DatasetInput})::Bool =
    loginputs(instance, run.info.run_id, datasets)

"""
    logparam(instance::MLFlow, run_id::String, key::String, value::String)
    logparam(instance::MLFlow, run::Run, key::String, value::String)
    logparam(instance::MLFlow, run_id::String, param::Param)
    logparam(instance::MLFlow, run::Run, param::Param)

Log a [`Param`](@ref) used for a [`Run`](@ref). A [`Param`](@ref) is a key-value pair
(string key, string value). Examples include hyperparameters used for ML model training and
constant dates and values used in an ETL pipeline. A [`Param`](@ref) can be logged only
once for a [`Run`](@ref).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the [`Run`](@ref) under which to log the [`Param`](@ref).
- `key`: Name of the [`Param`](@ref).
- `value`: String value of the [`Param`](@ref) being logged.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function logparam(instance::MLFlow, run_id::String, key::String, value::String)::Bool
    mlfpost(instance, "runs/log-parameter"; run_id=run_id, key=key, value=value)
    return true
end
logparam(instance::MLFlow, run::Run, key::String, value::String)::Bool =
    logparam(instance, run.info.run_id, key, value)
logparam(instance::MLFlow, run_id::String, param::Param)::Bool =
    logparam(instance, run_id, param.key, param.value)
logparam(instance::MLFlow, run::Run, param::Param)::Bool =
    logparam(instance, run.info.run_id, param.key, param.value)
