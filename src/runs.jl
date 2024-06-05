"""
    createrun(mlf::MLFlow, experiment_id; run_name=missing, start_time=missing, tags=missing)

Creates a run associated to an experiment.

# Arguments
- `mlf`: [`MLFlow`](@ref) configuration.
- `experiment_id`: experiment identifier.

# Keywords
- `run_name`: run name. If not specified, MLFlow sets it.
- `start_time`: if provided, must be a UNIX timestamp in milliseconds. By default, set to current time.
- `tags`: if provided, must be a key-value structure such as for example:
    - [Dict("key" => "foo", "value" => "bar"), Dict("key" => "missy", "value" => "gala")]

# Returns
- an instance of type [`MLFlowRun`](@ref)
"""
function createrun(mlf::MLFlow, experiment_id; run_name=missing, start_time=missing, tags::Vector{Dict{String, String}}=missing)
    endpoint = "runs/create"
    if ismissing(start_time)
        start_time = Int(trunc(datetime2unix(now(UTC)) * 1000))
    end
    result = mlfpost(mlf, endpoint; experiment_id=experiment_id, run_name=run_name, start_time=start_time, tags=tags)
    MLFlowRun(result["run"]["info"], result["run"]["data"])
end
"""
    createrun(mlf::MLFlow, experiment::MLFlowExperiment; run_name=missing, start_time=missing, tags::Vector{Dict{String, String}}=missing)

Dispatches to `createrun(mlf::MLFlow, experiment_id; run_name=run_name, start_time=start_time, tags=tags)`
"""
createrun(mlf::MLFlow, experiment::MLFlowExperiment; run_name=missing, start_time=missing, tags::Vector{Dict{String, String}}=missing) =
    createrun(mlf, experiment.experiment_id; run_name=run_name, start_time=start_time, tags=tags)

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
- `run_name`: if provided, must be a String. By default, not set.
- `end_time`: if provided, must be a UNIX timestamp in milliseconds. By default, set to current time.
"""
function updaterun(mlf::MLFlow, run_id::String, status::MLFlowRunStatus; run_name=missing, end_time=missing)
    endpoint = "runs/update"
    kwargs = Dict(
        :run_id => run_id,
        :status => status.status,
        :run_name => run_name,
        :end_time => end_time
    )
    if ismissing(end_time) && status.status == "FINISHED"
        end_time = Int(trunc(datetime2unix(now(UTC)) * 1000))
        kwargs[:end_time] = string(end_time)
    end
    result = mlfpost(mlf, endpoint; kwargs...)
    MLFlowRun(result["run_info"])
end
updaterun(mlf::MLFlow, run_id::String, status::String; run_name=missing, end_time=missing) =
    updaterun(mlf, run_id, MLFlowRunStatus(status); run_name=run_name, end_time=end_time)
updaterun(mlf::MLFlow, run_info::MLFlowRunInfo, status::String; run_name=missing, end_time=missing) =
    updaterun(mlf, run_info.run_id, MLFlowRunStatus(status); run_name=run_name, end_time=end_time)
updaterun(mlf::MLFlow, run::MLFlowRun, status::String; run_name=missing, end_time=missing) =
    updaterun(mlf, run.info, MLFlowRunStatus(status); run_name=run_name, end_time=end_time)
updaterun(mlf::MLFlow, run_info::MLFlowRunInfo, status::MLFlowRunStatus; run_name=missing, end_time=missing) =
    updaterun(mlf, run_info.run_id, status; run_name=run_name, end_time=end_time)
updaterun(mlf::MLFlow, run::MLFlowRun, status::MLFlowRunStatus; run_name=missing, end_time=missing) =
    updaterun(mlf, run.info, status; run_name=run_name, end_time=end_time)

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
        next_runs = searchruns(mlf, experiment_ids; kwargs...)
        return vcat(runs, next_runs)
    end

    runs
end
searchruns(mlf::MLFlow, experiment_id::Integer; kwargs...) =
    searchruns(mlf, [experiment_id]; kwargs...)
searchruns(mlf::MLFlow, exp::MLFlowExperiment; kwargs...) =
    searchruns(mlf, exp.experiment_id; kwargs...)
searchruns(mlf::MLFlow, exps::AbstractVector{MLFlowExperiment}; kwargs...) =
    searchruns(mlf, getfield.(exps, :experiment_id); kwargs...)
