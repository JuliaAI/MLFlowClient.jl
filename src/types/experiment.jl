"""
    MLFlowExperiment

Represents an MLFlow experiment.

# Fields
- `name::String`: experiment name.
- `lifecycle_stage::String`: life cycle stage, one of ["active", "deleted"]
- `experiment_id::Integer`: experiment identifier.
- `tags::Any`: list of tags.
- `artifact_location::String`: where are experiment artifacts stored.

# Constructors

- `MLFlowExperiment(name, lifecycle_stage, experiment_id, tags, artifact_location)`
- `MLFlowExperiment(exp::Dict{String,Any})`

"""
struct MLFlowExperiment
    name::String
    lifecycle_stage::String
    experiment_id::Integer
    tags::Any
    artifact_location::String
end
function MLFlowExperiment(exp::Dict{String,Any})
    name = get(exp, "name", missing)
    lifecycle_stage = get(exp, "lifecycle_stage", missing)
    experiment_id = parse(Int, get(exp, "experiment_id", missing))
    tags = get(exp, "tags", missing)
    artifact_location = get(exp, "artifact_location", missing)
    MLFlowExperiment(name, lifecycle_stage, experiment_id, tags, artifact_location)
end
Base.show(io::IO, t::MLFlowExperiment) = show(io, ShowCase(t, new_lines=true))
