const NumberOrString = Union{Number, String}
const MLFlowUpsertData{T} = Union{Array{T}, Array{<:Dict{String, <:Any}},
    Dict{String, <:NumberOrString}, Array{<:Pair{String, <:NumberOrString}},
    Array{<:Tuple{String, <:NumberOrString}}}

function dict_to_T_array(::Type{T},
    dict::Dict{String, <:NumberOrString}) where T<:LoggingData
    entities = T[]
    for (key, value) in dict
        if T<:Metric
            push!(entities, Metric(key, Float64(value), round(Int, now() |> datetime2unix),
                nothing))
        else
            push!(entities, T(key, value |> string))
        end
    end

    return entities
end

function pairarray_to_T_array(::Type{T}, pair_array::Array{<:Pair}) where T<:LoggingData
    entities = T[]
    for pair in pair_array
        key = pair.first |> string
        if T<:Metric
            value = pair.second
            push!(entities, Metric(key, Float64(value), round(Int, now() |> datetime2unix),
                nothing))
        else
            value = pair.second |> string
            push!(entities, T(key, value))
        end
    end

    return entities
end

function tuplearray_to_T_array(::Type{T},
    tuple_array::Array{<:Tuple{String, <:NumberOrString}}) where T<:LoggingData
    entities = T[]
    for tuple in tuple_array
        if length(tuple) != 2
            error("Tuple must have exactly two elements (format: (key, value))")
        end

        key = tuple |> first |> string
        if T<: Metric
            value = tuple |> last
            push!(entities, Metric(key, Float64(value), round(Int, now() |> datetime2unix),
                nothing))
        else
            value = tuple |> last |> string
            push!(entities, T(key, value))
        end
    end

    return entities
end

function dictarray_to_T_array(::Type{T},
    dict_array::Array{<:Dict{String, <:Any}}) where T<:LoggingData
    entities = T[]
    for dict in dict_array
        key = dict["key"] |> string
        if T<:Metric
            value = Float64(dict["value"])
            if haskey(dict, "timestamp")
                timestamp = dict["timestamp"]
            else
                timestamp = round(Int, now() |> datetime2unix)
            end
            push!(entities, Metric(key, value, timestamp, nothing))
        else
            value = dict["value"] |> string
            push!(entities, T(key, value))
        end
    end

    return entities
end

function parse(::Type{T}, entities::MLFlowUpsertData{T}) where T<:LoggingData
    if entities isa Dict{String, <:NumberOrString}
        return dict_to_T_array(T, entities)
    elseif entities isa Array{<:Dict{String, <:Any}}
        return dictarray_to_T_array(T, entities)
    elseif entities isa Array{<:Pair{String, <:NumberOrString}}
        return pairarray_to_T_array(T, entities)
    elseif entities isa Array{<:Tuple{String, <:NumberOrString}}
        return tuplearray_to_T_array(T, entities)
    end
    return entities
end
