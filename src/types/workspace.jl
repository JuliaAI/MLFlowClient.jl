"""
    TraceArchivalConfig

Trace archival settings for a [`Workspace`](@ref).

# Fields
- `location`: Optional archival repository root override.
- `retention`: Optional archival retention override (format: `<int><unit>`, e.g. "30d").
"""
struct TraceArchivalConfig
    location::Union{String,Nothing}
    retention::Union{String,Nothing}
end

function TraceArchivalConfig(data::AbstractDict)
    TraceArchivalConfig(
        get(data, "location", nothing),
        get(data, "retention", nothing)
    )
end

"""
    Workspace

Represents an MLflow workspace. Workspace management requires the server to run with
`--enable-workspaces`.

# Fields
- `name`: Unique workspace name.
- `description`: Optional workspace description.
- `default_artifact_root`: Optional default artifact root override for the workspace.
- `trace_archival_config`: Optional trace archival settings.
"""
struct Workspace
    name::String
    description::Union{String,Nothing}
    default_artifact_root::Union{String,Nothing}
    trace_archival_config::Union{TraceArchivalConfig,Nothing}
end

function Workspace(data::AbstractDict)
    trace_archival_config = haskey(data, "trace_archival_config") &&
        !isnothing(data["trace_archival_config"]) ?
        TraceArchivalConfig(data["trace_archival_config"]) : nothing
    Workspace(
        get(data, "name", ""),
        get(data, "description", nothing),
        get(data, "default_artifact_root", nothing),
        trace_archival_config
    )
end
