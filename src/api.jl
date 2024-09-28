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

"""
    mlfput_artifact(mlf, artifact_uri, filename, data)

Performs a HTTP PUT to upload the specified artifact.
Assumes that the artifact store is hosted in the mlflow server.
"""
function mlfput_artifact(mlf, artifact_uri, filename, data)
    artifact_path = chopprefix(artifact_uri, "mlflow-artifacts:/")
    if artifact_path == artifact_uri
        error("Artifact URI must start with `mlflow-artifacts:/`")
    end
    content_type = guess_mime(filename).mime
    apiuri = URI("$(mlf.apiroot)/$(mlf.apiversion)/mlflow-artifacts/artifacts/$(artifact_path)/$(filename)")
    apiheaders = headers(mlf, Dict("Content-Type" => content_type))
    try
        response = HTTP.put(apiuri, apiheaders, data)
        return JSON.parse(String(response.body))
    catch e
        throw(e)
    end
end
