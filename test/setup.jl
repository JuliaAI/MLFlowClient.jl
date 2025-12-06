# Test if MLFlow and Minio are running (see .devcontainers/compose.yaml)

@testset verbose = true "infrastructure" begin
    mlflow_up = try
        mlflow_server_is_running() 
    catch
        false 
    end
    mlflow_up || @error "The MLFlow test instance is not running."

    @test mlflow_up

    minio_up = try
        minio_is_running()
    catch
        false
    end

    minio_up || @error "The MiniO test instance is not running."

    @test minio_up 
end
