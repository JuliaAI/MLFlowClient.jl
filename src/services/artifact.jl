"""
    listartifacts(instance::MLFlow, run_id::String; path::String="", page_token::String="")
    listartifacts(instance::MLFlow, run::Run; path::String="", page_token::String="")

List artifacts for a [`Run`](@ref).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `run_id`: ID of the [`Run`](@ref) whose artifacts to list.
- `path`: Filter artifacts matching this path (a relative path from the root artifact
    directory).
- `page_token`: Token indicating the page of artifact results to fetch

# Returns
- Root artifact directory for the [`Run`](@ref).
- List of file location and metadata for artifacts.
- Token that can be used to retrieve the next page of artifact results.
"""
function listartifacts(instance::MLFlow, run_id::String; path::String="",
    page_token::String="")::Tuple{String,Array{FileInfo},Union{String,Nothing}}
    result = mlfget(instance, "artifacts/list"; run_id=run_id, path=path,
        page_token=page_token)

    root_uri = get(result, "root_uri", "")
    files = get(result, "files", []) |> (x -> [FileInfo(y) for y in x])
    next_page_token = get(result, "next_page_token", nothing)

    return root_uri, files, next_page_token
end
listartifacts(instance::MLFlow, run::Run; path::String="", page_token::String="") =
    listartifacts(instance, run.info.run_id; path=path, page_token=page_token)

"""
    downloadartifact(instance::MLFlow, artifact_path::String)

Download an artifact from the MLflow artifact repository.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `artifact_path`: Path of the artifact to download.

# Returns
Artifact binary data as a byte array.
"""
function downloadartifact(instance::MLFlow, artifact_path::String)::Vector{UInt8}
    apiuri = uri_artifacts(instance, "artifacts/$artifact_path")
    apiheaders = headers(instance, Dict("Content-Type" => "application/octet-stream"))

    try
        response = HTTP.get(apiuri, apiheaders)
        return response.body
    catch e
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) - $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end

"""
    uploadartifact(instance::MLFlow, artifact_path::String, data::Vector{UInt8})

Upload an artifact to the MLflow artifact repository.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `artifact_path`: Path where the artifact should be stored.
- `data`: Artifact binary data.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function uploadartifact(instance::MLFlow, artifact_path::String, data::Vector{UInt8})::Bool
    apiuri = uri_artifacts(instance, "artifacts/$artifact_path")
    apiheaders = headers(instance, Dict("Content-Type" => "application/octet-stream"))

    try
        HTTP.put(apiuri, apiheaders, data)
        return true
    catch e
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) - $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end

"""
    listartifactsdirect(instance::MLFlow; path::String="")

List artifacts directly from the MLflow artifact repository (not associated with a run).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `path`: Filter artifacts matching this path (a relative path from the root artifact directory).

# Returns
List of file location and metadata for artifacts.
"""
function listartifactsdirect(instance::MLFlow; path::String="")::Array{FileInfo}
    params = Dict{Symbol,Any}()
    !isempty(path) && (params[:path] = path)

    result = mlfget_artifacts(instance, "artifacts"; params...)
    return get(result, "files", []) |> (x -> [FileInfo(y) for y in x])
end

"""
    deleteartifact(instance::MLFlow, artifact_path::String)

Delete an artifact from the MLflow artifact repository.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `artifact_path`: Path of the artifact to delete.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deleteartifact(instance::MLFlow, artifact_path::String)::Bool
    apiuri = uri_artifacts(instance, "artifacts/$artifact_path")
    apiheaders = headers(instance, Dict("Content-Type" => "application/json"))

    try
        HTTP.delete(apiuri, apiheaders)
        return true
    catch e
        error_response = e.response.body |> String |> JSON.parse
        error_message = "$(error_response["error_code"]) - $(error_response["message"])"
        @error error_message
        throw(ErrorException(error_message))
    end
end

"""
    createmultipartupload(instance::MLFlow, artifact_path::String, num_parts::Int64)

Create a multipart upload for an artifact.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `artifact_path`: Path where the artifact should be stored.
- `num_parts`: Number of parts for the multipart upload.

# Returns
- `upload_id`: Upload ID for the multipart upload.
- `credentials`: Array of credentials for each part.
"""
function createmultipartupload(instance::MLFlow, artifact_path::String, num_parts::Int64)::Tuple{String,Array{MultipartUploadCredential}}
    result = mlfpost_artifacts(instance, "mpu/create/$artifact_path";
        path=artifact_path, num_parts=num_parts)

    upload_id = get(result, "upload_id", "")
    credentials = get(result, "credentials", []) .|> (x -> MultipartUploadCredential(x))

    return upload_id, credentials
end

"""
    completemultipartupload(instance::MLFlow, artifact_path::String, upload_id::String,
        parts::Array{MultipartUploadPart})

Complete a multipart upload.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `artifact_path`: Path of the artifact.
- `upload_id`: Upload ID for the multipart upload.
- `parts`: Array of uploaded parts with their part numbers and ETags.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function completemultipartupload(instance::MLFlow, artifact_path::String, upload_id::String,
    parts::Array{MultipartUploadPart})::Bool
    mlfpost_artifacts(instance, "mpu/complete/$artifact_path";
        path=artifact_path, upload_id=upload_id, parts=parts)
    return true
end

"""
    abortmultipartupload(instance::MLFlow, artifact_path::String, upload_id::String)

Abort a multipart upload.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `artifact_path`: Path of the artifact.
- `upload_id`: Upload ID for the multipart upload.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function abortmultipartupload(instance::MLFlow, artifact_path::String, upload_id::String)::Bool
    mlfpost_artifacts(instance, "mpu/abort/$artifact_path";
        path=artifact_path, upload_id=upload_id)
    return true
end

"""
    getpresigneddownloadurl(instance::MLFlow, artifact_path::String)

Get a presigned URL for downloading an artifact.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `artifact_path`: Path of the artifact.

# Returns
- `url`: The presigned URL for downloading the artifact.
- `headers`: Optional headers that must be included in the download request.
- `file_size`: Optional size of the file in bytes.
"""
function getpresigneddownloadurl(instance::MLFlow, artifact_path::String)::Tuple{String,Dict{String,String},Int64}
    result = mlfget_artifacts(instance, "presigned/artifacts/$artifact_path")

    url = get(result, "url", "")
    headers = get(result, "headers", Dict{String,String}())
    file_size = get(result, "file_size", 0) |> Int64

    return url, headers, file_size
end

"""
    mlfget_artifacts(mlf, endpoint; kwargs...)

Performs a HTTP GET to a specified mlflow-artifacts endpoint. kwargs are turned into GET params.
"""
function mlfget_artifacts(mlf, endpoint; kwargs...)
    apiuri = uri_artifacts(mlf, endpoint;
        parameters=Dict{Symbol,Any}(k => v for (k, v) in kwargs if v !== missing))
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
    mlfpost_artifacts(mlf, endpoint; kwargs...)

Performs a HTTP POST to the specified mlflow-artifacts endpoint. kwargs are converted to JSON and become the
POST body.
"""
function mlfpost_artifacts(mlf, endpoint; kwargs...)
    apiuri = uri_artifacts(mlf, endpoint;)
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
