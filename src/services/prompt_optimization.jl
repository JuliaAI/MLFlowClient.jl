"""
    createpromptoptimizationjob(instance::MLFlow, experiment_id::String,
        source_prompt_uri::String, config::Dict{String,Any};
        tags::Array{PromptOptimizationJobTag}=PromptOptimizationJobTag[])

Create a new prompt optimization job.

This endpoint initiates an optimization run with the specified configuration.
The optimization process runs asynchronously and can be monitored via getpromptoptimizationjob.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: ID of the MLflow experiment to track the optimization job in.
- `source_prompt_uri`: URI of the source prompt to optimize (e.g., "prompts:/my-prompt/1").
- `config`: Configuration for the optimization job as a dictionary.
- `tags`: Optional tags for the optimization job.

# Returns
An instance of type [`PromptOptimizationJob`](@ref).
"""
function createpromptoptimizationjob(instance::MLFlow, experiment_id::String,
    source_prompt_uri::String, config::Dict{String,Any};
    tags::Array{PromptOptimizationJobTag}=PromptOptimizationJobTag[])::PromptOptimizationJob
    result = mlfpost_v3(instance, "prompt-optimization/jobs";
        experiment_id=experiment_id, source_prompt_uri=source_prompt_uri,
        config=config, tags=tags)
    return result["job"] |> PromptOptimizationJob
end

"""
    getpromptoptimizationjob(instance::MLFlow, job_id::String)

Get the details and status of a prompt optimization job.

Returns the job configuration, current status, progress statistics,
and the best prompt if the optimization has completed.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `job_id`: The unique identifier of the optimization job (same as run_id).

# Returns
An instance of type [`PromptOptimizationJob`](@ref).
"""
function getpromptoptimizationjob(instance::MLFlow, job_id::String)::PromptOptimizationJob
    result = mlfget_v3(instance, "prompt-optimization/jobs/$(job_id)")
    return result["job"] |> PromptOptimizationJob
end

"""
    searchpromptoptimizationjobs(instance::MLFlow, experiment_id::String)

Search for prompt optimization jobs.

Returns a list of optimization jobs matching the specified filters.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: ID of the MLflow experiment to search optimization jobs in.

# Returns
Vector of [`PromptOptimizationJob`](@ref) entities.
"""
function searchpromptoptimizationjobs(instance::MLFlow, experiment_id::String)::Array{PromptOptimizationJob}
    result = mlfpost_v3(instance, "prompt-optimization/jobs/search";
        experiment_id=experiment_id)
    return get(result, "jobs", []) |> (x -> [PromptOptimizationJob(y) for y in x])
end

"""
    cancelpromptoptimizationjob(instance::MLFlow, job_id::String)

Cancel an in-progress prompt optimization job.

If the job is already completed or cancelled, this operation has no effect.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `job_id`: The unique identifier of the optimization job to cancel.

# Returns
An instance of type [`PromptOptimizationJob`](@ref).
"""
function cancelpromptoptimizationjob(instance::MLFlow, job_id::String)::PromptOptimizationJob
    result = mlfpost_v3(instance, "prompt-optimization/jobs/$(job_id)/cancel")
    return result["job"] |> PromptOptimizationJob
end

"""
    deletepromptoptimizationjob(instance::MLFlow, job_id::String)

Delete a prompt optimization job and its associated data.

This permanently removes the job and all related information.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `job_id`: The unique identifier of the optimization job to delete.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletepromptoptimizationjob(instance::MLFlow, job_id::String)::Bool
    mlfdelete_v3(instance, "prompt-optimization/jobs/$(job_id)")
    return true
end
