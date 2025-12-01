@warn "To run this test suite, ensure to run `docker-compose -f docker-compose.test.yml up`"

ENV["GKSwstype"]="nul" # to disable plotting windows during tests
ENV["MLFLOW_TRACKING_URI"] = "http://127.0.0.1:5050/api"

include("base.jl")

const minio_cfg = MinioConfig(
    "http://127.0.0.1:9000";
    username="minioadmin",
    password="minioadmin",
)
include("setup.jl")

include("types/mlflow.jl")

include("services/run.jl")
include("services/misc.jl")
include("services/logger.jl")
include("services/artifact.jl")
include("services/experiment.jl")
include("services/registered_model.jl")
include("services/model_version.jl")
include("services/user.jl")
