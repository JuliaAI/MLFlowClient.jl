"""
    User

# Fields
- `id::String`: User ID.
- `username::String`: Username.
- `is_admin::Bool`: Whether the user is an admin.
"""
struct User
    id::String
    username::String
    is_admin::Bool
end
User(data::AbstractDict{String}) =
    User(data["id"] |> string, data["username"], data["is_admin"])
Base.show(io::IO, t::User) = show(io, ShowCase(t, new_lines=true))
