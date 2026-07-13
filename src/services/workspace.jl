"""
    listworkspaces(instance::MLFlow)

List all workspaces available to the current principal.

!!! note
    Workspace management requires the MLflow server to run with `--enable-workspaces`.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.

# Returns
Vector of [`Workspace`](@ref) entities.
"""
function listworkspaces(instance::MLFlow)::Array{Workspace}
    result = mlfget_v3(instance, "workspaces")
    return get(result, "workspaces", []) |> (x -> [Workspace(y) for y in x])
end

"""
    createworkspace(instance::MLFlow, name::String;
        description::Union{String,Missing}=missing,
        default_artifact_root::Union{String,Missing}=missing,
        trace_archival_config::Union{Dict,Missing}=missing)

Create a new workspace.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: Workspace name to create.
- `description`: Optional workspace description.
- `default_artifact_root`: Optional default artifact root override.
- `trace_archival_config`: Optional trace archival settings with `location` and/or
    `retention` keys.

# Returns
An instance of type [`Workspace`](@ref).
"""
function createworkspace(instance::MLFlow, name::String;
    description::Union{String,Missing}=missing,
    default_artifact_root::Union{String,Missing}=missing,
    trace_archival_config::Union{Dict,Missing}=missing)::Workspace
    params = Dict{Symbol,Any}(:name => name)
    !ismissing(description) && (params[:description] = description)
    !ismissing(default_artifact_root) && (params[:default_artifact_root] = default_artifact_root)
    !ismissing(trace_archival_config) && (params[:trace_archival_config] = trace_archival_config)
    result = mlfpost_v3(instance, "workspaces"; params...)
    return result["workspace"] |> Workspace
end

"""
    getworkspace(instance::MLFlow, workspace_name::String)

Get a workspace by name.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `workspace_name`: Name of the workspace to retrieve.

# Returns
An instance of type [`Workspace`](@ref).
"""
function getworkspace(instance::MLFlow, workspace_name::String)::Workspace
    result = mlfget_v3(instance, "workspaces/$(workspace_name)")
    return result["workspace"] |> Workspace
end

"""
    updateworkspace(instance::MLFlow, workspace_name::String;
        description::Union{String,Missing}=missing,
        default_artifact_root::Union{String,Missing}=missing,
        trace_archival_config::Union{Dict,Missing}=missing)

Update a workspace's metadata.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `workspace_name`: Name of the workspace to update.
- `description`: Optional new description.
- `default_artifact_root`: Optional new default artifact root override.
- `trace_archival_config`: Optional new trace archival settings.

# Returns
An instance of type [`Workspace`](@ref).
"""
function updateworkspace(instance::MLFlow, workspace_name::String;
    description::Union{String,Missing}=missing,
    default_artifact_root::Union{String,Missing}=missing,
    trace_archival_config::Union{Dict,Missing}=missing)::Workspace
    params = Dict{Symbol,Any}()
    !ismissing(description) && (params[:description] = description)
    !ismissing(default_artifact_root) && (params[:default_artifact_root] = default_artifact_root)
    !ismissing(trace_archival_config) && (params[:trace_archival_config] = trace_archival_config)
    result = mlfpatch_v3(instance, "workspaces/$(workspace_name)"; params...)
    return result["workspace"] |> Workspace
end

"""
    deleteworkspace(instance::MLFlow, workspace_name::String)

Delete a workspace.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `workspace_name`: Name of the workspace to delete.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deleteworkspace(instance::MLFlow, workspace_name::String)::Bool
    mlfdelete_v3(instance, "workspaces/$(workspace_name)")
    return true
end
