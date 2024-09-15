"""
    createrun(instance::MLFlow, experiment_id::String;
        run_name::Union{String, Missing}=missing,
        start_time::Union{Integer, Missing}=missing,
        tags::Union{Dict{<:Any}, Array{<:Any}}=[])

Create a new run within an experiment. A run is usually a single execution of a
machine learning or data ETL pipeline.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: ID of the associated experiment.
- `run_name`: Name of the run.
- `start_time`: Unix timestamp in milliseconds of when the run started.
- `tags`: Additional metadata for run.

# Returns
An instance of type [`Run`](@ref).
"""
function createrun(instance::MLFlow, experiment_id::String;
    run_name::Union{String, Missing}=missing,
    start_time::Union{Integer, Missing}=missing,
    tags::Union{Dict{<:Any}, Array{<:Any}}=[])
    tags = tags |> parsetags

    try
        result = mlfpost(instance, "runs/create"; experiment_id=experiment_id,
            run_name=run_name, start_time=start_time, tags=tags)
        return result["run"] |> Run
    catch e
        throw(e)
    end
end
