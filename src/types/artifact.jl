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

"""
    MultipartUploadCredential

Credentials for a multipart upload part.

# Fields
- `part_number::Int64`: Part number (1-indexed).
- `upload_url::String`: Presigned URL for uploading this part.
- `headers::Dict{String,String}`: Required headers for the upload request.
"""
struct MultipartUploadCredential
    part_number::Int64
    upload_url::String
    headers::Dict{String,String}
end

"""
    MultipartUploadPart

A part in a multipart upload.

# Fields
- `part_number::Int64`: Part number (1-indexed).
- `etag::String`: ETag of the uploaded part.
"""
struct MultipartUploadPart
    part_number::Int64
    etag::String
end
