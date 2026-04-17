"""
    FallbackConfig

Configuration for fallback routing.

# Fields
- `strategy`: The fallback strategy.
- `max_attempts`: The max attempts for fallback routing.
"""
struct FallbackConfig
    strategy::String
    max_attempts::Int32
end

function FallbackConfig(data::AbstractDict)
    FallbackConfig(
        get(data, "strategy", ""),
        get(data, "max_attempts", 0) |> Int32
    )
end

"""
    BudgetDuration

Fixed window duration: a (unit, value) pair that defines how long a budget window is.

# Fields
- `unit`: Unit of time (MINUTES, HOURS, DAYS, WEEKS, MONTHS).
- `value`: Number of units per window.
"""
struct BudgetDuration
    unit::String
    value::Int32
end

function BudgetDuration(data::AbstractDict)
    BudgetDuration(
        get(data, "unit", ""),
        get(data, "value", 0) |> Int32
    )
end

"""
    GatewayEndpointModelConfig

Configuration for a model attached to an endpoint.

# Fields
- `model_definition_id`: ID of the model definition.
- `linkage_type`: Type of linkage.
- `weight`: Routing weight for traffic distribution.
- `fallback_order`: Order for fallback attempts.
"""
struct GatewayEndpointModelConfig
    model_definition_id::String
    linkage_type::String
    weight::Float64
    fallback_order::Int32
end

function GatewayEndpointModelConfig(data::AbstractDict)
    GatewayEndpointModelConfig(
        get(data, "model_definition_id", ""),
        get(data, "linkage_type", ""),
        get(data, "weight", 0.0),
        get(data, "fallback_order", 0) |> Int32
    )
end

"""
    GatewayEndpointTag

Tag associated with an endpoint.

# Fields
- `key`: Tag key.
- `value`: Tag value.
"""
struct GatewayEndpointTag
    key::String
    value::String
end

function GatewayEndpointTag(data::AbstractDict)
    GatewayEndpointTag(
        get(data, "key", ""),
        get(data, "value", "")
    )
end

"""
    GatewaySecretInfo

Represents metadata about a gateway secret (does not include encrypted value).

# Fields
- `secret_id`: Unique identifier for the secret.
- `secret_name`: User-friendly name for the secret.
- `provider`: Optional LLM provider name.
- `created_by`: Username of the creator.
- `last_updated_by`: Username of the last updater.
- `created_at`: Creation time in milliseconds since epoch.
- `last_updated_at`: Last update time in milliseconds since epoch.
"""
struct GatewaySecretInfo
    secret_id::String
    secret_name::String
    provider::String
    created_by::String
    last_updated_by::String
    created_at::Int64
    last_updated_at::Int64
end

function GatewaySecretInfo(data::AbstractDict)
    GatewaySecretInfo(
        get(data, "secret_id", ""),
        get(data, "secret_name", ""),
        get(data, "provider", ""),
        get(data, "created_by", ""),
        get(data, "last_updated_by", ""),
        get(data, "created_at", 0),
        get(data, "last_updated_at", 0)
    )
end

"""
    GatewayModelDefinition

Represents a reusable gateway model definition.

# Fields
- `model_definition_id`: Unique identifier for the model definition.
- `name`: User-friendly name for the model definition.
- `secret_id`: ID of the secret containing authentication credentials.
- `secret_name`: Name of the secret for display purposes.
- `provider`: LLM provider name.
- `model_name`: Provider-specific model identifier.
- `created_by`: Username of the creator.
- `last_updated_by`: Username of the last updater.
- `created_at`: Creation time in milliseconds since epoch.
- `last_updated_at`: Last update time in milliseconds since epoch.
"""
struct GatewayModelDefinition
    model_definition_id::String
    name::String
    secret_id::String
    secret_name::String
    provider::String
    model_name::String
    created_by::String
    last_updated_by::String
    created_at::Int64
    last_updated_at::Int64
end

function GatewayModelDefinition(data::AbstractDict)
    GatewayModelDefinition(
        get(data, "model_definition_id", ""),
        get(data, "name", ""),
        get(data, "secret_id", ""),
        get(data, "secret_name", ""),
        get(data, "provider", ""),
        get(data, "model_name", ""),
        get(data, "created_by", ""),
        get(data, "last_updated_by", ""),
        get(data, "created_at", 0),
        get(data, "last_updated_at", 0)
    )
end

"""
    GatewayEndpointModelMapping

Mapping between an endpoint and a model definition.

# Fields
- `mapping_id`: Unique identifier for this mapping.
- `endpoint_id`: ID of the endpoint.
- `model_definition_id`: ID of the model definition.
- `model_definition`: The full model definition (populated via JOIN).
- `weight`: Routing weight for traffic distribution.
- `created_at`: Timestamp when the mapping was created.
- `created_by`: User ID who created the mapping.
- `linkage_type`: Type of linkage.
- `fallback_order`: Order for fallback attempts.
"""
struct GatewayEndpointModelMapping
    mapping_id::String
    endpoint_id::String
    model_definition_id::String
    model_definition::Union{GatewayModelDefinition,Nothing}
    weight::Float64
    created_at::Int64
    created_by::String
    linkage_type::String
    fallback_order::Int32
end

function GatewayEndpointModelMapping(data::AbstractDict)
    model_def = haskey(data, "model_definition") && !isnothing(data["model_definition"]) ?
        GatewayModelDefinition(data["model_definition"]) : nothing
    GatewayEndpointModelMapping(
        get(data, "mapping_id", ""),
        get(data, "endpoint_id", ""),
        get(data, "model_definition_id", ""),
        model_def,
        get(data, "weight", 0.0),
        get(data, "created_at", 0),
        get(data, "created_by", ""),
        get(data, "linkage_type", ""),
        get(data, "fallback_order", 0) |> Int32
    )
end

"""
    GatewayEndpointConfig

Represents configuration for a gateway endpoint.

# Fields
- `model_definition_id`: ID of the model definition.
- `route`: Route configuration as JSON string.
- `limits`: Rate limits as JSON string.
- `auth`: Auth configuration as JSON string.
- `metadata`: Additional metadata as JSON string.
"""
struct GatewayEndpointConfig
    model_definition_id::String
    route::String
    limits::String
    auth::String
    metadata::String
end

function GatewayEndpointConfig(data::AbstractDict)
    GatewayEndpointConfig(
        get(data, "model_definition_id", ""),
        get(data, "route", ""),
        get(data, "limits", ""),
        get(data, "auth", ""),
        get(data, "metadata", "")
    )
end

"""
    GatewayEndpoint

Represents a gateway endpoint.

# Fields
- `endpoint_id`: Unique identifier for the endpoint.
- `name`: Name of the endpoint.
- `model_mappings`: Array of model mappings bound to this endpoint.
- `routing_strategy`: Routing strategy for the endpoint.
- `fallback_config`: Fallback configuration.
- `created_by`: Username of the creator.
- `last_updated_by`: Username of the last updater.
- `created_at`: Creation time in milliseconds since epoch.
- `last_updated_at`: Last update time in milliseconds since epoch.
- `tags`: Array of endpoint tags.
- `experiment_id`: ID of the MLflow experiment where traces are logged.
- `usage_tracking`: Whether usage tracking is enabled.
"""
struct GatewayEndpoint
    endpoint_id::String
    name::String
    model_mappings::Array{GatewayEndpointModelMapping}
    routing_strategy::String
    fallback_config::Union{FallbackConfig,Nothing}
    created_by::String
    last_updated_by::String
    created_at::Int64
    last_updated_at::Int64
    tags::Array{GatewayEndpointTag}
    experiment_id::String
    usage_tracking::Bool
end

function GatewayEndpoint(data::AbstractDict)
    GatewayEndpoint(
        get(data, "endpoint_id", ""),
        get(data, "name", ""),
        get(data, "model_mappings", []) .|> GatewayEndpointModelMapping,
        get(data, "routing_strategy", ""),
        haskey(data, "fallback_config") && !isnothing(data["fallback_config"]) ?
            FallbackConfig(data["fallback_config"]) : nothing,
        get(data, "created_by", ""),
        get(data, "last_updated_by", ""),
        get(data, "created_at", 0),
        get(data, "last_updated_at", 0),
        get(data, "tags", []) .|> GatewayEndpointTag,
        get(data, "experiment_id", ""),
        get(data, "usage_tracking", false)
    )
end

"""
    GatewayEndpointBinding

Represents a binding between a gateway endpoint and an MLflow resource.

# Fields
- `endpoint_id`: ID of the endpoint.
- `resource_type`: Type of MLflow resource (e.g., "scorer").
- `resource_id`: ID of the MLflow resource.
- `created_by`: Username of the creator.
- `created_at`: Creation time in milliseconds since epoch.
"""
struct GatewayEndpointBinding
    endpoint_id::String
    resource_type::String
    resource_id::String
    created_by::String
    created_at::Int64
end

function GatewayEndpointBinding(data::AbstractDict)
    GatewayEndpointBinding(
        get(data, "endpoint_id", ""),
        get(data, "resource_type", ""),
        get(data, "resource_id", ""),
        get(data, "created_by", ""),
        get(data, "created_at", 0)
    )
end

"""
    GatewayBudgetWindow

Represents a budget window for rate limiting.

# Fields
- `budget_policy_id`: ID of the budget policy.
- `window_start_ms`: Window start timestamp.
- `window_end_ms`: Window end timestamp.
- `current_spend`: Current spend in the window.
"""
struct GatewayBudgetWindow
    budget_policy_id::String
    window_start_ms::Int64
    window_end_ms::Int64
    current_spend::Float64
end

function GatewayBudgetWindow(data::AbstractDict)
    GatewayBudgetWindow(
        get(data, "budget_policy_id", ""),
        get(data, "window_start_ms", 0),
        get(data, "window_end_ms", 0),
        get(data, "current_spend", 0.0)
    )
end

"""
    GatewayBudgetPolicy

A budget policy for gateway endpoints.

# Fields
- `budget_policy_id`: Unique identifier for the budget policy.
- `budget_unit`: Budget measurement unit.
- `budget_amount`: Budget amount.
- `duration`: Budget duration configuration.
- `target_scope`: Target scope for the budget policy.
- `budget_action`: Action to take when budget is exceeded.
- `created_by`: Username of the creator.
- `last_updated_by`: Username of the last updater.
- `created_at`: Creation time in milliseconds since epoch.
- `last_updated_at`: Last update time in milliseconds since epoch.
"""
struct GatewayBudgetPolicy
    budget_policy_id::String
    budget_unit::String
    budget_amount::Float64
    duration::BudgetDuration
    target_scope::String
    budget_action::String
    created_by::String
    last_updated_by::String
    created_at::Int64
    last_updated_at::Int64
end

function GatewayBudgetPolicy(data::AbstractDict)
    GatewayBudgetPolicy(
        get(data, "budget_policy_id", ""),
        get(data, "budget_unit", ""),
        get(data, "budget_amount", 0.0),
        get(data, "duration", Dict{String,Any}()) |> BudgetDuration,
        get(data, "target_scope", ""),
        get(data, "budget_action", ""),
        get(data, "created_by", ""),
        get(data, "last_updated_by", ""),
        get(data, "created_at", 0),
        get(data, "last_updated_at", 0)
    )
end
