"""
    uri(mlf::MLFlow, endpoint="", query=missing)

Retrieves an URI based on `mlf`, `endpoint`, and, optionally, `query`.

# Examples
``` julia-repl
julia> MLFlowClient.uri(mlf, "experiments/get", Dict(:experiment_id=>10))
URI("http://localhost/api/2.0/mlflow/experiments/get?experiment_id=10")
```
"""
function uri(mlf::MLFlow, endpoint="", query=missing)
    u = URI("$(mlf.baseuri)/api/$(mlf.apiversion)/mlflow/$(endpoint)")
    !ismissing(query) && return URI(u; query=query)
    u
end

"""
    mlfget(mlf, endpoint; kwargs...)

Performs a HTTP GET to a specifid endpoint. kwargs are turned into GET params.
"""
function mlfget(mlf, endpoint; kwargs...)
    apiuri = uri(mlf, endpoint, kwargs)
    headers = ["Content-Type: application/json"]
    try
        response = HTTP.get(apiuri, headers)
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
    headers = ["Content-Type: application/json"]
    body = JSON.json(kwargs)
    try
        response = HTTP.post(apiuri, headers, body)
        return JSON.parse(String(response.body))
    catch e
        throw(e)
    end
end

