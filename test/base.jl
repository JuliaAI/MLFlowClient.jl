using Test
using Dates
using UUIDs
using Base64
using MLFlowClient

function mlflow_server_is_running(mlf::MLFlow)
    try
        response = MLFlowClient.mlfget(mlf, "experiments/list")
        return isa(response, Dict)
    catch e
        return false
    end
end

# creates an instance of mlf
# skips test if mlflow is not available on default location, ENV["MLFLOW_TRACKING_URI"]
macro ensuremlf()
    e = quote
        encoded_credentials = Base64.base64encode("admin:password1234")
        mlf = MLFlow(headers=Dict("Authorization" => "Basic $(encoded_credentials)"))
        mlflow_server_is_running(mlf) || return nothing
    end
    eval(e)
end
