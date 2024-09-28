"""
    MLFlow

Base type which defines location and version for MLFlow API service.

# Fields
- `apiroot::String`: API root URL, e.g. `http://localhost:5000/api`
- `apiversion::Union{Integer, AbstractFloat}`: used API version, e.g. `2.0`
- `headers::Dict`: HTTP headers to be provided with the REST API requests (useful for authetication tokens)
Default is `false`, using the REST API endpoint.

# Constructors

- `MLFlow(apiroot; user, password, apiversion=2.0, headers=Dict())` - this constructor will check env 
variables `MLFLOW_TRACKING_USERNAME` and `MLFLOW_TRACKING_PASSWORD` for credentials.
- `MLFlow()` - defaults to `MLFlow(ENV["MLFLOW_TRACKING_URI"])` or `MLFlow("http://localhost:5000/api")`

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
    apiversion::Union{Integer, AbstractFloat}
    headers::Dict
end

function MLFlow(
    apiroot;
    user=get(ENV, "MLFLOW_TRACKING_USERNAME", missing), 
    password=get(ENV, "MLFLOW_TRACKING_PASSWORD", missing), 
    apiversion=2.0, 
    headers=Dict()
    )
    if !ismissing(user) && !ismissing(password)
        token = base64encode("$(user):$(password)")
        headers["Authorization"] = "Basic $(token)"
    end
    return MLFlow(apiroot, apiversion, headers)
end

function MLFlow()
    apiroot = "http://localhost:5000/api"
    if haskey(ENV, "MLFLOW_TRACKING_URI")
        apiroot = ENV["MLFLOW_TRACKING_URI"]
    end
    return MLFlow(apiroot)
end
Base.show(io::IO, t::MLFlow) = show(io, ShowCase(t, [:apiroot,:apiversion], new_lines=true))
