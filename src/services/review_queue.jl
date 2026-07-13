"""
    createreviewqueue(instance::MLFlow, experiment_id::String, name::String,
        queue_type::String; created_by::Union{String,Missing}=missing,
        users::Union{Array{String},Missing}=missing,
        schema_ids::Union{Array{String},Missing}=missing)

Create a [`ReviewQueue`](@ref) (user or custom) scoped to an experiment.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: Parent experiment ID.
- `name`: Queue name (must be unique within the experiment).
- `queue_type`: Queue type (`USER` or `CUSTOM`, see `ReviewQueueType`). A USER queue
    must have exactly one user equal to its name and no schemas; a CUSTOM queue may not use
    the reserved name `default`.
- `created_by`: Optional owner of the queue (server-stamped on authenticated servers).
- `users`: Optional assigned-user pool.
- `schema_ids`: Optional attached label-schema IDs (for a CUSTOM queue).

# Returns
An instance of type [`ReviewQueue`](@ref).
"""
function createreviewqueue(instance::MLFlow, experiment_id::String, name::String,
    queue_type::String; created_by::Union{String,Missing}=missing,
    users::Union{Array{String},Missing}=missing,
    schema_ids::Union{Array{String},Missing}=missing)::ReviewQueue
    params = Dict{Symbol,Any}(:experiment_id => experiment_id, :name => name,
        :queue_type => queue_type)
    !ismissing(created_by) && (params[:created_by] = created_by)
    !ismissing(users) && (params[:users] = users)
    !ismissing(schema_ids) && (params[:schema_ids] = schema_ids)
    result = mlfpost_v3(instance, "review-queues/create"; params...)
    return result["review_queue"] |> ReviewQueue
end

"""
    getorcreateuserqueue(instance::MLFlow, experiment_id::String, user::String;
        created_by::Union{String,Missing}=missing)

Get-or-create a user's personal [`ReviewQueue`](@ref) for an experiment. This operation is
atomic and idempotent on `(experiment_id, user)`.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: Parent experiment ID.
- `user`: The user identifier whose personal queue to get or create.
- `created_by`: Optional owner of the queue.

# Returns
An instance of type [`ReviewQueue`](@ref).
"""
function getorcreateuserqueue(instance::MLFlow, experiment_id::String, user::String;
    created_by::Union{String,Missing}=missing)::ReviewQueue
    params = Dict{Symbol,Any}(:experiment_id => experiment_id, :user => user)
    !ismissing(created_by) && (params[:created_by] = created_by)
    result = mlfpost_v3(instance, "review-queues/get-or-create-user"; params...)
    return result["review_queue"] |> ReviewQueue
end

"""
    getreviewqueue(instance::MLFlow, queue_id::String)

Get a [`ReviewQueue`](@ref) by ID.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `queue_id`: The review queue ID.

# Returns
An instance of type [`ReviewQueue`](@ref).
"""
function getreviewqueue(instance::MLFlow, queue_id::String)::ReviewQueue
    result = mlfget_v3(instance, "review-queues/get"; queue_id=queue_id)
    return result["review_queue"] |> ReviewQueue
end

"""
    getreviewqueuebyname(instance::MLFlow, experiment_id::String, name::String)

Get a [`ReviewQueue`](@ref) by `(experiment_id, name)`.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: Parent experiment ID.
- `name`: The review queue name.

# Returns
An instance of type [`ReviewQueue`](@ref).
"""
function getreviewqueuebyname(instance::MLFlow, experiment_id::String,
    name::String)::ReviewQueue
    result = mlfget_v3(instance, "review-queues/get-by-name";
        experiment_id=experiment_id, name=name)
    return result["review_queue"] |> ReviewQueue
end

"""
    listreviewqueues(instance::MLFlow, experiment_id::String;
        user::Union{String,Missing}=missing, item_id::Union{String,Missing}=missing,
        max_results::Union{Int,Missing}=missing,
        page_token::Union{String,Missing}=missing)

List an experiment's [`ReviewQueue`](@ref) entities, newest first.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: Parent experiment ID.
- `user`: If set, return only queues that user is assigned to.
- `item_id`: If set, return only queues that already contain this item (a trace ID).
- `max_results`: Maximum number of queues to return.
- `page_token`: Token indicating the page of queues to fetch.

# Returns
- Vector of [`ReviewQueue`](@ref) entities.
- The next page token if there are more results.
"""
function listreviewqueues(instance::MLFlow, experiment_id::String;
    user::Union{String,Missing}=missing, item_id::Union{String,Missing}=missing,
    max_results::Union{Int,Missing}=missing,
    page_token::Union{String,Missing}=missing)::Tuple{Array{ReviewQueue},Union{String,Nothing}}
    parameters = Dict{Symbol,Any}(:experiment_id => experiment_id)
    !ismissing(user) && (parameters[:user] = user)
    !ismissing(item_id) && (parameters[:item_id] = item_id)
    !ismissing(max_results) && (parameters[:max_results] = max_results)
    !ismissing(page_token) && !isempty(page_token) && (parameters[:page_token] = page_token)
    result = mlfget_v3(instance, "review-queues/list"; parameters...)
    queues = get(result, "review_queues", []) |> (x -> [ReviewQueue(y) for y in x])
    next_page_token = get(result, "next_page_token", nothing)
    return queues, next_page_token
end

"""
    updatereviewqueue(instance::MLFlow, queue_id::String;
        name::Union{String,Missing}=missing,
        users::Union{Array{String},Missing}=missing,
        schema_ids::Union{Array{String},Missing}=missing,
        new_owner::Union{String,Missing}=missing)

Update a CUSTOM [`ReviewQueue`](@ref)'s name, assigned users, attached schemas, and/or
owner. The `queue_type` is immutable and USER queues reject this operation. Passing `users`
or `schema_ids` replaces the corresponding set (passing an empty vector clears it).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `queue_id`: The review queue ID.
- `name`: Optional new queue name.
- `users`: Optional replacement assigned-user pool.
- `schema_ids`: Optional replacement attached label-schema IDs.
- `new_owner`: Optional new owner (reassigns `created_by`; requires MANAGE permission).

# Returns
An instance of type [`ReviewQueue`](@ref).
"""
function updatereviewqueue(instance::MLFlow, queue_id::String;
    name::Union{String,Missing}=missing, users::Union{Array{String},Missing}=missing,
    schema_ids::Union{Array{String},Missing}=missing,
    new_owner::Union{String,Missing}=missing)::ReviewQueue
    params = Dict{Symbol,Any}(:queue_id => queue_id)
    if !ismissing(users)
        params[:update_users] = true
        params[:users] = users
    end
    if !ismissing(schema_ids)
        params[:update_schema_ids] = true
        params[:schema_ids] = schema_ids
    end
    !ismissing(name) && (params[:name] = name)
    !ismissing(new_owner) && (params[:new_owner] = new_owner)
    result = mlfpost_v3(instance, "review-queues/update"; params...)
    return result["review_queue"] |> ReviewQueue
end

"""
    deletereviewqueue(instance::MLFlow, queue_id::String)

Delete a [`ReviewQueue`](@ref) and its user/item/schema associations. This is a no-op if the
queue does not exist.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `queue_id`: The review queue ID.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletereviewqueue(instance::MLFlow, queue_id::String)::Bool
    mlfpost_v3(instance, "review-queues/delete"; queue_id=queue_id)
    return true
end

"""
    additemstoreviewqueue(instance::MLFlow, queue_id::String, item_ids::Array{String};
        item_type::String="TRACE")

Attach items to a [`ReviewQueue`](@ref). This is idempotent per item (re-attaching preserves
the existing status).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `queue_id`: The review queue ID.
- `item_ids`: IDs of the items to attach (trace IDs in v1).
- `item_type`: Type of the referenced objects (see `ReviewItemType`); defaults to
    `TRACE`, the only supported value.

# Returns
Vector of [`ReviewQueueItem`](@ref) covering every requested item, in request order.
"""
function additemstoreviewqueue(instance::MLFlow, queue_id::String, item_ids::Array{String};
    item_type::String="TRACE")::Array{ReviewQueueItem}
    result = mlfpost_v3(instance, "review-queues/items/add";
        queue_id=queue_id, item_type=item_type, item_ids=item_ids)
    return get(result, "items", []) |> (x -> [ReviewQueueItem(y) for y in x])
end

"""
    removeitemsfromreviewqueue(instance::MLFlow, queue_id::String, item_ids::Array{String})

Detach items from a [`ReviewQueue`](@ref). This is a no-op for items that are not attached.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `queue_id`: The review queue ID.
- `item_ids`: IDs of the items to detach.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function removeitemsfromreviewqueue(instance::MLFlow, queue_id::String,
    item_ids::Array{String})::Bool
    mlfpost_v3(instance, "review-queues/items/remove";
        queue_id=queue_id, item_ids=item_ids)
    return true
end

"""
    listreviewqueueitems(instance::MLFlow, queue_id::String;
        status::Union{String,Missing}=missing,
        max_results::Union{Int,Missing}=missing,
        page_token::Union{String,Missing}=missing)

List a [`ReviewQueue`](@ref)'s attached items, newest-attached first.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `queue_id`: The review queue ID.
- `status`: Optional filter by status (see `ReviewStatus`).
- `max_results`: Maximum number of items to return.
- `page_token`: Token indicating the page of items to fetch.

# Returns
- Vector of [`ReviewQueueItem`](@ref) entities.
- The next page token if there are more results.
"""
function listreviewqueueitems(instance::MLFlow, queue_id::String;
    status::Union{String,Missing}=missing, max_results::Union{Int,Missing}=missing,
    page_token::Union{String,Missing}=missing)::Tuple{Array{ReviewQueueItem},Union{String,Nothing}}
    parameters = Dict{Symbol,Any}(:queue_id => queue_id)
    !ismissing(status) && (parameters[:status] = status)
    !ismissing(max_results) && (parameters[:max_results] = max_results)
    !ismissing(page_token) && !isempty(page_token) && (parameters[:page_token] = page_token)
    result = mlfget_v3(instance, "review-queues/items/list"; parameters...)
    items = get(result, "items", []) |> (x -> [ReviewQueueItem(y) for y in x])
    next_page_token = get(result, "next_page_token", nothing)
    return items, next_page_token
end

"""
    setreviewqueueitemstatus(instance::MLFlow, queue_id::String, item_id::String,
        status::String; completed_by::Union{String,Missing}=missing)

Set the shared-pool status of an attached [`ReviewQueueItem`](@ref).

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `queue_id`: The review queue ID.
- `item_id`: The item ID.
- `status`: New status (see `ReviewStatus`).
- `completed_by`: Required for `COMPLETE`/`DECLINED`; must be absent for `PENDING` (reopening
    an item clears attribution).

# Returns
An instance of type [`ReviewQueueItem`](@ref).
"""
function setreviewqueueitemstatus(instance::MLFlow, queue_id::String, item_id::String,
    status::String; completed_by::Union{String,Missing}=missing)::ReviewQueueItem
    params = Dict{Symbol,Any}(:queue_id => queue_id, :item_id => item_id, :status => status)
    !ismissing(completed_by) && (params[:completed_by] = completed_by)
    result = mlfpost_v3(instance, "review-queues/items/set-status"; params...)
    return result["item"] |> ReviewQueueItem
end
