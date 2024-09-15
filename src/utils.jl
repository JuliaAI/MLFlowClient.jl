IntOrString = Union{Int, String}

"""
    generatefilterfromentity_type(filter_params::AbstractDict{K,V}, entity_type::String) where {K,V}

Generates a `filter` string from `filter_params` dictionary and `entity_type`.

# Arguments
- `filter_params`: dictionary to use for filter generation.
- `entity_type`: entity type to use for filter generation.

# Returns
A string that can be passed as `filter` to [`searchruns`](@ref).

# Examples

```@example
generatefilterfromentity_type(Dict("paramkey1" => "paramvalue1", "paramkey2" => "paramvalue2"), "param")
```
"""
function generatefilterfromentity_type(filter_params::AbstractDict{K,V}, entity_type::String) where {K,V}
    length(filter_params) > 0 || return ""
    # NOTE: may have issues with escaping.
    filters = ["$(entity_type).\"$(k)\" = \"$(v)\"" for (k, v) ∈ filter_params]
    join(filters, " and ")
end

"""
    generatefilterfromparams(filter_params::AbstractDict{K,V}) where {K,V}

Generates a `filter` string from `filter_params` dictionary and `param` entity type.
"""
generatefilterfromparams(filter_params::AbstractDict{K,V}) where {K,V} = generatefilterfromentity_type(filter_params, "param")
"""
    generatefilterfrommattributes(filter_attributes::AbstractDict{K,V}) where {K,V}

Generates a `filter` string from `filter_attributes` dictionary and `attribute` entity type.
"""
generatefilterfromattributes(filter_attributes::AbstractDict{K,V}) where {K,V} = generatefilterfromentity_type(filter_attributes, "attribute")

const MLFLOW_ERROR_CODES = (;
    RESOURCE_ALREADY_EXISTS = "RESOURCE_ALREADY_EXISTS",
    RESOURCE_DOES_NOT_EXIST = "RESOURCE_DOES_NOT_EXIST",
)

"""
    pairtags_to_dictarray(pair_array::Array{Pair{Any, Any}})

Transforms an array of `Pair` tags into an array of MLFlow compatible `Dict`
format tags.

```@example
# Having an array of pairs
["foo" => "bar", "missy" => "gala"]

# Will be transformed into an array of dictionaries
[Dict("key" => "foo", "value" => "bar"), Dict("key" => "missy", "value" => "gala")]
```
"""
function pairtags_to_dictarray(pair_array::Array{<:Pair})::Array{<:Dict}
    dict_array = Dict[]
    for pair in pair_array
        key = string(pair.first)
        value = string(pair.second)
        push!(dict_array, Dict("key" => key, "value" => value))
    end

    return dict_array
end

"""
    tagsdict_to_dictarray(dict::Dict{Any, Any})

Transforms a dictionary into an array of `Dict`.

```@example
# Having a dictionary
Dict("foo" => "bar", "missy" => "gala")

# Will be transformed into an array of dictionaries
[Dict("key" => "foo", "value" => "bar"), Dict("key" => "missy", "value" => "gala")]
```
"""
function tagsdict_to_dictarray(dict::Dict{<:Any})::Array{<:Dict}
    dict_array = Dict[]
    for (key, value) in dict
        push!(dict_array, Dict("key" => key |> string,
            "value" => value |> string))
    end

    return dict_array
end

"""
    tagarray_to_dictarray(tag_array::Array{Tag})

Transforms an array of `Tag` into an array of `Dict`.

```@example
# Having an array of tags
[Tag("foo", "bar"), Tag("missy", "gala")]

# Will be transformed into an array of dictionaries
[Dict("key" => "foo", "value" => "bar"), Dict("key" => "missy", "value" => "gala")]
```
"""
function tagarray_to_dictarray(tag_array::Array{Tag})::Array{<:Dict}
    dict_array = Dict[]
    for tag in tag_array
        push!(dict_array, Dict("key" => tag.key , "value" => tag.value))
    end

    return dict_array
end

function parsetags(tags::Union{Dict{<:Any}, Array{<:Any}})::Array{<:Dict}
    parsed_tags = Dict[]
    if tags isa Array{Tag}
        parsed_tags = tags |> tagarray_to_dictarray
    elseif tags isa Array{<:Pair}
        parsed_tags = tags |> pairtags_to_dictarray
    elseif tags isa Dict{<:Any}
        parsed_tags = tags |> tagsdict_to_dictarray
    end

    return parsed_tags
end
