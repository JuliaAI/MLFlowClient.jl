"""
    FileInfo

# Fields
- `path::String`: Path relative to the root artifact directory run.
- `is_dir::Bool`: Whether the path is a directory.
- `file_size::Int64`: Size in bytes. Unset for directories.
"""
struct FileInfo
    path::String
    is_dir::Bool
    file_size::Int64
end
Base.show(io::IO, t::FileInfo) = show(io, ShowCase(t, new_lines=true))
