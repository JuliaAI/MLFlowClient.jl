"""
    createregisteredmodel(instance::MLFlow, name::String;
        tags::MLFlowUpsertData{Tag}=Tag[], description::Union{String, Missing}=missing)

Create a [`RegisteredModel`](@ref) with a name. Returns the newly created
[`RegisteredModel`](@ref). Validates that another [`RegisteredModel`](@ref) with the same
name does not already exist and fails if another [`RegisteredModel`](@ref) with the same
name already exists.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: Register models under this name.
- `tags`: A collection of [`Tag`](@ref).
- `description`: Optional description for [`RegisteredModel`](@ref).

# Returns
An instance of type [`RegisteredModel`](@ref).
"""
function createregisteredmodel(instance::MLFlow, name::String;
    tags::MLFlowUpsertData{Tag}=Tag[], description::Union{String,Missing}=missing,
    deployment_job_id::Union{String,Missing}=missing)::RegisteredModel
    result = mlfpost(instance, "registered-models/create"; name=name,
        tags=parse(Tag, tags), description=description,
        deployment_job_id=deployment_job_id)
    return result["registered_model"] |> RegisteredModel
end

"""
    getregisteredmodel(instance::MLFlow, name::String)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: [`RegisteredModel`](@ref) model unique name identifier.

# Returns
An instance of type [`RegisteredModel`](@ref).
"""
function getregisteredmodel(instance::MLFlow, name::String)::RegisteredModel
    result = mlfget(instance, "registered-models/get"; name=name)
    return result["registered_model"] |> RegisteredModel
end

"""
    renameregisteredmodel(instance::MLFlow, name::String, new_name::String)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: [`RegisteredModel`](@ref) unique name identifier.
- `new_name`: If provided, updates the name for this [`RegisteredModel`](@ref).

# Returns
An instance of type [`RegisteredModel`](@ref).
"""
function renameregisteredmodel(instance::MLFlow, name::String,
    new_name::String)::RegisteredModel
    result = mlfpost(instance, "registered-models/rename"; name=name, new_name=new_name)
    return result["registered_model"] |> RegisteredModel
end

"""
    updateregisteredmodel(instance::MLFlow, name::String;
        description::Union{String, Missing}=missing)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: [`RegisteredModel`](@ref) unique name identifier.
- `description`: If provided, updates the description for this [`RegisteredModel`](@ref).

# Returns
An instance of type [`RegisteredModel`](@ref).
"""
function updateregisteredmodel(instance::MLFlow, name::String;
    description::Union{String,Missing}=missing)::RegisteredModel
    result = mlfpatch(instance, "registered-models/update"; name=name,
        description=description)
    return result["registered_model"] |> RegisteredModel
end

"""
    deleteregisteredmodel(instance::MLFlow, name::String)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: [`RegisteredModel`](@ref) unique name identifier.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deleteregisteredmodel(instance::MLFlow, name::String)::Bool
    mlfdelete(instance, "registered-models/delete"; name=name)
    return true
end

"""
    searchregisteredmodels(instance::MLFlow, filter::String, max_results::Int64,
        order_by::String, page_token::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `filter`: String filter condition. See [MLFlow documentation](https://mlflow.org/docs/latest/rest-api.html#search-registeredmodels).
- `max_results`: Maximum number of models desired.
- `order_by`: List of columns for ordering search results, which can include model name
    and last updated timestamp with an optional “DESC” or “ASC” annotation, where “ASC” is
    the default. Tiebreaks are done by model name ASC.
- `page_token`: Pagination token to go to the next page based on a previous search query.

# Returns
- Vector of [`RegisteredModel`](@ref) that were found in the [`MLFlow`](@ref) instance.
- The next page token if there are more results.
"""
function searchregisteredmodels(instance::MLFlow; filter::String="",
    max_results::Int64=100, order_by::Array{String}=String[],
    page_token::String="")::Tuple{Array{RegisteredModel},Union{String,Nothing}}
    parameters = (; max_results, page_token, filter)

    if order_by |> !isempty
        parameters = (; order_by, parameters...)
    end

    result = mlfget(instance, "registered-models/search"; parameters...)

    registered_models = get(result, "registered_models", []) |> (x -> [RegisteredModel(y) for y in x])
    next_page_token = get(result, "next_page_token", nothing)

    return registered_models, next_page_token
end

"""
    setregisteredmodeltag(instance::MLFlow, name::String, key::String, value::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` Unique name of the model.
- `key:` Name of the [`Tag`](@ref).
- `value:` String value of the [`Tag`](@ref) being logged.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function setregisteredmodeltag(instance::MLFlow, name::String, key::String, value::String)::Bool
    mlfpost(instance, "registered-models/set-tag"; name=name, key=key, value=value)
    return true
end

"""
    deleteregisteredmodeltag(instance::MLFlow, name::String, key::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` Name of the [`RegisteredModel`](@ref) that the tag was logged under.
- `key:` Name of the [`Tag`](@ref).

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deleteregisteredmodeltag(instance::MLFlow, name::String, key::String)::Bool
    mlfdelete(instance, "registered-models/delete-tag"; name=name, key=key)
    return true
end

"""
    deleteregisteredmodelalias(instance::MLFlow, name::String, alias::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` Name of the [`RegisteredModel`](@ref).
- `alias:` Name of the alias.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deleteregisteredmodelalias(instance::MLFlow, name::String, alias::String)::Bool
    mlfdelete(instance, "registered-models/alias"; name=name, alias=alias)
    return true
end

"""
    setregisteredmodelalias(instance::MLFlow, name::String, alias::String, version::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` Name of the [`RegisteredModel`](@ref).
- `alias:` Name of the alias.
- `version:` [`ModelVersion`](@ref) number.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function setregisteredmodelalias(instance::MLFlow, name::String, alias::String,
    version::String)::Bool
    mlfpost(instance, "registered-models/alias"; name=name, alias=alias, version=version)
    return true
end

"""
    createregisteredmodelpermission(instance::MLFlow, name::String, username::String,
        permission::Permission)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` [`RegisteredModel`](@ref) name.
- `username:` [`User`](@ref) username.
- `permission:` [`Permission`](@ref) to grant.

# Returns
An instance of type [`RegisteredModelPermission`](@ref).
"""
function createregisteredmodelpermission(instance::MLFlow, name::String, username::String,
    permission::Permission.PermissionEnum)::RegisteredModelPermission
    result = mlfpost(instance, "registered-models/permissions/create"; name=name,
        username=username, permission=permission)
    return result["registered_model_permission"] |> RegisteredModelPermission
end

"""
    getregisteredmodelpermission(instance::MLFlow, name::String, username::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` [`RegisteredModel`](@ref) name.
- `username:` [`User`](@ref) username.

# Returns
An instance of type [`RegisteredModelPermission`](@ref).
"""
function getregisteredmodelpermission(instance::MLFlow, name::String,
    username::String)::RegisteredModelPermission
    result = mlfget(instance, "registered-models/permissions/get"; name=name,
        username=username)
    return result["registered_model_permission"] |> RegisteredModelPermission
end

"""
    updateregisteredmodelpermission(instance::MLFlow, name::String, username::String,
        permission::Permission)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` [`RegisteredModel`](@ref) name.
- `username:` [`User`](@ref) username.
- `permission:` New [`Permission`](@ref) to grant.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function updateregisteredmodelpermission(instance::MLFlow, name::String, username::String,
    permission::Permission.PermissionEnum)::Bool
    mlfpatch(instance, "registered-models/permissions/update"; name=name, username=username,
        permission=permission)
    return true
end

"""
    deleteregisteredmodelpermission(instance::MLFlow, name::String, username::String)

# Arguments
- `instance:` [`MLFlow`](@ref) configuration.
- `name:` [`RegisteredModel`](@ref) name.
- `username:` [`User`](@ref) username.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deleteregisteredmodelpermission(instance::MLFlow, name::String,
    username::String)::Bool
    mlfdelete(instance, "registered-models/permissions/delete"; name=name,
        username=username)
    return true
end
