@testset verbose = true "instantiate mlflow" begin
    mlflow_tracking_uri = ENV["MLFLOW_TRACKING_URI"]

    @testset "using default constructor" begin
        delete!(ENV, "MLFLOW_TRACKING_URI")

        instance = MLFlow("test", 2.0, Dict(), nothing, nothing)

        @test instance.apiroot == "test"
        @test instance.apiversion == 2.0
        @test instance.headers == Dict()
        @test isnothing(instance.username)
        @test isnothing(instance.password)

        ENV["MLFLOW_TRACKING_URI"] = mlflow_tracking_uri
    end

    @testset "using apiroot-only constructor" begin
        delete!(ENV, "MLFLOW_TRACKING_URI")

        instance = MLFlow("test")

        @test instance.apiroot == "test"
        @test instance.apiversion == 2.0
        @test instance.headers == Dict()
        @test isnothing(instance.username)
        @test isnothing(instance.password)

        ENV["MLFLOW_TRACKING_URI"] = mlflow_tracking_uri
    end

    @testset "using constructor with keyword arguments" begin
        delete!(ENV, "MLFLOW_TRACKING_URI")

        instance = MLFlow(; username="test", password="test")

        @test instance.apiroot == "http://localhost:5000/api"
        @test instance.apiversion == 2.0
        @test haskey(instance.headers, "Authorization")
        @test instance.username == "test"
        @test instance.password == "test"

        ENV["MLFLOW_TRACKING_URI"] = mlflow_tracking_uri
    end

    @testset "using env variables" begin
        mlflow_tracking_username =
            haskey(ENV, "MLFLOW_TRACKING_USERNAME") ? ENV["MLFLOW_TRACKING_USERNAME"] : nothing
        mlflow_tracking_password =
            haskey(ENV, "MLFLOW_TRACKING_PASSWORD") ? ENV["MLFLOW_TRACKING_PASSWORD"] : nothing

        ENV["MLFLOW_TRACKING_USERNAME"] = "test"
        ENV["MLFLOW_TRACKING_PASSWORD"] = "test"

        @test_logs (:warn, "The provided apiroot will be ignored as MLFLOW_TRACKING_URI is set.") (:warn, "The provided username will be ignored as MLFLOW_TRACKING_USERNAME is set.") (:warn, "The provided password will be ignored as MLFLOW_TRACKING_PASSWORD is set.") MLFlow()

        if !isnothing(mlflow_tracking_username)
            ENV["MLFLOW_TRACKING_USERNAME"] = mlflow_tracking_username
        else
            delete!(ENV, "MLFLOW_TRACKING_USERNAME")
        end
        if !isnothing(mlflow_tracking_password)
            ENV["MLFLOW_TRACKING_PASSWORD"] = mlflow_tracking_password
        else
            delete!(ENV, "MLFLOW_TRACKING_PASSWORD")
        end
    end

    @testset "defining username, password and authorization header" begin
        encoded_credentials = Base64.base64encode("test:test")
        @test_throws ErrorException MLFlow(; username="test", password="test",
            headers=Dict("Authorization" => "Basic $encoded_credentials"))
    end
end
