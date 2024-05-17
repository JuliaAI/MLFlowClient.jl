"""
    healthcheck(mlf::MLFlow)

Checks if MLFlow server is up and running. Returns `true` if it is, `false`
otherwise.
"""
function healthcheck(mlf)
    uri = "$(mlf.baseuri)/health"
    try
        response = HTTP.get(uri)
        return String(response.body) == "OK"
    catch e
        return false
    end
end

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
