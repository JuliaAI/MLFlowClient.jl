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
    updateuserpassword(instance::MLFlow, username::String, password::String)

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `username`: Username.
- `password`: New password.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function updateuserpassword(instance::MLFlow, username::String, password::String)::Bool
    mlfpatch(instance, "users/update-password"; username=username, password=password)
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
