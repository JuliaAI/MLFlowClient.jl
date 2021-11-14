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
        start_time = Int(trunc(datetime2unix(now()) * 1000))
    end
    result = mlfpost(mlf, endpoint; experiment_id=experiment_id, start_time=string(start_time), tags=tags)
    MLFlowRun(result["run"]["info"], result["run"]["data"])
end

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
        end_time = Int(trunc(datetime2unix(now()) * 1000))
        kwargs[:end_time] => end_time
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
"""
function deleterun(mlf::MLFlow, run_id::String)
    endpoint = "runs/delete"
    mlfpost(mlf, endpoint; run_id=run_id)
end
deleterun(mlf::MLFlow, run_info::MLFlowRunInfo) = deleterun(mlf, run_info.run_id)
deleterun(mlf::MLFlow, run::MLFlowRun) = deleterun(mlf, run.info)

