using Test
using Dates
using HTTP
using UUIDs
using Base64
using MLFlowClient
using Minio
using URIs

# The route experiments/list was deprecated.
# It is thee in f.ex. 1.30.1, but not in 2.0.1:
# https://mlflow.org/docs/1.30.1/rest-api.html#list-experiments
# https://mlflow.org/docs/2.0.1/rest-api.html#list-experiments
# Query the health endpoint instead: https://github.com/mlflow/mlflow/pull/2725
"""
    mlflow_server_is_running(mlf::MLFlow)

Check MLFlow health endpoint. Return true if healthy, false otherwise.
"""
function mlflow_server_is_running()
    resp = HTTP.request("HEAD", "$(TEST_MLFLOW_URI)/health", readtimeout=10)
    return resp.status == 200 
end

# creates an instance of mlf
# skips test if mlflow is not available on default location, ENV["MLFLOW_TRACKING_URI"]
macro ensuremlf()
    e = quote
        encoded_credentials = Base64.base64encode("admin:password1234")
        mlf = MLFlow(headers=Dict("Authorization" => "Basic $(encoded_credentials)"))
        mlflow_server_is_running() || return nothing
        mlf
    end
    eval(e)
end

"""
    minio_is_running

Check minio health endpoint. Return true if health, false otherwise
"""
function minio_is_running()
    response = HTTP.request("HEAD", "$(TEST_MLFLOW_S3_ENDPOINT_URL)/minio/health/live", readtimeout=10)
    return response.status == 200
end

macro ensureminio()
    e = quote
        minio_is_running() || return nothing
    end
    eval(e)
end


