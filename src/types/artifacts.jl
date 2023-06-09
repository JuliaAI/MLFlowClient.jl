"""
    MLFlowArtifactFileInfo

Metadata of a single artifact file -- result of [`listartifacts`](@ref).

# Fields
- `filepath::String`: File path, including the root artifact directory of a run.
- `filesize::Int64`: Size in bytes.
"""
struct MLFlowArtifactFileInfo
    filepath::String
    filesize::Int64
end
Base.show(io::IO, t::MLFlowArtifactFileInfo) = show(io, ShowCase(t, new_lines=true))
get_path(mlfafi::MLFlowArtifactFileInfo) = mlfafi.filepath
get_size(mlfafi::MLFlowArtifactFileInfo) = mlfafi.filesize

"""
    MLFlowArtifactDirInfo

Metadata of a single artifact directory -- result of [`listartifacts`](@ref).

# Fields
- `dirpath::String`: Directory path, including the root artifact directory of a run.
"""
struct MLFlowArtifactDirInfo
    dirpath::String
end
Base.show(io::IO, t::MLFlowArtifactDirInfo) = show(io, ShowCase(t, new_lines=true))
get_path(mlfadi::MLFlowArtifactDirInfo) = mlfadi.dirpath
get_size(mlfadi::MLFlowArtifactDirInfo) = 0
