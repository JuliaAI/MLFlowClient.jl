"""
    createwebhook(instance::MLFlow, name::String, url::String;
        events::Array{WebhookEvent}=WebhookEvent[],
        description::Union{String, Missing}=missing,
        status::Union{WebhookStatus.WebhookStatusEnum, Missing}=missing,
        secret::Union{String, Missing}=missing)

Create a new webhook. Returns the created [`Webhook`](@ref).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: Name of the webhook.
- `url`: URL to send webhook events to.
- `events`: Events that trigger the webhook.
- `description`: Description of the webhook.
- `status`: Initial status of the webhook.
- `secret`: Secret for webhook verification.

# Returns
An instance of type [`Webhook`](@ref).
"""
function createwebhook(instance::MLFlow, name::String, url::String;
    events::Array{WebhookEvent}=WebhookEvent[],
    description::Union{String,Missing}=missing,
    status::Union{WebhookStatus.WebhookStatusEnum,Missing}=missing,
    secret::Union{String,Missing}=missing)::Webhook
    # Serialize events to dicts
    serialized_events = [Dict("entity" => string(e.entity), "action" => string(e.action)) for e in events]
    
    kwargs = Pair{Symbol,Any}[
        :name => name,
        :url => url,
        :events => serialized_events
    ]
    if description !== missing
        push!(kwargs, :description => description)
    end
    if status !== missing
        push!(kwargs, :status => status |> Integer)
    end
    if secret !== missing
        push!(kwargs, :secret => secret)
    end
    result = mlfpost(instance, "webhooks"; kwargs...)
    return result["webhook"] |> Webhook
end

"""
    listwebhooks(instance::MLFlow; max_results::Int64=100, page_token::String="")

List all webhooks.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `max_results`: Maximum number of webhooks desired.
- `page_token`: Pagination token from previous request.

# Returns
- Vector of [`Webhook`](@ref) that were found.
- The next page token if there are more results.
"""
function listwebhooks(instance::MLFlow; max_results::Int64=100,
    page_token::Union{String,Missing}=missing)::Tuple{Array{Webhook},Union{String,Nothing}}
    parameters = Dict{Symbol,Any}(:max_results => max_results)
    if !ismissing(page_token) && !isempty(page_token)
        parameters[:page_token] = page_token
    end
    result = mlfget(instance, "webhooks"; parameters...)
    webhooks = get(result, "webhooks", []) |> (x -> [Webhook(y) for y in x])
    next_page_token = get(result, "next_page_token", nothing)
    return webhooks, next_page_token
end

"""
    getwebhook(instance::MLFlow, webhook_id::String)

Get a webhook by its ID.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `webhook_id`: Unique identifier for the webhook.

# Returns
An instance of type [`Webhook`](@ref).
"""
function getwebhook(instance::MLFlow, webhook_id::String)::Webhook
    result = mlfget(instance, "webhooks/$(webhook_id)")
    return result["webhook"] |> Webhook
end

"""
    updatewebhook(instance::MLFlow, webhook_id::String;
        name::Union{String, Missing}=missing,
        description::Union{String, Missing}=missing,
        url::Union{String, Missing}=missing,
        status::Union{WebhookStatus.WebhookStatusEnum, Missing}=missing,
        secret::Union{String, Missing}=missing)

Update a webhook. Returns the updated [`Webhook`](@ref).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `webhook_id`: Unique identifier for the webhook.
- `name`: Updated name for the webhook.
- `description`: Updated description for the webhook.
- `url`: Updated URL for the webhook.
- `status`: Updated status of the webhook.
- `secret`: Updated secret for the webhook.

# Returns
An instance of type [`Webhook`](@ref).
"""
function updatewebhook(instance::MLFlow, webhook_id::String;
    name::Union{String,Missing}=missing,
    description::Union{String,Missing}=missing,
    url::Union{String,Missing}=missing,
    status::Union{WebhookStatus.WebhookStatusEnum,Missing}=missing,
    secret::Union{String,Missing}=missing)::Webhook
    kwargs = Pair{Symbol,Any}[:webhook_id => webhook_id]

    if name !== missing
        push!(kwargs, :name => name)
    end
    if description !== missing
        push!(kwargs, :description => description)
    end
    if url !== missing
        push!(kwargs, :url => url)
    end
    if status !== missing
        push!(kwargs, :status => status |> Integer)
    end
    if secret !== missing
        push!(kwargs, :secret => secret)
    end

    result = mlfpatch(instance, "webhooks/$(webhook_id)"; kwargs...)
    return result["webhook"] |> Webhook
end

"""
    deletewebhook(instance::MLFlow, webhook_id::String)

Delete a webhook.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `webhook_id`: Unique identifier for the webhook.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletewebhook(instance::MLFlow, webhook_id::String)::Bool
    mlfdelete(instance, "webhooks/$(webhook_id)")
    return true
end

"""
    testwebhook(instance::MLFlow, webhook_id::String;
        event::Union{WebhookEvent, Missing}=missing)

Test a webhook.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `webhook_id`: Unique identifier for the webhook.
- `event`: Optional event to test with.

# Returns
An instance of type [`WebhookTestResult`](@ref).
"""
function testwebhook(instance::MLFlow, webhook_id::String;
    event::Union{WebhookEvent,Missing}=missing)::WebhookTestResult
    kwargs = Pair{Symbol,Any}[]

    if event !== missing
        push!(kwargs, :event => event)
    end

    result = mlfpost(instance, "webhooks/$(webhook_id)/test"; kwargs...)
    return result["result"] |> WebhookTestResult
end
