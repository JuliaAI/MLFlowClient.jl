"""
    MLFlow

Base type which defines location and version for MLFlow API service.

# Fields
- `baseuri::String`: base MLFlow tracking URI, e.g. `http://localhost:5000`
- `apiversion::Union{Integer, AbstractFloat}`: used API version, e.g. `2.0`
- `headers::Dict`: HTTP headers to be provided with the REST API requests (useful for authetication tokens)
- `use_ajax::Bool`: whether to use the AJAX endpoint for the MLFlow service.
Default is `false`, using the REST API endpoint.

# Constructors

- `MLFlow(baseuri; apiversion=2.0,headers=Dict(),use_ajax=false)`
- `MLFlow()` - defaults to `MLFlow(ENV["MLFLOW_TRACKING_URI"])` or `MLFlow("http://localhost:5000")`

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
    apiversion::Union{Integer, AbstractFloat}
    headers::Dict
    use_ajax::Bool
end
MLFlow(baseuri; apiversion=2.0, headers=Dict(), use_ajax=false) = MLFlow(baseuri, apiversion, headers, use_ajax)
function MLFlow()
    baseuri = "http://localhost:5000"
    if haskey(ENV, "MLFLOW_TRACKING_URI")
        baseuri = ENV["MLFLOW_TRACKING_URI"]
    end
    return MLFlow(baseuri)
end
Base.show(io::IO, t::MLFlow) = show(io, ShowCase(t, [:baseuri,:apiversion], new_lines=true))
