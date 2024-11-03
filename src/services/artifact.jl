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
    page_token::String="")::Tuple{String, Array{FileInfo}, Union{String, Nothing}}
    result = mlfget(instance, "artifacts/list"; run_id=run_id, path=path,
        page_token=page_token)

    root_uri = get(result, "root_uri", "")
    files = get(result, "files", []) |> (x -> [FileInfo(y) for y in x])
    next_page_token = get(result, "next_page_token", nothing)

    return root_uri, files, next_page_token
end
listartifacts(instance::MLFlow, run::Run; path::String="", page_token::String="") =
    listartifacts(instance, run.info.run_id; path=path, page_token=page_token)
