"""
    uri(mlf::MLFlow, endpoint="", query=missing)

Retrieves an URI based on `mlf`, `endpoint`, and, optionally, `query`.

# Examples
```@example
MLFlowClient.uri(mlf, "experiments/get", Dict(:experiment_id=>10))
```
"""
function uri(mlf::MLFlow, endpoint="", query=missing)
    u = URI("$(mlf.apiroot)/$(mlf.apiversion)/mlflow/$(endpoint)")
    !ismissing(query) && return URI(u; query=query)
    u
end

"""
    headers(mlf::MLFlow,custom_headers::AbstractDict)

Retrieves HTTP headers based on `mlf` and merges with user-provided `custom_headers`

# Examples
```@example
headers(mlf,Dict("Content-Type"=>"application/json"))
```
"""
headers(mlf::MLFlow, custom_headers::AbstractDict) = merge(mlf.headers, custom_headers)

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
    transform_pair_array_to_dict_array(pair_array::Array{Pair{Any, Any}})

Transforms an array of `Pair` into an array of `Dict`.

```@example
# Having an array of pairs
["foo" => "bar", "missy" => "gala"]

# Will be transformed into an array of dictionaries
[Dict("key" => "foo", "value" => "bar"), Dict("key" => "missy", "value" => "gala")]
```
"""
function transform_pair_array_to_dict_array(pair_array::Array{Pair{Any, Any}})
    dict_array = Dict{String, String}[]
    for pair in pair_array
        key = string(pair.first)
        value = string(pair.second)
        push!(dict_array, Dict(key => value))
    end
    return dict_array
end

"""
    transform_dict_to_dict_array(dict::Dict{Any, Any})

Transforms a dictionary into an array of `Dict`.

```@example
# Having a dictionary
Dict("foo" => "bar", "missy" => "gala")

# Will be transformed into an array of dictionaries
[Dict("key" => "foo", "value" => "bar"), Dict("key" => "missy", "value" => "gala")]
```
"""
function transform_dict_to_dict_array(dict::Dict{Any, Any})
    dict_array = Dict{String, String}[]
    for (key, value) in dict
        push!(dict_array, Dict(string(key) => string(value)))
    end
    return dict_array
end

"""
    transform_tag_array_to_dict_array(tag_array::Array{Tag})

Transforms an array of `Tag` into an array of `Dict`.

```@example
# Having an array of tags
[Tag("foo", "bar"), Tag("missy", "gala")]

# Will be transformed into an array of dictionaries
[Dict("key" => "foo", "value" => "bar"), Dict("key" => "missy", "value" => "gala")]
```
"""
function transform_tag_array_to_dict_array(tag_array::Array{Tag})
    dict_array = Dict{String, String}[]
    for tag in tag_array
        push!(dict_array, Dict(tag.key => tag.value))
    end
    return dict_array
end
