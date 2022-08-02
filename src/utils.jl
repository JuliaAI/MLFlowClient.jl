"""
    uri(mlf::MLFlow, endpoint="", query=missing)

Retrieves an URI based on `mlf`, `endpoint`, and, optionally, `query`.

# Examples
```@example
MLFlowClient.uri(mlf, "experiments/get", Dict(:experiment_id=>10))
```
"""
function uri(mlf::MLFlow, endpoint="", query=missing)
    u = URI("$(mlf.baseuri)/api/$(mlf.apiversion)/mlflow/$(endpoint)")
    !ismissing(query) && return URI(u; query=query)
    u
end

"""
    headers(mlf::MLFlow,custom_headers::AbstractDict)

Retrieves HTTP headers based on `mlf` and merges with user-provided `custom_headers`

# Examples
```@example
headers(mlf,Dict("Content-Type"=>"application/json"))
```
"""
headers(mlf::MLFlow,custom_headers::AbstractDict)=merge(mlf.headers, custom_headers)

"""
    mlfget(mlf, endpoint; kwargs...)

Performs a HTTP GET to a specifid endpoint. kwargs are turned into GET params.
"""
function mlfget(mlf, endpoint; kwargs...)
    apiuri = uri(mlf, endpoint, kwargs)
    apiheaders = headers(mlf,Dict("Content-Type"=>"application/json"))
    try
        response = HTTP.get(apiuri, apiheaders)
        return JSON.parse(String(response.body))
    catch e
        throw(e)
    end
end

"""
    mlfpost(mlf, endpoint; kwargs...)

Performs a HTTP POST to the specified endpoint. kwargs are converted to JSON and become the POST body.
"""
function mlfpost(mlf, endpoint; kwargs...)
    apiuri = uri(mlf, endpoint)
    apiheaders = headers(mlf,Dict("Content-Type"=>"application/json"))
    body = JSON.json(kwargs)
    try
        response = HTTP.post(apiuri, apiheaders, body)
        return JSON.parse(String(response.body))
    catch e
        throw(e)
    end
end

"""
    generatefilterfromparams(filter_params::AbstractDict{K,V}) where {K,V}

Generates a `filter` string from `filter_params` dictionary.

# Arguments
- `filter_params`: dictionary to use for filter generation.

# Returns
A string that can be passed as `filter` to [`searchruns`](@ref).

# Examples

```@example
generatefilterfromparams(Dict("paramkey1" => "paramvalue1", "paramkey2" => "paramvalue2"))
```
"""
function generatefilterfromparams(filter_params::AbstractDict{K,V}) where {K,V}
    length(filter_params) > 0 || return ""
    # NOTE: may have issues with escaping.
    filters = ["param.\"$(k)\" = \"$(v)\"" for(k, v) ∈ filter_params]
    join(filters, " and ")
end
