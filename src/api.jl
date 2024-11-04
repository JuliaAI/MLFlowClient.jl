"""
    uri(mlf::MLFlow, endpoint::String; parameters=missing)

Retrieves an URI based on `mlf`, `endpoint`, and, optionally, `parameters`.

# Examples
```@example
MLFlowClient.uri(mlf, "experiments/get", Dict(:experiment_id=>10))
```
"""
uri(mlf::MLFlow, endpoint::String;
    parameters::Dict{Symbol, <:Any}=Dict{Symbol, NumberOrString}()) =
    URI("$(mlf.apiroot)/$(mlf.apiversion)/mlflow/$(endpoint)"; query=parameters)

"""
    headers(mlf::MLFlow,custom_headers::AbstractDict)

Retrieves HTTP headers based on `mlf` and merges with user-provided `custom_headers`

# Examples
```@example
headers(mlf,Dict("Content-Type"=>"application/json"))
```
"""
headers(mlf::MLFlow, custom_headers::AbstractDict) = merge(mlf.headers, custom_headers)

"""
    mlfget(mlf, endpoint; kwargs...)

Performs a HTTP GET to a specified endpoint. kwargs are turned into GET params.
"""
function mlfget(mlf, endpoint; kwargs...)
    apiuri = uri(mlf, endpoint;
        parameters=Dict(k => v for (k, v) in kwargs if v !== missing))
    apiheaders = headers(mlf, ("Content-Type" => "application/json") |> Dict)

    try
        response = HTTP.get(apiuri, apiheaders)
        return response.body |> String |> JSON.parse
    catch e
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) -  $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end

"""
    mlfpost(mlf, endpoint; kwargs...)

Performs a HTTP POST to the specified endpoint. kwargs are converted to JSON and become the
POST body.
"""
function mlfpost(mlf, endpoint; kwargs...)
    apiuri = uri(mlf, endpoint;)
    apiheaders = headers(mlf, Dict("Content-Type" => "application/json"))
    body = JSON.json(kwargs)

    try
        response = HTTP.post(apiuri, apiheaders, body)
        return response.body |> String |> JSON.parse
    catch e
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) -  $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end

"""
    mlfpatch(mlf, endpoint; kwargs...)

Performs a HTTP PATCH to the specified endpoint. kwargs are converted to JSON and become
the PATCH body.
"""
function mlfpatch(mlf, endpoint; kwargs...)
    apiuri = uri(mlf, endpoint;)
    apiheaders = headers(mlf, Dict("Content-Type" => "application/json"))
    body = JSON.json(kwargs)

    try
        response = HTTP.patch(apiuri, apiheaders, body)
        return response.body |> String |> JSON.parse
    catch e
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) -  $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end

"""
    mlfdelete(mlf, endpoint; kwargs...)

Performs a HTTP DELETE to the specified endpoint. kwargs are converted to JSON and become
the DELETE body.
"""
function mlfdelete(mlf, endpoint; kwargs...)
    apiuri = uri(mlf, endpoint;
        parameters=Dict(k => v for (k, v) in kwargs if v !== missing))
    apiheaders = headers(mlf, Dict("Content-Type" => "application/json"))
    body = JSON.json(kwargs)

    try
        response = HTTP.delete(apiuri, apiheaders, body)
        return response.body |> String |> JSON.parse
    catch e
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) -  $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end
