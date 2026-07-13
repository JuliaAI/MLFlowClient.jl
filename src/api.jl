"""
    uri(mlf::MLFlow, endpoint::String; parameters=missing)

Retrieves an URI based on `mlf`, `endpoint`, and, optionally, `parameters`.

# Examples
```@example
MLFlowClient.uri(mlf, "experiments/get", Dict(:experiment_id=>10))
```
"""
uri(mlf::MLFlow, endpoint::String;
    parameters::Dict{Symbol,<:Any}=Dict{Symbol,NumberOrString}()) =
    URI("$(mlf.apiroot)/$(mlf.apiversion)/mlflow/$(endpoint)"; query=parameters)

"""
    uri_artifacts(mlf::MLFlow, endpoint::String; parameters=missing)

Retrieves an URI for mlflow-artifacts endpoints.

# Examples
```@example
MLFlowClient.uri_artifacts(mlf, "artifacts/path/to/file")
```
"""
uri_artifacts(mlf::MLFlow, endpoint::String;
    parameters::Dict{Symbol,<:Any}=Dict{Symbol,NumberOrString}()) =
    URI("$(mlf.apiroot)/$(mlf.apiversion)/mlflow-artifacts/$(endpoint)"; query=parameters)

"""
    uri_v3(mlf::MLFlow, endpoint::String; parameters=missing)

Retrieves an URI for API version 3.0.

# Examples
```@example
MLFlowClient.uri_v3(mlf, "scorers/register", Dict(:experiment_id=>10))
```
"""
uri_v3(mlf::MLFlow, endpoint::String;
    parameters::Dict{Symbol,<:Any}=Dict{Symbol,NumberOrString}()) =
    URI("$(mlf.apiroot)/3.0/mlflow/$(endpoint)"; query=parameters)

"""
    headers(mlf::MLFlow,custom_headers::AbstractDict)

Retrieves HTTP headers based on `mlf` and merges with user-provided `custom_headers`.

`Connection: close` is set by default so each request uses a fresh connection. MLflow's
server (gunicorn) closes idle keep-alive connections after a couple of seconds, while the
HTTP client keeps them pooled for much longer; reusing such a stale connection surfaces as
`unexpected EOF while reading HTTP/1 data`. Disabling reuse avoids that class of error.

# Examples
```@example
headers(mlf,Dict("Content-Type"=>"application/json"))
```
"""
headers(mlf::MLFlow, custom_headers::AbstractDict) =
    merge(Dict("Connection" => "close"), mlf.headers, custom_headers)

"""
    mlfget(mlf, endpoint; kwargs...)

Performs a HTTP GET to a specified endpoint. kwargs are turned into GET params.
"""
function mlfget(mlf, endpoint; kwargs...)
    apiuri = uri(mlf, endpoint;
        parameters=Dict{Symbol,Any}(k => v for (k, v) in kwargs if v !== missing))
    apiheaders = headers(mlf, ("Content-Type" => "application/json") |> Dict)

    try
        response = HTTP.get(apiuri, apiheaders)
        return response.body |> String |> JSON.parse
    catch e
        # Only HTTP error responses (4xx/5xx) carry a `.response` with an MLflow error
        # body; connection/parse errors (e.g. HTTP.ParseError) do not, so rethrow those
        # instead of masking them with a FieldError on `e.response`.
        e isa HTTP.StatusError || rethrow()
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
        # Only HTTP error responses (4xx/5xx) carry a `.response` with an MLflow error
        # body; connection/parse errors (e.g. HTTP.ParseError) do not, so rethrow those
        # instead of masking them with a FieldError on `e.response`.
        e isa HTTP.StatusError || rethrow()
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
        # Only HTTP error responses (4xx/5xx) carry a `.response` with an MLflow error
        # body; connection/parse errors (e.g. HTTP.ParseError) do not, so rethrow those
        # instead of masking them with a FieldError on `e.response`.
        e isa HTTP.StatusError || rethrow()
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
        parameters=Dict{Symbol,Any}(k => v for (k, v) in kwargs if v !== missing))
    apiheaders = headers(mlf, Dict("Content-Type" => "application/json"))
    body = JSON.json(kwargs)

    try
        response = HTTP.delete(apiuri, apiheaders, body)
        response_body = response.body |> String
        # Some v3 endpoints (e.g. workspaces/delete) return an empty body on success.
        return isempty(strip(response_body)) ? Dict{String,Any}() : JSON.parse(response_body)
    catch e
        # Only HTTP error responses (4xx/5xx) carry a `.response` with an MLflow error
        # body; connection/parse errors (e.g. HTTP.ParseError) do not, so rethrow those
        # instead of masking them with a FieldError on `e.response`.
        e isa HTTP.StatusError || rethrow()
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) -  $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end

"""
    mlfget_v3(mlf, endpoint; kwargs...)

Performs a HTTP GET to a specified endpoint using API version 3.0. kwargs are turned into GET params.
"""
function mlfget_v3(mlf, endpoint; kwargs...)
    apiuri = uri_v3(mlf, endpoint;
        parameters=Dict{Symbol,Any}(k => v for (k, v) in kwargs if v !== missing))
    apiheaders = headers(mlf, ("Content-Type" => "application/json") |> Dict)

    try
        response = HTTP.get(apiuri, apiheaders)
        return response.body |> String |> JSON.parse
    catch e
        # Only HTTP error responses (4xx/5xx) carry a `.response` with an MLflow error
        # body; connection/parse errors (e.g. HTTP.ParseError) do not, so rethrow those
        # instead of masking them with a FieldError on `e.response`.
        e isa HTTP.StatusError || rethrow()
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) -  $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end

"""
    mlfpost_v3(mlf, endpoint; kwargs...)

Performs a HTTP POST to the specified endpoint using API version 3.0. kwargs are converted to JSON and become the
POST body.
"""
function mlfpost_v3(mlf, endpoint; kwargs...)
    apiuri = uri_v3(mlf, endpoint;)
    apiheaders = headers(mlf, Dict("Content-Type" => "application/json"))
    body = JSON.json(kwargs)

    try
        response = HTTP.post(apiuri, apiheaders, body)
        return response.body |> String |> JSON.parse
    catch e
        # Only HTTP error responses (4xx/5xx) carry a `.response` with an MLflow error
        # body; connection/parse errors (e.g. HTTP.ParseError) do not, so rethrow those
        # instead of masking them with a FieldError on `e.response`.
        e isa HTTP.StatusError || rethrow()
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) -  $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end

"""
    mlfpatch_v3(mlf, endpoint; kwargs...)

Performs a HTTP PATCH to the specified endpoint using API version 3.0. kwargs are converted to JSON and become
the PATCH body.
"""
function mlfpatch_v3(mlf, endpoint; kwargs...)
    apiuri = uri_v3(mlf, endpoint;)
    apiheaders = headers(mlf, Dict("Content-Type" => "application/json"))
    body = JSON.json(kwargs)

    try
        response = HTTP.patch(apiuri, apiheaders, body)
        return response.body |> String |> JSON.parse
    catch e
        # Only HTTP error responses (4xx/5xx) carry a `.response` with an MLflow error
        # body; connection/parse errors (e.g. HTTP.ParseError) do not, so rethrow those
        # instead of masking them with a FieldError on `e.response`.
        e isa HTTP.StatusError || rethrow()
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) -  $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end

"""
    mlfdelete_v3(mlf, endpoint; kwargs...)

Performs a HTTP DELETE to the specified endpoint using API version 3.0. kwargs are converted to JSON and become
the DELETE body.
"""
function mlfdelete_v3(mlf, endpoint; kwargs...)
    apiuri = uri_v3(mlf, endpoint;
        parameters=Dict{Symbol,Any}(k => v for (k, v) in kwargs if v !== missing))
    apiheaders = headers(mlf, Dict("Content-Type" => "application/json"))
    body = JSON.json(kwargs)

    try
        response = HTTP.delete(apiuri, apiheaders, body)
        response_body = response.body |> String
        # Some v3 endpoints (e.g. workspaces/delete) return an empty body on success.
        return isempty(strip(response_body)) ? Dict{String,Any}() : JSON.parse(response_body)
    catch e
        # Only HTTP error responses (4xx/5xx) carry a `.response` with an MLflow error
        # body; connection/parse errors (e.g. HTTP.ParseError) do not, so rethrow those
        # instead of masking them with a FieldError on `e.response`.
        e isa HTTP.StatusError || rethrow()
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) -  $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end