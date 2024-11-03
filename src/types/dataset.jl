"""
    Dataset

Represents a reference to data used for training, testing, or evaluation during the model
development process.

# Fields
- `name::String`: The name of the dataset.
- `digest::String`: The digest of the dataset.
- `source_type::String`: The type of the dataset source.
- `source::String`: Source information for the dataset.
- `schema::String`: The schema of the dataset. This field is optional.
- `profile::String`: The profile of the dataset. This field is optional.
"""
struct Dataset
    name::String
    digest::String
    source_type::String
    source::String
    schema::Union{String, Nothing}
    profile::Union{String, Nothing}
end
Dataset(data::Dict{String, Any}) = Dataset(data["name"], data["digest"],
    data["source_type"], data["source"], get(data, "schema", nothing),
    get(data, "profile", nothing))
Base.show(io::IO, t::Dataset) = show(io, ShowCase(t, new_lines=true))

"""
    DatasetInput

Represents a dataset and input tags.

# Fields
- `tags::Array{Tag}`: A list of tags for the dataset input.
- `dataset::Dataset`: The dataset being used as a run input.
"""
struct DatasetInput
    tags::Array{Tag}
    dataset::Dataset
end
DatasetInput(data::Dict{String, Any}) = DatasetInput(
    [Tag(tag) for tag in get(data, "tags", [])], Dataset(data["dataset"]))
Base.show(io::IO, t::DatasetInput) = show(io, ShowCase(t, new_lines=true))
