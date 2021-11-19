"""
    logparam(mlf::MLFlow, run, key, value)
    logparam(mlf::MLFlow, run, kv)

Associates a key/value pair of parameters to the particular run.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `run`: one of [`MLFlowRun`](@ref), [`MLFlowRunInfo`](@ref), or `String`.
- `key`: parameter key (name).
- `value`: parameter value.

One could also specify `kv::Dict` instead of separate `key` and `value` arguments.
"""
function logparam(mlf::MLFlow, run_id::String, key, value)
    endpoint = "runs/log-parameter"
    mlfpost(mlf, endpoint; run_id=run_id, key=key, value=value)
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
function logmetric(mlf::MLFlow, run_id::String, key, value::T; timestamp=missing, step=missing) where T<:Real
    endpoint = "runs/log-metric"
    if ismissing(timestamp)
        timestamp = Int(trunc(datetime2unix(now()) * 1000))
    end
    mlfpost(mlf, endpoint; run_id=run_id, key=key, value=value, timestamp=timestamp, step=step)
end
logmetric(mlf::MLFlow, run_info::MLFlowRunInfo, key, value::T; timestamp=missing, step=missing) where T<:Real =
    logmetric(mlf::MLFlow, run_info.run_id, key, value; timestamp=timestamp, step=step)
logmetric(mlf::MLFlow, run::MLFlowRun, key, value::T; timestamp=missing, step=missing) where T<:Real =
    logmetric(mlf, run.info, key, value; timestamp=timestamp, step=step)

function logmetric(mlf::MLFlow, run::Union{String,MLFlowRun,MLFlowRunInfo}, key, values::AbstractArray{T}; timestamp=missing, step=missing) where T<:Real
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
    mkpath(artifact_uri)
    filepath = joinpath(artifact_uri, basefilename)
    try
        f = open(filepath, "w")
        write(f, data)
        close(f)
    catch e
        error("Unable to create artifact $(filepath): $e")
    end
    filepath
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
