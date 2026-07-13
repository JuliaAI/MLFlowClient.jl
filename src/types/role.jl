"""
    RolePermission

A permission grant attached to a [`Role`](@ref).

# Fields
- `id`: Unique identifier for the role permission.
- `role_id`: ID of the [`Role`](@ref) this permission belongs to.
- `resource_type`: Resource type the permission applies to (e.g. "experiment",
    "registered_model").
- `resource_pattern`: Resource identifier the permission applies to.
- `permission`: Permission granted (e.g. "READ", "EDIT", "MANAGE", "NO_PERMISSIONS").
"""
struct RolePermission
    id::Int64
    role_id::Int64
    resource_type::String
    resource_pattern::String
    permission::String
end

function RolePermission(data::AbstractDict)
    RolePermission(
        get(data, "id", 0) |> Int64,
        get(data, "role_id", 0) |> Int64,
        get(data, "resource_type", ""),
        get(data, "resource_pattern", ""),
        get(data, "permission", "")
    )
end

"""
    Role

A role groups permission grants and can be assigned to users.

# Fields
- `id`: Unique identifier for the role.
- `name`: Role name.
- `workspace`: Workspace the role belongs to.
- `description`: Optional role description.
- `permissions`: The [`RolePermission`](@ref)s attached to the role.
"""
struct Role
    id::Int64
    name::String
    workspace::String
    description::Union{String,Nothing}
    permissions::Array{RolePermission}
end

function Role(data::AbstractDict)
    Role(
        get(data, "id", 0) |> Int64,
        get(data, "name", ""),
        get(data, "workspace", ""),
        get(data, "description", nothing),
        [RolePermission(permission) for permission in get(data, "permissions", [])]
    )
end

"""
    UserRoleAssignment

The assignment of a [`Role`](@ref) to a [`User`](@ref).

# Fields
- `id`: Unique identifier for the assignment.
- `user_id`: ID of the assigned [`User`](@ref).
- `role_id`: ID of the assigned [`Role`](@ref).
"""
struct UserRoleAssignment
    id::Int64
    user_id::String
    role_id::Int64
end

function UserRoleAssignment(data::AbstractDict)
    UserRoleAssignment(
        get(data, "id", 0) |> Int64,
        get(data, "user_id", "") |> string,
        get(data, "role_id", 0) |> Int64
    )
end

"""
    UserPermission

A single permission grant a [`User`](@ref) holds through one of their roles, as returned
by [`listuserpermissions`](@ref) and [`listcurrentuserpermissions`](@ref).

# Fields
- `role_id`: ID of the [`Role`](@ref) the grant comes from.
- `role_name`: Name of the role.
- `workspace`: Workspace the role belongs to.
- `resource_type`: Resource type the permission applies to.
- `resource_pattern`: Resource identifier the permission applies to.
- `permission`: Permission granted.
"""
struct UserPermission
    role_id::Int64
    role_name::String
    workspace::String
    resource_type::String
    resource_pattern::String
    permission::String
end

function UserPermission(data::AbstractDict)
    UserPermission(
        get(data, "role_id", 0) |> Int64,
        get(data, "role_name", ""),
        get(data, "workspace", ""),
        get(data, "resource_type", ""),
        get(data, "resource_pattern", ""),
        get(data, "permission", "")
    )
end
