"""
    MLFlow

Base type which defines location and version for MLFlow API service.

# Fields
- `apiroot::String`: API root URL, e.g. `http://localhost:5000/api`
- `apiversion::Union{Integer, AbstractFloat}`: used API version, e.g. `2.0`
- `headers::Dict`: HTTP headers to be provided with the REST API requests.
- `username::Union{Nothing, String}`: username for basic authentication.
- `password::Union{Nothing, String}`: password for basic authentication.

!!! warning
    You cannot provide an `Authorization` header when an `username` and `password` are
    provided. An error will be thrown in that case.

!!! note
    - If `MLFLOW_TRACKING_URI` is set, the provided `apiroot` will be ignored.
    - If `MLFLOW_TRACKING_USERNAME` is set, the provided `username` will be ignored.
    - If `MLFLOW_TRACKING_PASSWORD` is set, the provided `password` will be ignored.
    These indications will be displayed as warnings.

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
    username::Union{Nothing,String}
    password::Union{Nothing,String}

    function MLFlow(apiroot, apiversion, headers, username, password)
        if haskey(ENV, "MLFLOW_TRACKING_URI")
            @warn "The provided apiroot will be ignored as MLFLOW_TRACKING_URI is set."
            apiroot = ENV["MLFLOW_TRACKING_URI"]
        end

        if haskey(ENV, "MLFLOW_TRACKING_USERNAME")
            @warn "The provided username will be ignored as MLFLOW_TRACKING_USERNAME is set."
            username = ENV["MLFLOW_TRACKING_USERNAME"]
        end

        if haskey(ENV, "MLFLOW_TRACKING_PASSWORD")
            @warn "The provided password will be ignored as MLFLOW_TRACKING_PASSWORD is set."
            password = ENV["MLFLOW_TRACKING_PASSWORD"]
        end

        if username |> !isnothing && password |> !isnothing
            if haskey(headers, "Authorization")
                error("You cannot provide an Authorization header when an username and password are provided.")
            end
            encoded_credentials = Base64.base64encode("$(username):$(password)")
            headers =
                merge(headers, Dict("Authorization" => "Basic $(encoded_credentials)"))
        end
        new(apiroot, apiversion, headers, username, password)
    end
end
MLFlow(apiroot::String; apiversion::AbstractFloat=2.0, headers::Dict=Dict(),
    username::Union{Nothing,String}=nothing,
    password::Union{Nothing,String}=nothing)::MLFlow =
    MLFlow(apiroot, apiversion, headers, username, password)
MLFlow(; apiroot::String="http://localhost:5000/api", apiversion::AbstractFloat=2.0,
    headers::Dict=Dict(), username::Union{Nothing,String}=nothing,
    password::Union{Nothing,String}=nothing)::MLFlow =
    MLFlow(apiroot, apiversion, headers, username, password)

Base.show(io::IO, t::MLFlow) =
    show(io, ShowCase(t, [:apiroot, :apiversion], new_lines=true))

abstract type LoggingData end
