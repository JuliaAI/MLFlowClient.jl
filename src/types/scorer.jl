"""
    Scorer

Represents a scorer for MLFlow experiments.

# Fields
- `experiment_id`: The experiment ID.
- `name`: The scorer name.
- `version`: Version number of the scorer.
- `scorer_id`: Unique identifier for the scorer.
- `serialized_scorer`: The serialized scorer string (JSON).
- `creation_time`: Creation time in milliseconds since epoch.
"""
struct Scorer
    experiment_id::String
    name::String
    version::Int64
    scorer_id::String
    serialized_scorer::String
    creation_time::Int64
end

function Scorer(data::AbstractDict)
    Scorer(
        get(data, "experiment_id", "") |> string,
        get(data, "name", "") |> string,
        get(data, "version", 0) |> Int64,
        get(data, "scorer_id", "") |> string,
        get(data, "serialized_scorer", "") |> string,
        get(data, "creation_time", 0) |> Int64
    )
end
