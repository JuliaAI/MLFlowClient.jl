"""
    getmetrichistory(instance::MLFlow, run_id::String, metric_key::String;
        page_token::String="", max_results::Union{Int64, Missing}=missing)

Get a list of all values for the specified [`Metric`](@ref) for a given [`Run`](@ref).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the [`Run`](@ref) from which to fetch [`Metric`](@ref) values.
- `metric_key`: Name of the [`Metric`](@ref) to fetch.
- `page_token`: Token indicating the page of [`Metric`](@ref) history to fetch.
- `max_results`: Maximum number of logged instances of a [`Metric`](@ref) for a
    [`Run`](@ref) to return per call.

# Returns
- A list of all historical values for the specified [`Metric`](@ref) in the specified
    [`Run`](@ref).
- The next page token if there are more results.
"""
function getmetrichistory(instance::MLFlow, run_id::String, metric_key::String;
    page_token::String="", max_results::Union{Int64, Missing}=missing
)::Tuple{Array{Metric}, Union{String, Nothing}}
    result = mlfget(instance, "metrics/get-history"; run_id=run_id, metric_key=metric_key,
        page_token=page_token,
        max_results=(ismissing(max_results) ? max_results : (max_results |> Int32)))

    metrics = result["metrics"] |> (x -> [Metric(y) for y in x])
    next_page_token = get(result, "next_page_token", nothing)

    return metrics, next_page_token
end
getmetrichistory(instance::MLFlow, run::Run, metric_key::String; page_token::String="",
    max_results::Union{Int64, Missing}=missing
)::Tuple{Array{Metric}, Union{String, Nothing}} =
    getmetrichistory(instance, run.info.run_id, metric_key; page_token=page_token,
        max_results=max_results)
getmetrichistory(instance::MLFlow, run::Run, metric::Metric; page_token::String="",
    max_results::Union{Int64, Missing}=missing
)::Tuple{Array{Metric}, Union{String, Nothing}} =
    getmetrichistory(instance, run.info.run_id, metric.key; page_token=page_token,
        max_results=max_results)

"""
    refresh(instance::MLFlow, run::Run)
    refresh(instance::MLFlow, experiment::Experiment)

Get the latest metadata for a [`Run`](@ref) or [`Experiment`](@ref).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run` or `experiment`: [`Run`](@ref) or [`Experiment`](@ref) to refresh.

# Returns
An instance of type [`Run`](@ref) or [`Experiment`](@ref).
"""
refresh(instance::MLFlow, experiment::Experiment)::Experiment =
    getexperiment(instance, experiment.experiment_id)
refresh(instance::MLFlow, run::Run)::Run = getrun(instance, run.info.run_id)
