"""
    Tag <: LoggingData

Generic tag type for MLFlow entities.

# Fields
- `key::String`: The tag key.
- `value::String`: The tag value.
"""
struct Tag <: LoggingData
    key::String
    value::String
end
Tag(data::Dict{String, Any})::Tag = Tag(data["key"], data["value"] |> string)
Base.show(io::IO, t::Tag) = show(io, ShowCase(t, new_lines=true))
