# Test if MLFlow and Minio are running (see .devcontainers/compose.yaml)

@testset verbose = true "infrastructure" begin
    println("Testing if MLFlow is running")

    mlflow_up = try
        mlflow_server_is_running() 
    catch
        false 
    end
    mlflow_up || @error "The MLFlow test instance is not running. Please start it as `docker-compose -f .devcontainers/compose.yaml -up"

    @test mlflow_up
    println("Testing if Minio is running")

    minio_up = try
        minio_is_running()
    catch
        false
    end

    minio_up || @error "The Minio test instance is not running. Please start the test environment as `docker-compose -f .devcontainers/compose.yaml up`"

    @test minio_up 
end
