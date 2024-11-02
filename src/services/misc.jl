"""
    getmetrichistory(instance::MLFlow, run_id::String, metric_key::String;
        page_token::String="", max_results::Int32=1)

Get a list of all values for the specified metric for a given run.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the run from which to fetch metric values.
- `metric_key`: Name of the metric.
- `page_token`: Token indicating the page of metric history to fetch.
- `max_results`: Maximum number of logged instances of a metric for a run to 
return per call.

# Returns
- A list of all metric historical values for the specified metric in the
specified run.
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
