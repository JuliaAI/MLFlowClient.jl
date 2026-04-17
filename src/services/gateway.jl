"""
    creategatewaysecret(instance::MLFlow, secret_name::String, secret_value::Array{Dict{String,String}};
        provider::Union{String,Missing}=missing, auth_config::Union{Array{Dict{String,String}},Missing}=missing,
        created_by::Union{String,Missing}=missing)

Create a new encrypted secret for LLM provider authentication.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `secret_name`: User-friendly name for the secret (must be unique).
- `secret_value`: The secret value(s) to encrypt as an array of key-value pairs.
  Example: `[Dict("key" => "api_key", "value" => "sk-xxx")]`
- `provider`: Optional LLM provider (e.g., "openai", "anthropic").
- `auth_config`: Optional provider-specific auth configuration as an array of key-value pairs.
- `created_by`: Username of the creator.

# Returns
An instance of type [`GatewaySecretInfo`](@ref).
"""
function creategatewaysecret(instance::MLFlow, secret_name::String, secret_value::Array{<:AbstractDict};
    provider::Union{String,Missing}=missing, auth_config::Union{Array{<:AbstractDict},Missing}=missing,
    created_by::Union{String,Missing}=missing)::GatewaySecretInfo
    params = Dict{Symbol,Any}(:secret_name => secret_name, :secret_value => secret_value)
    !ismissing(provider) && (params[:provider] = provider)
    !ismissing(auth_config) && (params[:auth_config] = auth_config)
    !ismissing(created_by) && (params[:created_by] = created_by)
    result = mlfpost_v3(instance, "gateway/secrets/create"; params...)
    return result["secret"] |> GatewaySecretInfo
end

"""
    getgatewaysecretinfo(instance::MLFlow; secret_id::Union{String,Missing}=missing,
        secret_name::Union{String,Missing}=missing)

Get metadata about a secret (does not include the encrypted value).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `secret_id`: Either secret_id or secret_name must be provided.
- `secret_name`: Either secret_id or secret_name must be provided.

# Returns
An instance of type [`GatewaySecretInfo`](@ref).
"""
function getgatewaysecretinfo(instance::MLFlow; secret_id::Union{String,Missing}=missing,
    secret_name::Union{String,Missing}=missing)::GatewaySecretInfo
    parameters = Dict{Symbol,Any}()
    if !ismissing(secret_id)
        parameters[:secret_id] = secret_id
    end
    if !ismissing(secret_name)
        parameters[:secret_name] = secret_name
    end
    result = mlfget_v3(instance, "gateway/secrets/get"; parameters...)
    return result["secret"] |> GatewaySecretInfo
end

"""
    updategatewaysecret(instance::MLFlow, secret_id::String;
        secret_value::Union{Array{<:AbstractDict},Missing}=missing,
        auth_config::Union{Array{<:AbstractDict},Missing}=missing,
        updated_by::Union{String,Missing}=missing)

Update an existing secret's value or auth configuration.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `secret_id`: ID of the secret to update.
- `secret_value`: Optional new secret value(s) as an array of key-value pairs.
- `auth_config`: Optional new auth configuration as an array of key-value pairs.
- `updated_by`: Username of the updater.

# Returns
An instance of type [`GatewaySecretInfo`](@ref).
"""
function updategatewaysecret(instance::MLFlow, secret_id::String;
    secret_value::Union{Array{<:AbstractDict},Missing}=missing,
    auth_config::Union{Array{<:AbstractDict},Missing}=missing,
    updated_by::Union{String,Missing}=missing)::GatewaySecretInfo
    params = Dict{Symbol,Any}(:secret_id => secret_id)
    !ismissing(secret_value) && (params[:secret_value] = secret_value)
    !ismissing(auth_config) && (params[:auth_config] = auth_config)
    !ismissing(updated_by) && (params[:updated_by] = updated_by)
    result = mlfpost_v3(instance, "gateway/secrets/update"; params...)
    return result["secret"] |> GatewaySecretInfo
end

"""
    deletegatewaysecret(instance::MLFlow, secret_id::String)

Delete a secret.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `secret_id`: ID of the secret to delete.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletegatewaysecret(instance::MLFlow, secret_id::String)::Bool
    mlfdelete_v3(instance, "gateway/secrets/delete"; secret_id=secret_id)
    return true
end

"""
    listgatewaysecretinfos(instance::MLFlow; provider::Union{String,Missing}=missing)

List all secrets with optional filtering by provider.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `provider`: Optional filter by provider (e.g., "openai", "anthropic").

# Returns
Vector of [`GatewaySecretInfo`](@ref) entities.
"""
function listgatewaysecretinfos(instance::MLFlow; provider::Union{String,Missing}=missing)::Array{GatewaySecretInfo}
    parameters = Dict{Symbol,Any}()
    if !ismissing(provider)
        parameters[:provider] = provider
    end
    result = mlfget_v3(instance, "gateway/secrets/list"; parameters...)
    return get(result, "secrets", []) |> (x -> [GatewaySecretInfo(y) for y in x])
end

## Model Definitions Management

"""
    creategatewaymodeldefinition(instance::MLFlow, name::String, secret_id::String,
        provider::String, model_name::String; created_by::Union{String,Missing}=missing)

Create a reusable model definition.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: User-friendly name for the model definition (must be unique).
- `secret_id`: ID of the secret containing authentication credentials.
- `provider`: LLM provider (e.g., "openai", "anthropic").
- `model_name`: Provider-specific model identifier.
- `created_by`: Username of the creator.

# Returns
An instance of type [`GatewayModelDefinition`](@ref).
"""
function creategatewaymodeldefinition(instance::MLFlow, name::String, secret_id::String,
    provider::String, model_name::String; created_by::Union{String,Missing}=missing)::GatewayModelDefinition
    result = mlfpost_v3(instance, "gateway/model-definitions/create";
        name=name, secret_id=secret_id, provider=provider,
        model_name=model_name, created_by=created_by)
    return result["model_definition"] |> GatewayModelDefinition
end

"""
    getgatewaymodeldefinition(instance::MLFlow, model_definition_id::String)

Get a model definition by ID.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `model_definition_id`: ID of the model definition to retrieve.

# Returns
An instance of type [`GatewayModelDefinition`](@ref).
"""
function getgatewaymodeldefinition(instance::MLFlow, model_definition_id::String)::GatewayModelDefinition
    result = mlfget_v3(instance, "gateway/model-definitions/get";
        model_definition_id=model_definition_id)
    return result["model_definition"] |> GatewayModelDefinition
end

"""
    listgatewaymodeldefinitions(instance::MLFlow; provider::Union{String,Missing}=missing)

List all model definitions with optional filters.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `provider`: Optional filter by provider.

# Returns
Vector of [`GatewayModelDefinition`](@ref) entities.
"""
function listgatewaymodeldefinitions(instance::MLFlow; provider::Union{String,Missing}=missing)::Array{GatewayModelDefinition}
    parameters = Dict{Symbol,Any}()
    if !ismissing(provider)
        parameters[:provider] = provider
    end
    result = mlfget_v3(instance, "gateway/model-definitions/list"; parameters...)
    return get(result, "model_definitions", []) |> (x -> [GatewayModelDefinition(y) for y in x])
end

"""
    updategatewaymodeldefinition(instance::MLFlow, model_definition_id::String;
        name::Union{String,Missing}=missing, secret_id::Union{String,Missing}=missing,
        model_name::Union{String,Missing}=missing, provider::Union{String,Missing}=missing,
        updated_by::Union{String,Missing}=missing)

Update a model definition.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `model_definition_id`: ID of the model definition to update.
- `name`: Optional new name.
- `secret_id`: Optional new secret ID.
- `model_name`: Optional new model name.
- `provider`: Optional new provider.
- `updated_by`: Username of the updater.

# Returns
An instance of type [`GatewayModelDefinition`](@ref).
"""
function updategatewaymodeldefinition(instance::MLFlow, model_definition_id::String;
    name::Union{String,Missing}=missing, secret_id::Union{String,Missing}=missing,
    model_name::Union{String,Missing}=missing, provider::Union{String,Missing}=missing,
    updated_by::Union{String,Missing}=missing)::GatewayModelDefinition
    result = mlfpost_v3(instance, "gateway/model-definitions/update";
        model_definition_id=model_definition_id, name=name, secret_id=secret_id,
        model_name=model_name, provider=provider, updated_by=updated_by)
    return result["model_definition"] |> GatewayModelDefinition
end

"""
    deletegatewaymodeldefinition(instance::MLFlow, model_definition_id::String)

Delete a model definition.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `model_definition_id`: ID of the model definition to delete.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletegatewaymodeldefinition(instance::MLFlow, model_definition_id::String)::Bool
    mlfdelete_v3(instance, "gateway/model-definitions/delete"; model_definition_id=model_definition_id)
    return true
end

## Endpoints Management

"""
    creategatewayendpoint(instance::MLFlow, name::String, model_configs::Array;
        created_by::Union{String,Missing}=missing, routing_strategy::Union{String,Missing}=missing,
        fallback_config::Union{Dict,Missing}=missing, experiment_id::Union{String,Missing}=missing,
        usage_tracking::Union{Bool,Missing}=missing)

Create a gateway endpoint.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: Name of the endpoint.
- `model_configs`: Array of model configurations. Each config should have:
  - `model_definition_id`: ID of the model definition
  - `linkage_type`: Type of linkage (e.g., "PRIMARY", "FALLBACK")
  - `weight`: Routing weight (optional)
  - `fallback_order`: Order for fallback (optional)
- `created_by`: Username of the creator.
- `routing_strategy`: Optional routing strategy for the endpoint.
- `fallback_config`: Optional fallback configuration.
- `experiment_id`: Optional experiment ID for tracing.
- `usage_tracking`: Whether to enable usage tracking (defaults to false).

# Returns
An instance of type [`GatewayEndpoint`](@ref).
"""
function creategatewayendpoint(instance::MLFlow, name::String, model_configs::Array;
    created_by::Union{String,Missing}=missing, routing_strategy::Union{String,Missing}=missing,
    fallback_config::Union{Dict,Missing}=missing, experiment_id::Union{String,Missing}=missing,
    usage_tracking::Union{Bool,Missing}=missing)
    params = Dict{Symbol,Any}(:name => name, :model_configs => model_configs)
    !ismissing(created_by) && (params[:created_by] = created_by)
    !ismissing(routing_strategy) && (params[:routing_strategy] = routing_strategy)
    !ismissing(fallback_config) && (params[:fallback_config] = fallback_config)
    !ismissing(experiment_id) && (params[:experiment_id] = experiment_id)
    !ismissing(usage_tracking) && (params[:usage_tracking] = usage_tracking)
    result = mlfpost_v3(instance, "gateway/endpoints/create"; params...)
    return result["endpoint"] |> GatewayEndpoint
end

"""
    getgatewayendpoint(instance::MLFlow, endpoint_id::String)

Get a gateway endpoint by ID.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_id`: ID of the endpoint to retrieve.

# Returns
An instance of type [`GatewayEndpoint`](@ref).
"""
function getgatewayendpoint(instance::MLFlow, endpoint_id::String)::GatewayEndpoint
    result = mlfget_v3(instance, "gateway/endpoints/get"; endpoint_id=endpoint_id)
    return result["endpoint"] |> GatewayEndpoint
end

"""
    updategatewayendpoint(instance::MLFlow, endpoint_id::String;
        name::Union{String,Missing}=missing,
        model_configs::Union{Array,Missing}=missing,
        routing_strategy::Union{String,Missing}=missing,
        fallback_config::Union{Dict,Missing}=missing,
        experiment_id::Union{String,Missing}=missing,
        usage_tracking::Union{Bool,Missing}=missing,
        updated_by::Union{String,Missing}=missing)

Update a gateway endpoint.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_id`: ID of the endpoint to update.
- `name`: Optional new name for the endpoint.
- `model_configs`: Optional new list of model configurations (replaces all existing).
- `routing_strategy`: Optional new routing strategy.
- `fallback_config`: Optional fallback configuration.
- `experiment_id`: Optional experiment ID for tracing.
- `usage_tracking`: Whether to enable usage tracking.
- `updated_by`: Username of the updater.

# Returns
An instance of type [`GatewayEndpoint`](@ref).
"""
function updategatewayendpoint(instance::MLFlow, endpoint_id::String;
    name::Union{String,Missing}=missing,
    model_configs::Union{Array,Missing}=missing,
    routing_strategy::Union{String,Missing}=missing,
    fallback_config::Union{Dict,Missing}=missing,
    experiment_id::Union{String,Missing}=missing,
    usage_tracking::Union{Bool,Missing}=missing,
    updated_by::Union{String,Missing}=missing)::GatewayEndpoint
    params = Dict{Symbol,Any}(:endpoint_id => endpoint_id)
    !ismissing(name) && (params[:name] = name)
    !ismissing(model_configs) && (params[:model_configs] = model_configs)
    !ismissing(routing_strategy) && (params[:routing_strategy] = routing_strategy)
    !ismissing(fallback_config) && (params[:fallback_config] = fallback_config)
    !ismissing(experiment_id) && (params[:experiment_id] = experiment_id)
    !ismissing(usage_tracking) && (params[:usage_tracking] = usage_tracking)
    !ismissing(updated_by) && (params[:updated_by] = updated_by)
    result = mlfpost_v3(instance, "gateway/endpoints/update"; params...)
    return result["endpoint"] |> GatewayEndpoint
end

"""
    deletegatewayendpoint(instance::MLFlow, endpoint_id::String)

Delete a gateway endpoint.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_id`: ID of the endpoint to delete.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletegatewayendpoint(instance::MLFlow, endpoint_id::String)::Bool
    mlfdelete_v3(instance, "gateway/endpoints/delete"; endpoint_id=endpoint_id)
    return true
end

"""
    listgatewayendpoints(instance::MLFlow; endpoint_type::Union{String,Missing}=missing)

List all gateway endpoints with optional filters.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_type`: Optional filter by endpoint type.

# Returns
Vector of [`GatewayEndpoint`](@ref) entities.
"""
function listgatewayendpoints(instance::MLFlow; endpoint_type::Union{String,Missing}=missing)::Array{GatewayEndpoint}
    parameters = Dict{Symbol,Any}()
    if !ismissing(endpoint_type)
        parameters[:endpoint_type] = endpoint_type
    end
    result = mlfget_v3(instance, "gateway/endpoints/list"; parameters...)
    return get(result, "endpoints", []) |> (x -> [GatewayEndpoint(y) for y in x])
end

"""
    attachmodeltogatewayendpoint(instance::MLFlow, endpoint_id::String,
        model_config::Dict{String,Any}; created_by::Union{String,Missing}=missing)

Attach a model to a gateway endpoint.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_id`: ID of the endpoint.
- `model_config`: Configuration for the model to attach. Should include:
  - `model_definition_id`: ID of the model definition
  - `linkage_type`: Type of linkage (e.g., "PRIMARY", "FALLBACK")
  - `weight`: Routing weight (optional)
  - `fallback_order`: Order for fallback (optional)
- `created_by`: Username of the creator.

# Returns
An instance of type [`GatewayEndpointModelMapping`](@ref).
"""
function attachmodeltogatewayendpoint(instance::MLFlow, endpoint_id::String,
    model_config::Dict{String,Any}; created_by::Union{String,Missing}=missing)::GatewayEndpointModelMapping
    params = Dict{Symbol,Any}(:endpoint_id => endpoint_id, :model_config => model_config)
    !ismissing(created_by) && (params[:created_by] = created_by)
    result = mlfpost_v3(instance, "gateway/endpoints/models/attach"; params...)
    return result["mapping"] |> GatewayEndpointModelMapping
end

"""
    detachmodelfromgatewayendpoint(instance::MLFlow, endpoint_id::String,
        model_definition_id::String)

Detach a model from a gateway endpoint.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_id`: ID of the endpoint.
- `model_definition_id`: ID of the model definition to detach.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function detachmodelfromgatewayendpoint(instance::MLFlow, endpoint_id::String,
    model_definition_id::String)::Bool
    mlfpost_v3(instance, "gateway/endpoints/models/detach";
        endpoint_id=endpoint_id, model_definition_id=model_definition_id)
    return true
end

## Endpoint Bindings

"""
    creategatewayendpointbinding(instance::MLFlow, endpoint_id::String,
        resource_type::String, resource_id::String; created_by::Union{String,Missing}=missing)

Create a binding between an endpoint and an MLflow resource.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_id`: ID of the endpoint to bind.
- `resource_type`: Type of MLflow resource.
- `resource_id`: ID of the MLflow resource.
- `created_by`: Username of the creator.

# Returns
An instance of type [`GatewayEndpointBinding`](@ref).
"""
function creategatewayendpointbinding(instance::MLFlow, endpoint_id::String,
    resource_type::String, resource_id::String; created_by::Union{String,Missing}=missing)::GatewayEndpointBinding
    result = mlfpost_v3(instance, "gateway/endpoints/bindings/create";
        endpoint_id=endpoint_id, resource_type=resource_type,
        resource_id=resource_id, created_by=created_by)
    return result["binding"] |> GatewayEndpointBinding
end

"""
    deletegatewayendpointbinding(instance::MLFlow, endpoint_id::String,
        resource_type::String, resource_id::String)

Delete a binding between an endpoint and a resource.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_id`: ID of the endpoint.
- `resource_type`: Type of resource bound to the endpoint.
- `resource_id`: ID of the resource.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletegatewayendpointbinding(instance::MLFlow, endpoint_id::String,
    resource_type::String, resource_id::String)::Bool
    mlfdelete_v3(instance, "gateway/endpoints/bindings/delete";
        endpoint_id=endpoint_id, resource_type=resource_type, resource_id=resource_id)
    return true
end

"""
    listgatewayendpointbindings(instance::MLFlow, endpoint_id::String;
        resource_type::Union{String,Missing}=missing, resource_id::Union{String,Missing}=missing)

List all bindings for an endpoint.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_id`: ID of the endpoint to list bindings for.
- `resource_type`: Type of resource to filter bindings by.
- `resource_id`: ID of the resource to filter bindings by.

# Returns
Vector of [`GatewayEndpointBinding`](@ref) entities.
"""
function listgatewayendpointbindings(instance::MLFlow, endpoint_id::String;
    resource_type::Union{String,Missing}=missing, resource_id::Union{String,Missing}=missing)::Array{GatewayEndpointBinding}
    parameters = Dict{Symbol,Any}(:endpoint_id => endpoint_id)
    if !ismissing(resource_type)
        parameters[:resource_type] = resource_type
    end
    if !ismissing(resource_id)
        parameters[:resource_id] = resource_id
    end
    result = mlfget_v3(instance, "gateway/endpoints/bindings/list"; parameters...)
    return get(result, "bindings", []) |> (x -> [GatewayEndpointBinding(y) for y in x])
end

## Endpoint Tags

"""
    setgatewayendpointtag(instance::MLFlow, endpoint_id::String, key::String, value::String)

Set a tag on an endpoint.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_id`: ID of the endpoint to set tag on.
- `key`: Tag key to set.
- `value`: Tag value to set.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function setgatewayendpointtag(instance::MLFlow, endpoint_id::String, key::String, value::String)::Bool
    mlfpost_v3(instance, "gateway/endpoints/set-tag";
        endpoint_id=endpoint_id, key=key, value=value)
    return true
end

"""
    deletegatewayendpointtag(instance::MLFlow, endpoint_id::String, key::String)

Delete a tag from an endpoint.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `endpoint_id`: ID of the endpoint to delete tag from.
- `key`: Tag key to delete.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletegatewayendpointtag(instance::MLFlow, endpoint_id::String, key::String)::Bool
    mlfdelete_v3(instance, "gateway/endpoints/delete-tag";
        endpoint_id=endpoint_id, key=key)
    return true
end

## Budgets Management

"""
    creategatewaybudget(instance::MLFlow, budget_unit::String, budget_amount::Float64,
        duration::Dict{String,Any}, target_scope::String, budget_action::String;
        created_by::Union{String,Missing}=missing)

Create a new budget policy.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `budget_unit`: Budget measurement unit (e.g., "USD").
- `budget_amount`: Budget amount.
- `duration`: Budget duration configuration with `unit` and `value` fields.
- `target_scope`: Target scope for the budget policy (e.g., "GLOBAL", "WORKSPACE").
- `budget_action`: Action to take when budget is exceeded (e.g., "ALERT", "REJECT").
- `created_by`: Username of the creator.

# Returns
An instance of type [`GatewayBudgetPolicy`](@ref).
"""
function creategatewaybudget(instance::MLFlow, budget_unit::String, budget_amount::Float64,
    duration::Dict{String,Any}, target_scope::String, budget_action::String;
    created_by::Union{String,Missing}=missing)::GatewayBudgetPolicy
    params = Dict{Symbol,Any}(
        :budget_unit => budget_unit,
        :budget_amount => budget_amount,
        :duration => duration,
        :target_scope => target_scope,
        :budget_action => budget_action
    )
    !ismissing(created_by) && (params[:created_by] = created_by)
    result = mlfpost_v3(instance, "gateway/budgets/create"; params...)
    return result["budget_policy"] |> GatewayBudgetPolicy
end

"""
    getgatewaybudget(instance::MLFlow, budget_policy_id::String)

Get a budget policy by ID.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `budget_policy_id`: ID of the budget policy to retrieve.

# Returns
An instance of type [`GatewayBudgetPolicy`](@ref).
"""
function getgatewaybudget(instance::MLFlow, budget_policy_id::String)::GatewayBudgetPolicy
    result = mlfget_v3(instance, "gateway/budgets/get"; budget_policy_id=budget_policy_id)
    return result["budget_policy"] |> GatewayBudgetPolicy
end

"""
    updategatewaybudget(instance::MLFlow, budget_policy_id::String;
        budget_amount::Union{Float64,Missing}=missing, duration::Union{Dict{String,Any},Missing}=missing,
        target_scope::Union{String,Missing}=missing, budget_action::Union{String,Missing}=missing,
        updated_by::Union{String,Missing}=missing)

Update a budget policy.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `budget_policy_id`: ID of the budget policy to update.
- `budget_amount`: Optional new budget amount.
- `duration`: Optional new duration configuration.
- `target_scope`: Optional new target scope.
- `budget_action`: Optional new budget action.
- `updated_by`: Username of the updater.

# Returns
An instance of type [`GatewayBudgetPolicy`](@ref).
"""
function updategatewaybudget(instance::MLFlow, budget_policy_id::String;
    budget_amount::Union{Float64,Missing}=missing, duration::Union{Dict{String,Any},Missing}=missing,
    target_scope::Union{String,Missing}=missing, budget_action::Union{String,Missing}=missing,
    updated_by::Union{String,Missing}=missing)::GatewayBudgetPolicy
    params = Dict{Symbol,Any}(:budget_policy_id => budget_policy_id)
    !ismissing(budget_amount) && (params[:budget_amount] = budget_amount)
    !ismissing(duration) && (params[:duration] = duration)
    !ismissing(target_scope) && (params[:target_scope] = target_scope)
    !ismissing(budget_action) && (params[:budget_action] = budget_action)
    !ismissing(updated_by) && (params[:updated_by] = updated_by)
    result = mlfpost_v3(instance, "gateway/budgets/update"; params...)
    return result["budget_policy"] |> GatewayBudgetPolicy
end

"""
    deletegatewaybudget(instance::MLFlow, budget_policy_id::String)

Delete a budget policy.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `budget_policy_id`: ID of the budget policy to delete.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletegatewaybudget(instance::MLFlow, budget_policy_id::String)::Bool
    mlfdelete_v3(instance, "gateway/budgets/delete"; budget_policy_id=budget_policy_id)
    return true
end

"""
    listgatewaybudgets(instance::MLFlow)

List all budget policies.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.

# Returns
Vector of [`GatewayBudgetPolicy`](@ref) entities.
"""
function listgatewaybudgets(instance::MLFlow)::Array{GatewayBudgetPolicy}
    result = mlfget_v3(instance, "gateway/budgets/list")
    return get(result, "budget_policies", []) |> (x -> [GatewayBudgetPolicy(y) for y in x])
end

"""
    listgatewaybudgetwindows(instance::MLFlow)

List all available budget windows.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.

# Returns
Vector of [`GatewayBudgetWindow`](@ref) entities.
"""
function listgatewaybudgetwindows(instance::MLFlow)::Array{GatewayBudgetWindow}
    result = mlfget_v3(instance, "gateway/budgets/windows")
    return get(result, "windows", []) |> (x -> [GatewayBudgetWindow(y) for y in x])
end
