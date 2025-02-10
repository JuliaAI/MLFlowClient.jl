"""
    User

# Fields
- `id::String`: User ID.
- `username::String`: Username.
- `is_admin::Bool`: Whether the user is an admin.
- `experiment_permissions::Array{ExperimentPermission}`: All experiment permissions
    explicitly granted to the user.
- `registered_model_permissions::Array{RegisteredModelPermission}`: All registered model
    explicitly granted to the user.
"""
struct User
    id::String
    username::String
    is_admin::Bool
    experiment_permissions::Array{ExperimentPermission}
    registered_model_permissions::Array{RegisteredModelPermission}
end
User(data::Dict{String,Any}) = User(data["id"] |> string, data["username"], data["is_admin"],
    [ExperimentPermission(permission) for permission in get(data, "experiment_permissions", [])],
    [RegisteredModelPermission(permission) for permission in get(data, "registered_model_permissions", [])])
Base.show(io::IO, t::User) = show(io, ShowCase(t, new_lines=true))
