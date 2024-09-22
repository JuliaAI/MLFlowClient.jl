const IntOrString = Union{Int, String}
const MLFlowUpsertData{T} = Union{Array{T}, Dict{String, String},
    Array{Pair{String, String}}, Array{Dict{String, String}}}

const MLFLOW_ERROR_CODES = (;
    RESOURCE_ALREADY_EXISTS = "RESOURCE_ALREADY_EXISTS",
    RESOURCE_DOES_NOT_EXIST = "RESOURCE_DOES_NOT_EXIST",
)

function dict_to_array(dict::Dict{String, String})::MLFlowUpsertData
    tags = Tag[]
    for (key, value) in dict
        push!(tags, Tag(key, value))
    end

    return tags
end

function pairsarray_to_array(pair_array::Array{<:Pair})::MLFlowUpsertData
    entity_array = Tag[]
    for pair in pair_array
        println(pair)
        key = pair.first |> string
        value = pair.second |> string
        push!(entity_array, Tag(key, value))
    end

    return entity_array
end

function dictarray_to_array(dict_array::Array{Dict{String, String}})::MLFlowUpsertData
    tags = Tag[]
    for dict in dict_array
        push!(tags, Tag(dict["key"], dict["value"]))
    end

    return tags
end

function parse(entities::MLFlowUpsertData{T}) where T<:LoggingData
    println(typeof(entities))
    if entities isa Dict{String, String}
        return entities |> dict_to_array
    elseif entities isa Array{Pair{String, String}}
        return entities |> pairsarray_to_array
    elseif entities isa Array{Dict{String, String}}
        return entities |> dictarray_to_array
    end
    return entities
end

refresh(instance::MLFlow, experiment::Experiment)::Experiment = 
    getexperiment(instance, experiment.experiment_id)
refresh(instance::MLFlow, run::Run)::Run = 
    getrun(instance, run.info.run_id)
