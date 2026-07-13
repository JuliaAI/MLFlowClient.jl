"""
    InputPassFail

Pass/Fail input for a [`LabelSchema`](@ref), rendered as a thumbs-up / thumbs-down toggle.

# Fields
- `positive_label`: Optional label shown next to the thumbs-up button (e.g. "Correct").
- `negative_label`: Optional label shown next to the thumbs-down button (e.g. "Incorrect").
"""
struct InputPassFail
    positive_label::Union{String,Nothing}
    negative_label::Union{String,Nothing}
end

function InputPassFail(data::AbstractDict)
    InputPassFail(
        get(data, "positive_label", nothing),
        get(data, "negative_label", nothing)
    )
end

"""
    InputCategorical

Categorical (single- or multi-select) input for a [`LabelSchema`](@ref).

# Fields
- `options`: The available options.
- `multi_select`: Whether the widget renders multi-select (the value becomes a list).
"""
struct InputCategorical
    options::Array{String}
    multi_select::Bool
end

function InputCategorical(data::AbstractDict)
    InputCategorical(
        [string(o) for o in get(data, "options", [])],
        get(data, "multi_select", false)
    )
end

"""
    InputNumeric

Numeric input bounded by optional min/max values for a [`LabelSchema`](@ref).

# Fields
- `min_value`: Optional lower bound.
- `max_value`: Optional upper bound.
"""
struct InputNumeric
    min_value::Union{Float64,Nothing}
    max_value::Union{Float64,Nothing}
end

function InputNumeric(data::AbstractDict)
    InputNumeric(
        haskey(data, "min_value") && !isnothing(data["min_value"]) ?
            Float64(data["min_value"]) : nothing,
        haskey(data, "max_value") && !isnothing(data["max_value"]) ?
            Float64(data["max_value"]) : nothing
    )
end

"""
    InputText

Free-form text input for a [`LabelSchema`](@ref).

# Fields
- `max_length`: Optional maximum character length (unset means no limit).
"""
struct InputText
    max_length::Union{Int64,Nothing}
end

function InputText(data::AbstractDict)
    InputText(
        haskey(data, "max_length") && !isnothing(data["max_length"]) ?
            Int64(data["max_length"]) : nothing
    )
end

"""
    LabelSchemaInput

Discriminated input wrapper for a [`LabelSchema`](@ref). Exactly one input variant is set.

# Fields
- `pass_fail`: Optional [`InputPassFail`](@ref) variant.
- `categorical`: Optional [`InputCategorical`](@ref) variant.
- `numeric`: Optional [`InputNumeric`](@ref) variant.
- `text`: Optional [`InputText`](@ref) variant.
"""
struct LabelSchemaInput
    pass_fail::Union{InputPassFail,Nothing}
    categorical::Union{InputCategorical,Nothing}
    numeric::Union{InputNumeric,Nothing}
    text::Union{InputText,Nothing}
end

function LabelSchemaInput(data::AbstractDict)
    LabelSchemaInput(
        haskey(data, "pass_fail") && !isnothing(data["pass_fail"]) ?
            InputPassFail(data["pass_fail"]) : nothing,
        haskey(data, "categorical") && !isnothing(data["categorical"]) ?
            InputCategorical(data["categorical"]) : nothing,
        haskey(data, "numeric") && !isnothing(data["numeric"]) ?
            InputNumeric(data["numeric"]) : nothing,
        haskey(data, "text") && !isnothing(data["text"]) ?
            InputText(data["text"]) : nothing
    )
end

"""
    LabelSchema

Represents an MLflow label schema: an experiment-scoped UI rendering hint that drives the
reviewer-facing widgets in the labeling UI.

# Fields
- `schema_id`: Server-generated identifier.
- `experiment_id`: Parent experiment ID.
- `name`: Schema name (unique within the experiment).
- `type`: Schema type (`FEEDBACK` or `EXPECTATION`).
- `instruction`: Optional supplementary guidance.
- `enable_comment`: Whether the widget renders a free-form comment input.
- `input`: The input configuration.
- `created_by`: User who created the schema.
- `created_at`: Creation time in milliseconds since epoch.
- `last_updated_at`: Last update time in milliseconds since epoch.
- `is_default`: Whether this is the experiment's protected default schema.
"""
struct LabelSchema
    schema_id::String
    experiment_id::String
    name::String
    type::String
    instruction::String
    enable_comment::Bool
    input::Union{LabelSchemaInput,Nothing}
    created_by::String
    created_at::Int64
    last_updated_at::Int64
    is_default::Bool
end

function LabelSchema(data::AbstractDict)
    input = haskey(data, "input") && !isnothing(data["input"]) ?
        LabelSchemaInput(data["input"]) : nothing
    LabelSchema(
        get(data, "schema_id", ""),
        get(data, "experiment_id", "") |> string,
        get(data, "name", ""),
        get(data, "type", ""),
        get(data, "instruction", ""),
        get(data, "enable_comment", false),
        input,
        get(data, "created_by", ""),
        get(data, "created_at", 0),
        get(data, "last_updated_at", 0),
        get(data, "is_default", false)
    )
end
