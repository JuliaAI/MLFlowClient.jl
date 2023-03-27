"""
    createrun(mlf::MLFlow, experiment_id; start_time=missing, tags=missing)

Creates a run associated to an experiment.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment_id`: experiment identifier.

# Keywords
- `start_time`: if provided, must be a UNIX timestamp in milliseconds. By default, set to current time.
- `tags`: if provided, must be a key-value structure such as a dictionary.

# Returns
- an instance of type [`MLFlowRun`](@ref)
"""
function createrun(mlf::MLFlow, experiment_id; start_time=missing, tags=missing)
    endpoint = "runs/create"
    if ismissing(start_time)
        start_time = Int(trunc(datetime2unix(now(UTC)) * 1000))
    end
    result = mlfpost(mlf, endpoint; experiment_id=experiment_id, start_time=start_time, tags=tags)
    MLFlowRun(result["run"]["info"], result["run"]["data"])
end
"""
    createrun(mlf::MLFlow, experiment::MLFlowExperiment; start_time=missing, tags=missing)

Dispatches to `createrun(mlf::MLFlow, experiment_id; start_time=start_time, tags=tags)`
"""
createrun(mlf::MLFlow, experiment::MLFlowExperiment; start_time=missing, tags=missing) =
    createrun(mlf, experiment.experiment_id; start_time=start_time, tags=tags)

"""
    getrun(mlf::MLFlow, run_id)

Retrieves information about an MLFlow run.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `run_id::String`: run identifier.

# Returns
- an instance of type [`MLFlowRun`](@ref)
"""
function getrun(mlf::MLFlow, run_id)
    endpoint = "runs/get"
    result = mlfget(mlf, endpoint; run_id=run_id)
    MLFlowRun(result["run"]["info"], result["run"]["data"])
end

"""
    updaterun(mlf::MLFlow, run, status; end_time=missing)

Updates the status of an experiment's run.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `run`: one of [`MLFlowRun`](@ref), [`MLFlowRunInfo`](@ref), or `String`.
- `status`: either `String` and one of ["RUNNING", "SCHEDULED", "FINISHED", "FAILED", "KILLED"], or an instance of `MLFlowRunStatus`

# Keywords
- `end_time`: if provided, must be a UNIX timestamp in milliseconds. By default, set to current time.
"""
function updaterun(mlf::MLFlow, run_id::String, status::MLFlowRunStatus; end_time=missing)
    endpoint = "runs/update"
    kwargs = Dict(
        :run_id => run_id,
        :status => status.status,
        :end_time => end_time
    )
    if ismissing(end_time) && status.status == "FINISHED"
        end_time = Int(trunc(datetime2unix(now(UTC)) * 1000))
        kwargs[:end_time] = string(end_time)
    end
    result = mlfpost(mlf, endpoint; kwargs...)
    MLFlowRun(result["run_info"])
end
updaterun(mlf::MLFlow, run_id::String, status::String; end_time=missing) =
    updaterun(mlf, run_id, MLFlowRunStatus(status); end_time=end_time)
updaterun(mlf::MLFlow, run_info::MLFlowRunInfo, status::String; end_time=missing) =
    updaterun(mlf, run_info.run_id, MLFlowRunStatus(status); end_time=end_time)
updaterun(mlf::MLFlow, run::MLFlowRun, status::String; end_time=missing) =
    updaterun(mlf, run.info, MLFlowRunStatus(status), end_time=end_time)
updaterun(mlf::MLFlow, run_info::MLFlowRunInfo, status::MLFlowRunStatus; end_time=missing) =
    updaterun(mlf, run_info.run_id, status, end_time=end_time)
updaterun(mlf::MLFlow, run::MLFlowRun, status::MLFlowRunStatus; end_time=missing) =
    updaterun(mlf, run.info, status; end_time=end_time)

"""
    deleterun(mlf::MLFlow, run)

Deletes an experiment's run.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `run`: one of [`MLFlowRun`](@ref), [`MLFlowRunInfo`](@ref), or `String`.

# Returns
`true` if successful.

"""
function deleterun(mlf::MLFlow, run_id::String)
    endpoint = "runs/delete"
    mlfpost(mlf, endpoint; run_id=run_id)
    true
end
deleterun(mlf::MLFlow, run_info::MLFlowRunInfo) = deleterun(mlf, run_info.run_id)
deleterun(mlf::MLFlow, run::MLFlowRun) = deleterun(mlf, run.info)

"""
    searchruns(mlf::MLFlow, experiment_ids)

Searches for runs in an experiment.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment_ids::AbstractVector{Integer}`: `experiment_id`s in which to search for runs. Can also be a single `Integer`.

# Keywords
- `filter::String`: filter as defined in [MLFlow documentation](https://mlflow.org/docs/latest/rest-api.html#search-runs)
- `filter_params::AbstractDict{K,V}`: if provided, `filter` is automatically generated based on `filter_params` using [`generatefilterfromparams`](@ref). One can only provide either `filter` or `filter_params`, but not both.
- `run_view_type::String`: one of `ACTIVE_ONLY`, `DELETED_ONLY`, or `ALL`.
- `max_results::Integer`: 50,000 by default.
- `order_by::String`: as defined in [MLFlow documentation](https://mlflow.org/docs/latest/rest-api.html#search-runs)
- `page_token::String`: paging functionality, handled automatically. Not meant to be passed by the user.

# Returns
- vector of [`MLFlowRun`](@ref) runs that were found in the list of experiments.

"""
function searchruns(mlf::MLFlow, experiment_ids::AbstractVector{<:Integer};
                    filter::String="",
                    filter_params::AbstractDict{K,V}=Dict{}(),
                    run_view_type::String="ACTIVE_ONLY",
                    max_results::Int64=50000,
                    order_by::AbstractVector{<:String}=["attribute.end_time"],
                    page_token::String=""
                    ) where {K,V}
    endpoint = "runs/search"
    run_view_type ∈ ["ACTIVE_ONLY", "DELETED_ONLY", "ALL"] || error("Unsupported run_view_type = $run_view_type")

    if length(filter_params) > 0 && length(filter) > 0
        error("Can only use either filter or filter_params, but not both at the same time.")
    end

    if length(filter_params) > 0
        filter = generatefilterfromparams(filter_params)
    end

    kwargs = (
        experiment_ids=experiment_ids,
        filter=filter,
        run_view_type=run_view_type,
        max_results=max_results,
        order_by=order_by
    )
    if !isempty(page_token)
        kwargs = (; kwargs..., page_token=page_token)
    end

    result = mlfpost(mlf, endpoint; kwargs...)
    haskey(result, "runs") || return MLFlowRun[]

    runs = map(x -> MLFlowRun(x["info"], x["data"]), result["runs"])

    # paging functionality using recursion
    if haskey(result, "next_page_token") && !isempty(result["next_page_token"])
        kwargs = (
            filter=filter,
            run_view_type=run_view_type,
            max_results=max_results,
            order_by=order_by,
            page_token=result["next_page_token"]
        )
        nextruns = searchruns(mlf, experiment_ids; kwargs...)
        return vcat(runs, nextruns)
    end

    runs
end
searchruns(mlf::MLFlow, experiment_id::Integer; kwargs...) =
    searchruns(mlf, [experiment_id]; kwargs...)
searchruns(mlf::MLFlow, exp::MLFlowExperiment; kwargs...) =
    searchruns(mlf, exp.experiment_id; kwargs...)
searchruns(mlf::MLFlow, exps::AbstractVector{MLFlowExperiment}; kwargs...) =
    searchruns(mlf, [getfield.(exps, :experiment_id)]; kwargs...)


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
function logmetric(mlf::MLFlow, run_id::String, key, value::T; timestamp=missing, step=missing) where T<:Real
    endpoint = "runs/log-metric"
    if ismissing(timestamp)
        timestamp = Int(trunc(datetime2unix(now(UTC)) * 1000))
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
                nextdepthresult = listartifacts(mlf, run_id, path=resultentry["path"], maxdepth=maxdepth-1)
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
