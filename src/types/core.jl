"""
    MLFlow

Base type which defines location and version for MLFlow API service.

# Fields
- `baseuri::String`: base MLFlow tracking URI, e.g. `http://localhost:5000`
- `apiversion`: used API version, e.g. `2.0`
- `headers`: HTTP headers to be provided with the REST API requests (useful for authetication tokens)

# Constructors

- `MLFlow(baseuri; apiversion=2.0,headers=Dict())`
- `MLFlow()` - defaults to `MLFlow("http://localhost:5000")`

# Examples

```@example
mlf = MLFlow()
```

```@example
remote_url="https://<your-server>.cloud.databricks.com"; # address of your remote server
mlf = MLFlow(remote_url, headers=Dict("Authorization" => "Bearer <your-secret-token>"))
```

"""
struct MLFlow
    baseuri::String
    apiversion
    headers::Dict
end
MLFlow(baseuri; apiversion=2.0,headers=Dict()) = MLFlow(baseuri, apiversion,headers)
MLFlow() = MLFlow("http://localhost:5000", 2.0, Dict())
Base.show(io::IO, t::MLFlow) = show(io, ShowCase(t, [:baseuri,:apiversion], new_lines=true))

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
