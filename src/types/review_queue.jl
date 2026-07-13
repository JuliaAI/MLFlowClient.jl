"""
    ReviewQueue

Represents an MLflow review queue: a named bundle of attached items, label schemas, and
assigned users, scoped to an experiment.

# Fields
- `queue_id`: Server-generated identifier (prefix `rq-`).
- `experiment_id`: Parent experiment ID.
- `name`: Queue name (the normalized user identifier for a USER queue).
- `queue_type`: Queue type (`USER` or `CUSTOM`).
- `created_by`: The queue's owner.
- `creation_time_ms`: Creation time in milliseconds since epoch.
- `last_update_time_ms`: Last update time in milliseconds since epoch.
- `users`: Assigned-user pool.
- `schema_ids`: Attached label-schema IDs (empty for a USER queue).
"""
struct ReviewQueue
    queue_id::String
    experiment_id::String
    name::String
    queue_type::String
    created_by::String
    creation_time_ms::Int64
    last_update_time_ms::Int64
    users::Array{String}
    schema_ids::Array{String}
end

function ReviewQueue(data::AbstractDict)
    ReviewQueue(
        get(data, "queue_id", ""),
        get(data, "experiment_id", "") |> string,
        get(data, "name", ""),
        get(data, "queue_type", ""),
        get(data, "created_by", ""),
        get(data, "creation_time_ms", 0),
        get(data, "last_update_time_ms", 0),
        [string(u) for u in get(data, "users", [])],
        [string(s) for s in get(data, "schema_ids", [])]
    )
end

"""
    ReviewQueueItem

Represents one item attached to a [`ReviewQueue`](@ref) plus its shared-pool workflow
status.

# Fields
- `queue_id`: ID of the queue the item belongs to.
- `item_type`: Type of the referenced object (`TRACE`).
- `item_id`: ID of the referenced object (a trace ID in v1).
- `status`: Shared-pool workflow status (`PENDING`, `COMPLETE`, or `DECLINED`).
- `completed_by`: User who completed/declined the item (set only for `COMPLETE`/`DECLINED`).
- `completed_time_ms`: Completion time in milliseconds since epoch.
- `creation_time_ms`: Creation time in milliseconds since epoch.
- `last_update_time_ms`: Last update time in milliseconds since epoch.
"""
struct ReviewQueueItem
    queue_id::String
    item_type::String
    item_id::String
    status::String
    completed_by::String
    completed_time_ms::Int64
    creation_time_ms::Int64
    last_update_time_ms::Int64
end

function ReviewQueueItem(data::AbstractDict)
    ReviewQueueItem(
        get(data, "queue_id", ""),
        get(data, "item_type", ""),
        get(data, "item_id", ""),
        get(data, "status", ""),
        get(data, "completed_by", ""),
        get(data, "completed_time_ms", 0),
        get(data, "creation_time_ms", 0),
        get(data, "last_update_time_ms", 0)
    )
end
