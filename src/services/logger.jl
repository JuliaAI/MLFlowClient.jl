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
    step::Union{Int64,Missing}=missing)::Bool
    mlfpost(instance, "runs/log-metric"; run_id=run_id, key=key, value=value,
        timestamp=timestamp, step=step)
    return true
end
logmetric(instance::MLFlow, run::Run, key::String, value::Float64;
    timestamp::Int64=round(Int, now() |> datetime2unix),
    step::Union{Int64,Missing}=missing)::Bool =
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

!!! note
    A single request can contain up to 1000 metrics, and up to 1000 metrics, params, and
    tags in total.

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

"""
    logmodel(instance::MLFlow, run_id::String, model_json::String)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the [`Run`](@ref) to log under.
- `model_json`: MLmodel file in json format.
"""
function logmodel(instance::MLFlow, run_id::String, model_json::String)::Bool
    mlfpost(instance, "runs/log-model"; run_id=run_id, model_json=model_json)
    return true
end
logmodel(instance::MLFlow, run::Run, model_json::String)::Bool =
    logmodel(instance, run.info.run_id, model_json)

"""
    logartifact(s3_cfg::MinioConfig, run::Run, s3_cfg::MinioConfig, path::String="", artifact_name::String="")

Log artifact for a run. Supports only S3 buckets.

# Arguments
- `s3_cfg`: Minio configuration
- `Run`: ['Run'](@ref) instance
- `path`: Path to the artifact
- `artifact_name`: Name of the artifact in the bucket

# Returns
`true` if successful. Otherwise, raises exception.

"""
function logartifact(s3_cfg::MinioConfig, run::Run, path::String="", artifact_name::String="")
    # Parse the URI
    u = URI(run.info.artifact_uri)
    u.scheme == "s3" || ArgumentError("The artifact URI for the run has to be a S3 bucket. Got: $(run.info.artifact_uri)")
    isfile(path) || ArgumentError("Can not read file $(path).")
    bucket_name = u.host
    artifacts_base_path = u.path


    # Determine MIME type to use
    kind = matcher(path)
    mime_type_str = if isnothing(kind)
        @warn "FileTypes.jl could not determing the specific MIME type for $(path). Defaulting to application/octet-stream"
        "application/octet-stream"
    else 
        string(kind.mime)
    end

    # Read the bytes of the file
    content = read(path)

    # Create the artifact path on the bucket
    artifact_path = isempty(artifact_name) ? joinpath(artifacts_base_path, path) : joinpath(artifacts_base_path, artifact_name)

    s3_put(s3_cfg, bucket_name, artifact_path, content, mime_type_str)
    return true
end


