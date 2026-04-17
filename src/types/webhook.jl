"""
    WebhookStatus

Status of a webhook.

# Members
- `ACTIVE`: Webhook is active and sending events.
- `DISABLED`: Webhook is disabled and not sending events.
"""
module WebhookStatus
    @enum WebhookStatusEnum begin
        ACTIVE = 1
        DISABLED = 2
    end
    function parse(status::String)::WebhookStatusEnum
        namemap = Dict(value => key for (key, value) in WebhookStatusEnum |> Base.Enums.namemap)
        return namemap[Symbol(status)] |> WebhookStatusEnum
    end
end

"""
    WebhookEntity

Entity types that webhooks can monitor.

# Members
- `REGISTERED_MODEL`: Monitor registered model events.
- `MODEL_VERSION`: Monitor model version events.
- `MODEL_VERSION_TAG`: Monitor model version tag events.
- `MODEL_VERSION_ALIAS`: Monitor model version alias events.
- `PROMPT`: Monitor prompt events.
- `PROMPT_VERSION`: Monitor prompt version events.
- `PROMPT_TAG`: Monitor prompt tag events.
- `PROMPT_VERSION_TAG`: Monitor prompt version tag events.
- `PROMPT_ALIAS`: Monitor prompt alias events.
- `BUDGET_POLICY`: Monitor budget policy events.
"""
module WebhookEntity
    @enum WebhookEntityEnum begin
        REGISTERED_MODEL = 1
        MODEL_VERSION = 2
        MODEL_VERSION_TAG = 3
        MODEL_VERSION_ALIAS = 4
        PROMPT = 5
        PROMPT_VERSION = 6
        PROMPT_TAG = 7
        PROMPT_VERSION_TAG = 8
        PROMPT_ALIAS = 9
        BUDGET_POLICY = 10
    end
    function parse(entity::String)::WebhookEntityEnum
        # Strip any prefix like "ENTITY_" and convert to symbol
        clean_entity = replace(entity, "ENTITY_" => "")
        namemap = Dict(value => key for (key, value) in WebhookEntityEnum |> Base.Enums.namemap)
        return namemap[Symbol(clean_entity)] |> WebhookEntityEnum
    end
end

"""
    WebhookAction

Action types for webhook events.

# Members
- `CREATED`: Entity was created.
- `UPDATED`: Entity was updated.
- `DELETED`: Entity was deleted.
- `SET`: Entity was set.
- `EXCEEDED`: Entity was exceeded.
"""
module WebhookAction
    @enum WebhookActionEnum begin
        CREATED = 1
        UPDATED = 2
        DELETED = 3
        SET = 4
        EXCEEDED = 5
    end
    function parse(action::String)::WebhookActionEnum
        # Strip any prefix like "ACTION_" and convert to symbol
        clean_action = replace(action, "ACTION_" => "")
        namemap = Dict(value => key for (key, value) in WebhookActionEnum |> Base.Enums.namemap)
        return namemap[Symbol(clean_action)] |> WebhookActionEnum
    end
end

"""
    WebhookEvent

Event that triggers a webhook.

# Fields
- `entity::WebhookEntity.WebhookEntityEnum`: Entity type.
- `action::WebhookAction.WebhookActionEnum`: Action type.
"""
struct WebhookEvent
    entity::WebhookEntity.WebhookEntityEnum
    action::WebhookAction.WebhookActionEnum
end
function WebhookEvent(data::AbstractDict{String})
    entity_val = data["entity"]
    action_val = data["action"]

    # Handle both string and integer enum values
    if entity_val isa Integer
        entity = WebhookEntity.WebhookEntityEnum(entity_val)
    else
        entity = WebhookEntity.parse(entity_val)
    end

    if action_val isa Integer
        action = WebhookAction.WebhookActionEnum(action_val)
    else
        action = WebhookAction.parse(action_val)
    end

    return WebhookEvent(entity, action)
end
Base.show(io::IO, t::WebhookEvent) = show(io, ShowCase(t, new_lines=true))

"""
    WebhookTestResult

Result of a webhook test.

# Fields
- `success::Bool`: Whether the test succeeded.
- `response_status::Int`: HTTP response status code.
- `response_body::String`: HTTP response body.
"""
struct WebhookTestResult
    success::Bool
    response_status::Int
    response_body::String
end
WebhookTestResult(data::AbstractDict{String}) = WebhookTestResult(
    get(data, "success", false),
    get(data, "response_status", 0),
    get(data, "response_body", ""))
Base.show(io::IO, t::WebhookTestResult) = show(io, ShowCase(t, new_lines=true))

"""
    Webhook

Represents a webhook configuration for MLflow events.

# Fields
- `webhook_id::String`: Unique identifier for the webhook.
- `name::String`: Name of the webhook.
- `description::Union{String, Nothing}`: Description of the webhook.
- `url::String`: URL to send webhook events to.
- `events::Array{WebhookEvent}`: Events this webhook is subscribed to.
- `status::WebhookStatus.WebhookStatusEnum`: Current status of the webhook.
- `creation_timestamp::Int64`: Timestamp when webhook was created.
- `last_updated_timestamp::Int64`: Timestamp when webhook was last updated.
"""
struct Webhook
    webhook_id::String
    name::String
    description::Union{String,Nothing}
    url::String
    events::Array{WebhookEvent}
    status::WebhookStatus.WebhookStatusEnum
    creation_timestamp::Int64
    last_updated_timestamp::Int64
end
Webhook(data::AbstractDict{String}) = Webhook(
    data["webhook_id"],
    get(data, "name", ""),
    get(data, "description", nothing),
    get(data, "url", ""),
    [WebhookEvent(event) for event in get(data, "events", [])],
    haskey(data, "status") ? WebhookStatus.parse(data["status"]) : WebhookStatus.ACTIVE,
    get(data, "creation_timestamp", 0),
    get(data, "last_updated_timestamp", 0))
Base.show(io::IO, t::Webhook) = show(io, ShowCase(t, new_lines=true))
