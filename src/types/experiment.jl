"""
    Experiment

# Fields
- `experiment_id::Integer`: Unique identifier for the experiment.
- `name::String`: Human readable name that identifies the experiment.
- `artifact_location::String`: Location where artifacts for the experiment are stored.
- `lifecycle_stage::String`: Current life cycle stage of the experiment: “active” or
    “deleted”. Deleted experiments are not returned by APIs.
- `last_update_time::Int64`: Last update time.
- `creation_time::Int64`: Creation time.
- `tags::Array{Tag}`: Additional metadata key-value pairs.
- `effective_trace_archival_retention::String`: Effective trace archival retention after
    broader-scope and experiment overrides are applied.
- `workspace::String`: Workspace name of the experiment (always `default` if workspaces are
    not enabled).
"""
struct Experiment
    experiment_id::String
    name::String
    artifact_location::String
    lifecycle_stage::String
    last_update_time::Int64
    creation_time::Int64
    tags::Array{Tag}
    effective_trace_archival_retention::String
    workspace::String
end
Experiment(data::AbstractDict{String}) = Experiment(data["experiment_id"], data["name"],
    data["artifact_location"], data["lifecycle_stage"], data["last_update_time"],
    data["creation_time"], [Tag(tag) for tag in get(data, "tags", [])],
    get(data, "effective_trace_archival_retention", ""),
    get(data, "workspace", ""))
Base.show(io::IO, t::Experiment) = show(io, ShowCase(t, new_lines=true))
