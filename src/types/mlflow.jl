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
    apiversion::Union{Integer, AbstractFloat}
    headers::Dict
end
MLFlow(baseuri; apiversion=2.0,headers=Dict()) = MLFlow(baseuri, apiversion,headers)
MLFlow() = MLFlow("http://localhost:5000", 2.0, Dict())
Base.show(io::IO, t::MLFlow) = show(io, ShowCase(t, [:baseuri,:apiversion], new_lines=true))
