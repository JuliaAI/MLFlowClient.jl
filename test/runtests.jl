if ~haskey(ENV, "MLFLOW_TRACKING_URI")
    error("""WARNING: MLFLOW_TRACKING_URI is not set. 
To run the unit tests, you need to set the URI of your MLFlow server API.

A test environment is provided in .devcontainers/compose.yaml, start it as
`docker-compose .devcontainers/compose.yaml up`.

Then set the environment variables
MLFLOW_TRACKING_URI="http://localhost:5050/api"
AWS_ACCESS_KEY_ID="minioadmin"
AWS_SECRET_ACCESS_KEY="minioadmin"
MLFLOW_S3_ENDPOINT_URL="http://localhost:9000"
""")
end


# Set up access to testing environment defined in docker-compose.test.yaml
const TEST_MLFLOW_URI = "http://localhost:5050/"
const TEST_MLFLOW_TRACKING_URI = "http://127.0.0.1:5050/api"
const TEST_MLFLOW_S3_ENDPOINT_URL = get(ENV, "MLFLOW_S3_ENDPOINT_URL", "http://127.0.0.1:9000")
const TEST_AWS_ACCESS_KEY_ID = get(ENV, "AWS_ACCESS_KEY_ID", "minioadmin")
const TEST_AWS_SECRET_ACCESS_KEY = get(ENV, "AWS_SECRET_ACCESS_KEY", "minioadmin")




include("base.jl")

const minio_cfg = MinioConfig(TEST_MLFLOW_S3_ENDPOINT_URL; username=TEST_AWS_ACCESS_KEY_ID, password=TEST_AWS_SECRET_ACCESS_KEY)
include("setup.jl")

include("types/mlflow.jl")

include("services/run.jl")
include("services/misc.jl")
include("services/logger.jl")
include("services/artifact.jl")
include("services/experiment.jl")
include("services/registered_model.jl")
include("services/model_version.jl")
#include("services/user.jl")
