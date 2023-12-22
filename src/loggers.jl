"""
    logparam(mlf::MLFlow, run, key, value)
    logparam(mlf::MLFlow, run, kv)

Associates a key/value pair of parameters to the particular run.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `run`: one of [`MLFlowRun`](@ref), [`MLFlowRunInfo`](@ref), or `String`.
- `key`: parameter key (name). Automatically converted to string before sending to MLFlow because this is the only type that MLFlow supports.
- `value`: parameter value. Automatically converted to string before sending to MLFlow because this is the only type that MLFlow supports.

One could also specify `kv::Dict` instead of separate `key` and `value` arguments.
"""
function logparam(mlf::MLFlow, run_id::String, key, value)
    endpoint = "runs/log-parameter"
    mlfpost(mlf, endpoint; run_id=run_id, key=string(key), value=string(value))
end
logparam(mlf::MLFlow, run_info::MLFlowRunInfo, key, value) =
    logparam(mlf, run_info.run_id, key, value)
logparam(mlf::MLFlow, run::MLFlowRun, key, value) =
    logparam(mlf, run.info, key, value)
function logparam(mlf::MLFlow, run::Union{String,MLFlowRun,MLFlowRunInfo}, kv)
    for (k, v) in kv
        logparam(mlf, run, k, v)
    end
end


"""
    logmetric(mlf::MLFlow, run, key, value::T; timestamp, step) where T<:Real
    logmetric(mlf::MLFlow, run, key, values::AbstractArray{T}; timestamp, step) where T<:Real

Logs a metric value (or values) against a particular run.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `run`: one of [`MLFlowRun`](@ref), [`MLFlowRunInfo`](@ref), or `String`
- `key`: metric name.
- `value`: metric value, must be numeric.

# Keywords
- `timestamp`: if provided, must be a UNIX timestamp in milliseconds. By default, set to current time.
- `step`: step at which the metric value has been taken.
"""
function logmetric(mlf::MLFlow, run_id::String, key, value::T; timestamp=missing, step=missing) where {T<:Real}
    endpoint = "runs/log-metric"
    if ismissing(timestamp)
        timestamp = Int(trunc(datetime2unix(now(UTC)) * 1000))
    end
    mlfpost(mlf, endpoint; run_id=run_id, key=key, value=value, timestamp=timestamp, step=step)
end
logmetric(mlf::MLFlow, run_info::MLFlowRunInfo, key, value::T; timestamp=missing, step=missing) where {T<:Real} =
    logmetric(mlf::MLFlow, run_info.run_id, key, value; timestamp=timestamp, step=step)
logmetric(mlf::MLFlow, run::MLFlowRun, key, value::T; timestamp=missing, step=missing) where {T<:Real} =
    logmetric(mlf, run.info, key, value; timestamp=timestamp, step=step)

function logmetric(mlf::MLFlow, run::Union{String,MLFlowRun,MLFlowRunInfo}, key, values::AbstractArray{T}; timestamp=missing, step=missing) where {T<:Real}
    for v in values
        logmetric(mlf, run, key, v; timestamp=timestamp, step=step)
    end
end


"""
    logartifact(mlf::MLFlow, run, basefilename, data)

Stores an artifact (file) in the run's artifact location.

!!! note
    Assumes that artifact_uri is mapped to a local directory.
    At the moment, this only works if both MLFlow and the client are running on the same host or they map a directory that leads to the same location over NFS, for example.

# Arguments
- `mlf::MLFlow`: [`MLFlow`](@ref) onfiguration. Currently not used, but when this method is extended to support `S3`, information from `mlf` will be needed.
- `run`: one of [`MLFlowRun`](@ref), [`MLFlowRunInfo`](@ref) or `String`.
- `basefilename`: name of the file to be written.
- `data`: artifact content, an object that can be written directly to a file handle.

# Throws
- an `ErrorException` if an exception occurs during writing artifact.

# Returns
path of the artifact that was created.
"""
function logartifact(mlf::MLFlow, run_id::AbstractString, basefilename::AbstractString, data)
    mlflowrun = getrun(mlf, run_id)
    artifact_uri = mlflowrun.info.artifact_uri

    if !startswith(artifact_uri, "s3://")
        mkpath(artifact_uri)
        filepath = joinpath(artifact_uri, basefilename)
        try
            open(filepath, "w") do f
                write(f, data)
            end
        catch e
            error("Unable to create artifact $(filepath): $e")
        end
    else
        region = get(ENV, "AWS_REGION", "")  # Optional, defaults to empty if not set

        if haskey(ENV, "MLFLOW_S3_ENDPOINT_URL")
          s3creds = AWSCredentials()
          s3config = MinioConfig(ENV["MLFLOW_S3_ENDPOINT_URL"], s3creds; region=region)
        else
          s3config = global_aws_config() # default AWS configuration
        end

        filepath = joinpath(artifact_uri, basefilename)

        try
            open(joinpath("/tmp/",basefilename), "w") do f
                write(f, data)
            end
            open(joinpath("/tmp/",basefilename), "r") do f
                file_data = read(f)
                s3_put(s3config, artifact_uri, filepath, file_data)
            end
        catch e
            error("Unable to upload artifact to S3 $(filepath): $e")
        end
    end

    return filepath
end
logartifact(mlf::MLFlow, run::MLFlowRun, basefilename::AbstractString, data) =
    logartifact(mlf, run.info, basefilename, data)
logartifact(mlf::MLFlow, run_info::MLFlowRunInfo, basefilename::AbstractString, data) =
    logartifact(mlf, run_info.run_id, basefilename, data)

"""
    logartifact(mlf::MLFlow, run, filepath)

Stores an artifact (file) in the run's artifact location.
The name of the artifact is calculated using `basename(filepath)`.

Dispatches on `logartifact(mlf::MLFlow, run, basefilename, data)` where `data` is the contents of `filepath`.

# Throws
- an `ErrorException` if `filepath` does not exist.
- an exception if such occurs while trying to read the contents of `filepath`.

"""
function logartifact(mlf::MLFlow, run_id::AbstractString, filepath::Union{AbstractPath,AbstractString})
    isfile(filepath) || error("File $filepath does not exist.")
    try
        f = open(filepath, "r")
        data = read(f)
        close(f)
        return logartifact(mlf, run_id, basename(filepath), data)
    catch e
        throw(e)
    finally
        if @isdefined f
            close(f)
        end
    end
end
logartifact(mlf::MLFlow, run::MLFlowRun, filepath::Union{AbstractPath,AbstractString}) =
    logartifact(mlf, run.info, filepath)
logartifact(mlf::MLFlow, run_info::MLFlowRunInfo, filepath::Union{AbstractPath,AbstractString}) =
    logartifact(mlf, run_info.run_id, filepath)

"""
    listartifacts(mlf::MLFlow, run)

Lists the artifacts associated with an experiment run.
According to [MLFlow documentation](https://mlflow.org/docs/latest/rest-api.html#list-artifacts), this API endpoint should return paged results, similar to [`searchruns`](@ref).
However, after some experimentation, this doesn't seem to be the case. Therefore, the paging functionality is not implemented here.

# Arguments
- `mlf::MLFlow`: [`MLFlow`](@ref) onfiguration. Currently not used, but when this method is extended to support `S3`, information from `mlf` will be needed.
- `run`: one of [`MLFlowRun`](@ref), [`MLFlowRunInfo`](@ref) or `String`.

# Keywords
- `path::String`: path of a directory within the artifact location. If set, returns the contents of the directory. By default, this is the root directory of the artifacts.
- `maxdepth::Int64`: depth of listing. Default is 1. This will only return the files/directories in the current `path`. To return all artifacts files and directories, use `maxdepth=-1`.

# Returns
A vector of `Union{MLFlowArtifactFileInfo,MLFlowArtifactDirInfo}`.
"""
function listartifacts(mlf::MLFlow, run_id::String; path::String="", maxdepth::Int64=1)
    endpoint = "artifacts/list"
    kwargs = (
        run_id=run_id,
    )
    kwargs = (; kwargs..., path=path)
    httpresult = mlfget(mlf, endpoint; kwargs...)
    "files" ∈ keys(httpresult) || return Vector{Union{MLFlowArtifactFileInfo,MLFlowArtifactDirInfo}}()
    "root_uri" ∈ keys(httpresult) || error("Malformed response from MLFlow REST API.")
    root_uri = httpresult["root_uri"]
    result = Vector{Union{MLFlowArtifactFileInfo,MLFlowArtifactDirInfo}}()
    maxdepth == 0 && return result

    for resultentry ∈ httpresult["files"]
        if resultentry["is_dir"] == false
            filepath = joinpath(root_uri, resultentry["path"])
            file_size = resultentry["file_size"]
            if typeof(file_size) <: Int
                filesize = file_size
            else
                filesize = parse(Int, file_size)
            end
            push!(result, MLFlowArtifactFileInfo(filepath, filesize))
        elseif resultentry["is_dir"] == true
            dirpath = joinpath(root_uri, resultentry["path"])
            push!(result, MLFlowArtifactDirInfo(dirpath))
            if maxdepth != 0
                nextdepthresult = listartifacts(mlf, run_id, path=resultentry["path"], maxdepth=maxdepth - 1)
                result = vcat(result, nextdepthresult)
            end
        else
            isdirval = resultentry["is_dir"]
            @warn "Malformed response from MLFlow REST API is_dir=$isdirval - skipping"
            continue
        end
    end
    result
end
listartifacts(mlf::MLFlow, run::MLFlowRun; kwargs...) =
    listartifacts(mlf, run.info.run_id; kwargs...)
listartifacts(mlf::MLFlow, run_info::MLFlowRunInfo; kwargs...) =
    listartifacts(mlf, run_info.run_id; kwargs...)

"""
    logbatch(mlf::MLFlow, run_id::String, metrics, params, tags)

Logs a batch of metrics, parameters and tags to an experiment run.

# Arguments
- `mlf::MLFlow`: [`MLFlow`](@ref) onfiguration.
- `run_id::String`: ID of the run to log to.
- `metrics`: a vector of [`MLFlowRunDataMetric`](@ref) or a vector of
NamedTuples of `(name, value, timestamp)`.
- `params`: a vector of [`MLFlowRunDataParam`](@ref) or a vector of NamedTuples
of `(name, value)`.
- `tags`: a vector of strings.
"""
logbatch(mlf::MLFlow, run_id::String; tags=String[], metrics=Any[],
    params=Any[]) = logbatch(mlf, run_id, tags, metrics, params)
function logbatch(mlf::MLFlow, run_id::String,
    tags::Union{AbstractVector{<:String}, AbstractVector{Any}},
    metrics::Union{AbstractVector{<:MLFlowRunDataMetric}, AbstractVector{Any}},
    params::Union{AbstractVector{<:MLFlowRunDataParam}, AbstractVector{Any}})
    endpoint = "runs/log-batch"
    mlfpost(mlf, endpoint;
        run_id=run_id, metrics=metrics, params=params, tags=tags)
end
function logbatch(mlf::MLFlow, run_id::String,
    tags::Union{AbstractVector{<:String}, AbstractVector{Any}},
    metrics::Union{AbstractVector{<:AbstractDict}, AbstractVector{Any}},
    params::Union{AbstractVector{<:AbstractDict}, AbstractVector{Any}})
    endpoint = "runs/log-batch"
    mlfpost(mlf, endpoint; run_id=run_id,
        metrics=MLFlowRunDataMetric.(metrics),
        params=MLFlowRunDataParam.(params), tags=tags)
end
