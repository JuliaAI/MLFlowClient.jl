"""
    logmetric(instance::MLFlow, run_id::String, key::String, value::Float64;
        timestamp::Int64=round(Int, now() |> datetime2unix),
        step::Union{Int64, Missing}=missing)
    logmetric(instance::MLFlow, run::Run, key::String, value::Float64;
        timestamp::Int64=round(Int, now() |> datetime2unix),
        step::Union{Int64, Missing}=missing)

Log a metric for a run. A metric is a key-value pair (string key, float value)
with an associated timestamp. Examples include the various metrics that
represent ML model accuracy. A metric can be logged multiple times.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the run under which to log the metric.
- `key`: Name of the metric.
- `value`: Double value of the metric being logged.
- `timestamp`: Unix timestamp in milliseconds at the time metric was logged.
- `step`: Step at which to log the metric.
"""
logmetric(instance::MLFlow, run_id::String, key::String, value::Float64;
    timestamp::Int64=round(Int, now() |> datetime2unix),
    step::Union{Int64, Missing}=missing) =
    mlfpost(instance, "runs/log-metric"; run_id=run_id, key=key, value=value, timestamp=timestamp, step=step)
logmetric(instance::MLFlow, run::Run, key::String, value::Float64;
    timestamp::Int64=round(Int, now() |> datetime2unix),
    step::Union{Int64, Missing}=missing) =
    logmetric(instance, run.info.run_id, key, value; timestamp=timestamp, step=step)

"""
    logbatch(instance::MLFlow, run_id::String, metrics::Array{Metric},
        params::Array{Param}, tags::Array{Tag})

Log a batch of metrics, params, and tags for a run. In case of error, partial
data may be written.

For more information about this function, check [MLFlow official documentation](https://mlflow.org/docs/latest/rest-api.html#log-batch).
"""
function logbatch(instance::MLFlow, run_id::String;
    metrics::Array{Metric}=Metric[], params::Array{Param}=Param[],
        tags::MLFlowUpsertData{Tag}=Tag[])
    mlfpost(instance, "runs/log-batch"; run_id=run_id, metrics=metrics,
            params=params, tags=(tags |> parse))
end
