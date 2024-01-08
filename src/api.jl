"""
    mlfget(mlf, endpoint; kwargs...)

Performs a HTTP GET to a specified endpoint. kwargs are turned into GET params.
"""
function mlfget(mlf, endpoint; kwargs...)
    apiuri = uri(mlf, endpoint, kwargs)
    apiheaders = headers(mlf, Dict("Content-Type" => "application/json"))

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
    apiheaders = headers(mlf, Dict("Content-Type" => "application/json"))
    body = JSON.json(kwargs)

    try
        response = HTTP.post(apiuri, apiheaders, body)
        return JSON.parse(String(response.body))
    catch e
        throw(e)
    end
end