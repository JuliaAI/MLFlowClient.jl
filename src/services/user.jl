"""
    createuser(instance::MLFlow, username::String, password::String)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username.
- `password`: Password.

# Returns
An [`User`](@ref) object.
"""
function createuser(instance::MLFlow, username::String, password::String)::User
    result = mlfpost(instance, "users/create"; username=username, password=password)
    return result["user"] |> User
end

"""
    getuser(instance::MLFlow, username::String)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username.

# Returns
An [`User`](@ref) object.
"""
function getuser(instance::MLFlow, username::String)::User
    result = mlfget(instance, "users/get"; username=username)
    return result["user"] |> User
end

"""
    updateuserpassword(instance::MLFlow, username::String, password::String;
        current_password::Union{String,Missing}=missing)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username.
- `password`: New password.
- `current_password`: The user's current password. Required when a user changes their own
    password; admins changing another user's password may omit it.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function updateuserpassword(instance::MLFlow, username::String, password::String;
    current_password::Union{String,Missing}=missing)::Bool
    params = Dict{Symbol,Any}(:username => username, :password => password)
    !ismissing(current_password) && (params[:current_password] = current_password)
    mlfpatch(instance, "users/update-password"; params...)
    return true
end

"""
    updateuseradmin(instance::MLFlow, username::String, is_admin::Bool)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username.
- `is_admin`: New admin status.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function updateuseradmin(instance::MLFlow, username::String, is_admin::Bool)::Bool
    mlfpatch(instance, "users/update-admin"; username=username, is_admin=is_admin)
    return true
end

"""
    deleteuser(instance::MLFlow, username::String)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deleteuser(instance::MLFlow, username::String)::Bool
    mlfdelete(instance, "users/delete"; username=username)
    return true
end

"""
    listusers(instance::MLFlow)

List all users.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.

# Returns
Vector of [`User`](@ref) entities.
"""
function listusers(instance::MLFlow)::Array{User}
    result = mlfget(instance, "users/list")
    return get(result, "users", []) |> (x -> [User(y) for y in x])
end

"""
    getcurrentuser(instance::MLFlow)

Get the currently authenticated user.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.

# Returns
An [`User`](@ref) object.
"""
function getcurrentuser(instance::MLFlow)::User
    result = mlfget(instance, "users/current")
    return result["user"] |> User
end

## Roles (RBAC)

"""
    createrole(instance::MLFlow, name::String, workspace::String;
        description::Union{String,Missing}=missing)

Create a new role.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `name`: Role name.
- `workspace`: Workspace the role belongs to.
- `description`: Optional role description.

# Returns
An instance of type [`Role`](@ref).
"""
function createrole(instance::MLFlow, name::String, workspace::String;
    description::Union{String,Missing}=missing)::Role
    params = Dict{Symbol,Any}(:name => name, :workspace => workspace)
    !ismissing(description) && (params[:description] = description)
    result = mlfpost_v3(instance, "roles/create"; params...)
    return result["role"] |> Role
end

"""
    getrole(instance::MLFlow, role_id::Int64)

Get a role by ID.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `role_id`: ID of the role to retrieve.

# Returns
An instance of type [`Role`](@ref).
"""
function getrole(instance::MLFlow, role_id::Int64)::Role
    result = mlfget_v3(instance, "roles/get"; role_id=role_id)
    return result["role"] |> Role
end

"""
    listroles(instance::MLFlow; workspace::Union{String,Missing}=missing)

List roles, optionally scoped to a workspace.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `workspace`: Optional workspace to scope the listing to.

# Returns
Vector of [`Role`](@ref) entities.
"""
function listroles(instance::MLFlow; workspace::Union{String,Missing}=missing)::Array{Role}
    parameters = Dict{Symbol,Any}()
    !ismissing(workspace) && (parameters[:workspace] = workspace)
    result = mlfget_v3(instance, "roles/list"; parameters...)
    return get(result, "roles", []) |> (x -> [Role(y) for y in x])
end

"""
    updaterole(instance::MLFlow, role_id::Int64; name::Union{String,Missing}=missing,
        description::Union{String,Missing}=missing)

Update a role's name and/or description.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `role_id`: ID of the role to update.
- `name`: Optional new name.
- `description`: Optional new description.

# Returns
An instance of type [`Role`](@ref).
"""
function updaterole(instance::MLFlow, role_id::Int64; name::Union{String,Missing}=missing,
    description::Union{String,Missing}=missing)::Role
    params = Dict{Symbol,Any}(:role_id => role_id)
    !ismissing(name) && (params[:name] = name)
    !ismissing(description) && (params[:description] = description)
    result = mlfpatch_v3(instance, "roles/update"; params...)
    return result["role"] |> Role
end

"""
    deleterole(instance::MLFlow, role_id::Int64)

Delete a role.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `role_id`: ID of the role to delete.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deleterole(instance::MLFlow, role_id::Int64)::Bool
    mlfdelete_v3(instance, "roles/delete"; role_id=role_id)
    return true
end

## Role permissions (RBAC)

"""
    addrolepermission(instance::MLFlow, role_id::Int64, resource_type::String,
        resource_pattern::String, permission::String)

Add a permission grant to a role.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `role_id`: ID of the role.
- `resource_type`: Resource type (e.g. "experiment", "registered_model").
- `resource_pattern`: Resource identifier the permission applies to.
- `permission`: Permission to grant (e.g. "READ", "EDIT", "MANAGE", "NO_PERMISSIONS").

# Returns
An instance of type [`RolePermission`](@ref).
"""
function addrolepermission(instance::MLFlow, role_id::Int64, resource_type::String,
    resource_pattern::String, permission::String)::RolePermission
    result = mlfpost_v3(instance, "roles/permissions/add"; role_id=role_id,
        resource_type=resource_type, resource_pattern=resource_pattern, permission=permission)
    return result["role_permission"] |> RolePermission
end

"""
    removerolepermission(instance::MLFlow, role_permission_id::Int64)

Remove a permission grant from a role.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `role_permission_id`: ID of the role permission to remove.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function removerolepermission(instance::MLFlow, role_permission_id::Int64)::Bool
    mlfdelete_v3(instance, "roles/permissions/remove"; role_permission_id=role_permission_id)
    return true
end

"""
    listrolepermissions(instance::MLFlow, role_id::Int64)

List the permission grants attached to a role.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `role_id`: ID of the role.

# Returns
Vector of [`RolePermission`](@ref) entities.
"""
function listrolepermissions(instance::MLFlow, role_id::Int64)::Array{RolePermission}
    result = mlfget_v3(instance, "roles/permissions/list"; role_id=role_id)
    return get(result, "role_permissions", []) |> (x -> [RolePermission(y) for y in x])
end

"""
    updaterolepermission(instance::MLFlow, role_permission_id::Int64, permission::String)

Update the permission level of a role permission grant.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `role_permission_id`: ID of the role permission to update.
- `permission`: New permission level.

# Returns
An instance of type [`RolePermission`](@ref).
"""
function updaterolepermission(instance::MLFlow, role_permission_id::Int64,
    permission::String)::RolePermission
    result = mlfpatch_v3(instance, "roles/permissions/update";
        role_permission_id=role_permission_id, permission=permission)
    return result["role_permission"] |> RolePermission
end

## Role assignments (RBAC)

"""
    assignrole(instance::MLFlow, username::String, role_id::Int64)

Assign a role to a user.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username to assign the role to.
- `role_id`: ID of the role to assign.

# Returns
An instance of type [`UserRoleAssignment`](@ref).
"""
function assignrole(instance::MLFlow, username::String, role_id::Int64)::UserRoleAssignment
    result = mlfpost_v3(instance, "roles/assign"; username=username, role_id=role_id)
    return result["assignment"] |> UserRoleAssignment
end

"""
    unassignrole(instance::MLFlow, username::String, role_id::Int64)

Unassign a role from a user.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username to unassign the role from.
- `role_id`: ID of the role to unassign.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function unassignrole(instance::MLFlow, username::String, role_id::Int64)::Bool
    mlfdelete_v3(instance, "roles/unassign"; username=username, role_id=role_id)
    return true
end

"""
    listuserroles(instance::MLFlow, username::String)

List the roles assigned to a user.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username whose roles to list.

# Returns
Vector of [`Role`](@ref) entities.
"""
function listuserroles(instance::MLFlow, username::String)::Array{Role}
    result = mlfget_v3(instance, "users/roles/list"; username=username)
    return get(result, "roles", []) |> (x -> [Role(y) for y in x])
end

"""
    listroleusers(instance::MLFlow, role_id::Int64)

List the user assignments for a role.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `role_id`: ID of the role.

# Returns
Vector of [`UserRoleAssignment`](@ref) entities.
"""
function listroleusers(instance::MLFlow, role_id::Int64)::Array{UserRoleAssignment}
    result = mlfget_v3(instance, "roles/users/list"; role_id=role_id)
    return get(result, "assignments", []) |> (x -> [UserRoleAssignment(y) for y in x])
end

## User permissions (RBAC)

"""
    grantuserpermission(instance::MLFlow, username::String, resource_type::String,
        resource_id::String, permission::String)

Grant a user a permission on a resource. This is the role-based replacement for the
removed per-resource permission endpoints.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username to grant the permission to.
- `resource_type`: Resource type (e.g. "experiment", "registered_model").
- `resource_id`: Identifier of the resource.
- `permission`: Permission to grant (e.g. "READ", "EDIT", "MANAGE", "NO_PERMISSIONS").

# Returns
`true` if successful. Otherwise, raises exception.
"""
function grantuserpermission(instance::MLFlow, username::String, resource_type::String,
    resource_id::String, permission::String)::Bool
    mlfpost_v3(instance, "users/permissions/grant"; username=username,
        resource_type=resource_type, resource_id=resource_id, permission=permission)
    return true
end

"""
    revokeuserpermission(instance::MLFlow, username::String, resource_type::String,
        resource_id::String)

Revoke a user's permission on a resource.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username to revoke the permission from.
- `resource_type`: Resource type (e.g. "experiment", "registered_model").
- `resource_id`: Identifier of the resource.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function revokeuserpermission(instance::MLFlow, username::String, resource_type::String,
    resource_id::String)::Bool
    mlfpost_v3(instance, "users/permissions/revoke"; username=username,
        resource_type=resource_type, resource_id=resource_id)
    return true
end

"""
    getuserpermission(instance::MLFlow, username::String, resource_type::String,
        resource_id::String)

Resolve a user's effective permission on a resource.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username to check.
- `resource_type`: Resource type (e.g. "experiment", "registered_model").
- `resource_id`: Identifier of the resource.

# Returns
A named tuple `(allowed::Bool, permission::String)` where `allowed` indicates regular
access and `permission` is the resolved permission level.
"""
function getuserpermission(instance::MLFlow, username::String, resource_type::String,
    resource_id::String)::NamedTuple{(:allowed, :permission),Tuple{Bool,String}}
    result = mlfget_v3(instance, "users/permissions/get"; username=username,
        resource_type=resource_type, resource_id=resource_id)
    return (allowed=get(result, "allowed", false), permission=get(result, "permission", ""))
end

"""
    listuserpermissions(instance::MLFlow, username::String)

List all permission grants a user holds across their roles.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username whose permissions to list.

# Returns
A named tuple `(is_admin::Bool, permissions::Array{UserPermission})`.
"""
function listuserpermissions(instance::MLFlow,
    username::String)::NamedTuple{(:is_admin, :permissions),Tuple{Bool,Array{UserPermission}}}
    result = mlfget_v3(instance, "users/permissions/list"; username=username)
    permissions = get(result, "permissions", []) |> (x -> [UserPermission(y) for y in x])
    return (is_admin=get(result, "is_admin", false), permissions=permissions)
end

"""
    listcurrentuserpermissions(instance::MLFlow)

List all permission grants the currently authenticated user holds.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.

# Returns
A named tuple `(is_admin::Bool, permissions::Array{UserPermission})`.
"""
function listcurrentuserpermissions(instance::MLFlow)::NamedTuple{(:is_admin, :permissions),Tuple{Bool,Array{UserPermission}}}
    result = mlfget_v3(instance, "users/current/permissions")
    permissions = get(result, "permissions", []) |> (x -> [UserPermission(y) for y in x])
    return (is_admin=get(result, "is_admin", false), permissions=permissions)
end
