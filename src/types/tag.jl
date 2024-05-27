"""
    Tag

Generic tag type for MLFlow entities.

# Fields
- `key::String`: The tag key.
- `value::String`: The tag value.
"""
struct Tag
    key::String
    value::String
end
Base.show(io::IO, t::Tag) = show(io, ShowCase(t, new_lines=true))
