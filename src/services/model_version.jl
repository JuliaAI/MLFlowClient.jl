"""
    getlatestmodelversions(instance::MLFlow, name::String;
        stages::Array{String}=String[])

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `stages:` List of stages.

# Returns
Latest [`ModelVersion`](@ref) for each requests stage.
"""
function getlatestmodelversions(instance::MLFlow, name::String;
    stages::Array{String}=String[])::Array{ModelVersion}
    result = mlfpost(instance, "registered-models/get-latest-versions"; name=name,
        stages=stages)
    return result["model_versions"] .|> ModelVersion
end

"""
    createmodelversion(instance::MLFlow, name::String, source::String;
        run_id::Union{String, Missing}=missing, tags::MLFlowUpsertData{Tag}=Tag[],
        run_link::Union{String, Missing}=missing,
        description::Union{String, Missing}=missing)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` Register model under this name.
- `source:` URI indicating the location of the model artifacts.
- `run_id`: [`Run`](@ref) id for correlation.
- `tags:` List of [`Tag`](@ref) to associate with the model version.
- `run_link:` Link to the [`Run`](@ref) that generated the [`ModelVersion`](@ref).
- `description:` Optional description for [`ModelVersion`](@ref).

# Returns
[`ModelVersion`](@ref) created.
"""
function createmodelversion(instance::MLFlow, name::String, source::String;
    run_id::Union{String, Missing}=missing, tags::MLFlowUpsertData{Tag}=Tag[],
    run_link::Union{String, Missing}=missing,
    description::Union{String, Missing}=missing)::ModelVersion
    result = mlfpost(instance, "model-versions/create"; name=name, source=source,
        run_id=run_id, tags=parse(Tag, tags), run_link=run_link, description=description)
    return result["model_version"] |> ModelVersion
end

"""
    getmodelversion(instance::MLFlow, name::String, version::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` Name of the [`RegisteredModel`](@ref).
- `version:` [`ModelVersion`](@ref) number.

# Returns
[`ModelVersion`](@ref) requested.
"""
function getmodelversion(instance::MLFlow, name::String, version::String)::ModelVersion
    result = mlfget(instance, "model-versions/get"; name=name, version=version)
    return result["model_version"] |> ModelVersion
end

"""
    updatemodelversion(instance::MLFlow, name::String, version::String;
        description::Union{String, Missing}=missing)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` Name of the [`RegisteredModel`](@ref).
- `version:` [`ModelVersion`](@ref) number.
- `description:` Optional description for [`ModelVersion`](@ref).

# Returns
[`ModelVersion`](@ref) generated for this model in registry.
"""
function updatemodelversion(instance::MLFlow, name::String, version::String;
    description::Union{String, Missing}=missing)::ModelVersion
    result = mlfpatch(instance, "model-versions/update"; name=name, version=version,
        description=description)
    return result["model_version"] |> ModelVersion
end

"""
    deletemodelversion(instance::MLFlow, name::String, version::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` Name of the [`RegisteredModel`](@ref).
- `version:` [`ModelVersion`](@ref) number.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletemodelversion(instance::MLFlow, name::String, version::String)::Bool
    mlfdelete(instance, "model-versions/delete"; name=name, version=version)
    return true
end

"""
    searchmodelversions(instance::MLFlow, filter::String, max_results::Int64,
        order_by::String, page_token::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `filter`: String filter condition. See [MLFlow documentation](https://mlflow.org/docs/latest/rest-api.html#search-modelversions).
- `max_results`: Maximum number of models desired.
- `order_by`: List of columns to be ordered by including model name, version, stage with an
    optional “DESC” or “ASC” annotation, where “ASC” is the default. Tiebreaks are done by
    latest stage transition timestamp, followed by name ASC, followed by version DESC.
- `page_token`: Pagination token to go to next page based on previous search query.

# Returns
- Vector of [`ModelVersion`](@ref) that were found in the [`MLFlow`](@ref) instance.
- The next page token if there are more results.
"""
function searchmodelversions(instance::MLFlow; filter::String="",
    max_results::Int64=200000, order_by::Array{String}=String[],
    page_token::String="")::Tuple{Array{ModelVersion}, Union{String, Nothing}}
    parameters = (; max_results, page_token, filter)

    if order_by |> !isempty
        parameters = (; order_by, parameters...)
    end

    result = mlfget(instance, "model-versions/search"; parameters...)

    model_versions = get(result, "model_versions", []) |> (x -> [ModelVersion(y) for y in x])
    next_page_token = get(result, "next_page_token", nothing)

    return model_versions, next_page_token
end

"""
    getdownloaduriformodelversionartifacts(instance::MLFlow, name::String, version::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` Name of the [`RegisteredModel`](@ref).
- `version:` [`ModelVersion`](@ref) number.

# Returns
URI corresponding to where artifacts for this [`ModelVersion`](@ref) are stored.
"""
function getdownloaduriformodelversionartifacts(instance::MLFlow, name::String,
    version::String)::String
    result = mlfget(instance, "model-versions/get-download-uri"; name=name, version=version)
    return result["artifact_uri"]
end

"""
    transitionmodelversionstage(instance::MLFlow, name::String, version::String,
        stage::String, archive_existing_versions::Bool)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` Name of the [`RegisteredModel`](@ref).
- `version:` [`ModelVersion`](@ref) number.
- `stage:` Transition [`ModelVersion`](@ref) to new stage.
- `archive_existing_versions:` When transitioning a model version to a particular stage,
    this flag dictates whether all existing model versions in that stage should be atomically
    moved to the “archived” stage. This ensures that at-most-one model version exists in the
    target stage.

# Returns
Updated [`ModelVersion`](@ref).
"""
function transitionmodelversionstage(instance::MLFlow, name::String, version::String,
    stage::String, archive_existing_versions::Bool)::ModelVersion
    result = mlfpost(instance, "model-versions/transition-stage"; name=name,
        version=version, stage=stage, archive_existing_versions=archive_existing_versions)
    return result["model_version"] |> ModelVersion
end
