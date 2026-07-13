"""
    createlabelschema(instance::MLFlow, experiment_id::String, name::String, type::String,
        input::Dict; instruction::Union{String,Missing}=missing,
        enable_comment::Union{Bool,Missing}=missing)

Create a new [`LabelSchema`](@ref) scoped to an experiment.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: Parent experiment ID.
- `name`: Schema name (unique within the experiment).
- `type`: Schema type (`FEEDBACK` or `EXPECTATION`, see [`LabelSchemaType`](@ref)).
- `input`: The input configuration as a dictionary with exactly one variant key
    (`pass_fail`, `categorical`, `numeric`, or `text`), e.g.
    `Dict("categorical" => Dict("options" => ["good", "bad"]))`.
- `instruction`: Optional supplementary guidance.
- `enable_comment`: Optional flag to render a free-form comment input.

# Returns
An instance of type [`LabelSchema`](@ref).
"""
function createlabelschema(instance::MLFlow, experiment_id::String, name::String,
    type::String, input::Dict; instruction::Union{String,Missing}=missing,
    enable_comment::Union{Bool,Missing}=missing)::LabelSchema
    params = Dict{Symbol,Any}(:experiment_id => experiment_id, :name => name,
        :type => type, :input => input)
    !ismissing(instruction) && (params[:instruction] = instruction)
    !ismissing(enable_comment) && (params[:enable_comment] = enable_comment)
    result = mlfpost_v3(instance, "label-schemas/create"; params...)
    return result["label_schema"] |> LabelSchema
end

"""
    getlabelschema(instance::MLFlow, schema_id::String)

Get a [`LabelSchema`](@ref) by ID.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `schema_id`: The label schema ID.

# Returns
An instance of type [`LabelSchema`](@ref).
"""
function getlabelschema(instance::MLFlow, schema_id::String)::LabelSchema
    result = mlfget_v3(instance, "label-schemas/get"; schema_id=schema_id)
    return result["label_schema"] |> LabelSchema
end

"""
    getlabelschemabyname(instance::MLFlow, experiment_id::String, name::String)

Get a [`LabelSchema`](@ref) by `(experiment_id, name)`.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: Parent experiment ID.
- `name`: The label schema name.

# Returns
An instance of type [`LabelSchema`](@ref).
"""
function getlabelschemabyname(instance::MLFlow, experiment_id::String,
    name::String)::LabelSchema
    result = mlfget_v3(instance, "label-schemas/get-by-name";
        experiment_id=experiment_id, name=name)
    return result["label_schema"] |> LabelSchema
end

"""
    listlabelschemas(instance::MLFlow, experiment_id::String;
        max_results::Union{Int,Missing}=missing,
        page_token::Union{String,Missing}=missing)

List [`LabelSchema`](@ref) entities for an experiment, paginated.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `experiment_id`: Parent experiment ID.
- `max_results`: Maximum number of schemas to return.
- `page_token`: Token indicating the page of schemas to fetch.

# Returns
- Vector of [`LabelSchema`](@ref) entities.
- The next page token if there are more results.
"""
function listlabelschemas(instance::MLFlow, experiment_id::String;
    max_results::Union{Int,Missing}=missing,
    page_token::Union{String,Missing}=missing)::Tuple{Array{LabelSchema},Union{String,Nothing}}
    parameters = Dict{Symbol,Any}(:experiment_id => experiment_id)
    !ismissing(max_results) && (parameters[:max_results] = max_results)
    !ismissing(page_token) && !isempty(page_token) && (parameters[:page_token] = page_token)
    result = mlfget_v3(instance, "label-schemas/list"; parameters...)
    schemas = get(result, "label_schemas", []) |> (x -> [LabelSchema(y) for y in x])
    next_page_token = get(result, "next_page_token", nothing)
    return schemas, next_page_token
end

"""
    updatelabelschema(instance::MLFlow, schema_id::String;
        name::Union{String,Missing}=missing,
        instruction::Union{String,Missing}=missing,
        enable_comment::Union{Bool,Missing}=missing,
        input::Union{Dict,Missing}=missing)

Sparse-update an existing [`LabelSchema`](@ref). The schema `type` is immutable and cannot
be updated.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `schema_id`: The label schema ID.
- `name`: Optional new schema name.
- `instruction`: Optional new supplementary guidance.
- `enable_comment`: Optional new comment-input flag.
- `input`: Optional new input configuration (see [`createlabelschema`](@ref)).

# Returns
An instance of type [`LabelSchema`](@ref).
"""
function updatelabelschema(instance::MLFlow, schema_id::String;
    name::Union{String,Missing}=missing, instruction::Union{String,Missing}=missing,
    enable_comment::Union{Bool,Missing}=missing,
    input::Union{Dict,Missing}=missing)::LabelSchema
    params = Dict{Symbol,Any}(:schema_id => schema_id)
    !ismissing(name) && (params[:name] = name)
    !ismissing(instruction) && (params[:instruction] = instruction)
    !ismissing(enable_comment) && (params[:enable_comment] = enable_comment)
    !ismissing(input) && (params[:input] = input)
    result = mlfpatch_v3(instance, "label-schemas/update"; params...)
    return result["label_schema"] |> LabelSchema
end

"""
    deletelabelschema(instance::MLFlow, schema_id::String)

Delete a [`LabelSchema`](@ref) by ID. This is a no-op if the schema does not exist.

# Arguments
- `instance`: [`MLFlow`](@ref) configuration.
- `schema_id`: The label schema ID.

# Returns
`true` if successful. Otherwise, raises exception.
"""
function deletelabelschema(instance::MLFlow, schema_id::String)::Bool
    mlfdelete_v3(instance, "label-schemas/delete"; schema_id=schema_id)
    return true
end
