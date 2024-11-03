"""
    MLFlow

Base type which defines location and version for MLFlow API service.

# Fields
- `apiroot::String`: API root URL, e.g. `http://localhost:5000/api`
- `apiversion::Union{Integer, AbstractFloat}`: used API version, e.g. `2.0`
- `headers::Dict`: HTTP headers to be provided with the REST API requests (useful for
    authetication tokens) Default is `false`, using the REST API endpoint.

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
    apiroot::String
    apiversion::AbstractFloat
    headers::Dict
end
MLFlow(apiroot; apiversion=2.0, headers=Dict()) = MLFlow(apiroot, apiversion, headers)
MLFlow(; apiroot="http://localhost:5000/api", apiversion=2.0, headers=Dict()) =
    MLFlow((haskey(ENV, "MLFLOW_TRACKING_URI") ?
            ENV["MLFLOW_TRACKING_URI"] : apiroot), apiversion, headers)

Base.show(io::IO, t::MLFlow) =
    show(io, ShowCase(t, [:apiroot,:apiversion], new_lines=true))

abstract type LoggingData end
