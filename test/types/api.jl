@testset verbose = true "API URI construction" begin
    mlf = mock_mlf()

    @testset "uri v2.0" begin
        u = MLFlowClient.uri(mlf, "experiments/get")
        u_str = string(u)
        @test occursin("2.0/mlflow/experiments/get", u_str)
        @test occursin("mock-server:5000", u_str)
    end

    @testset "uri v2.0 with parameters" begin
        u = MLFlowClient.uri(mlf, "experiments/get";
            parameters=Dict{Symbol,Any}(:experiment_id => "1"))
        u_str = string(u)
        @test occursin("experiment_id=1", u_str)
    end

    @testset "uri_v3" begin
        u = MLFlowClient.uri_v3(mlf, "scorers/list")
        u_str = string(u)
        @test occursin("3.0/mlflow/scorers/list", u_str)
        @test occursin("mock-server:5000", u_str)
    end

    @testset "uri_v3 with parameters" begin
        u = MLFlowClient.uri_v3(mlf, "scorers/get";
            parameters=Dict{Symbol,Any}(:experiment_id => "1", :name => "test"))
        u_str = string(u)
        @test occursin("experiment_id=1", u_str)
        @test occursin("name=test", u_str)
    end

    @testset "uri_artifacts" begin
        u = MLFlowClient.uri_artifacts(mlf, "artifacts/test.txt")
        u_str = string(u)
        @test occursin("2.0/mlflow-artifacts/artifacts/test.txt", u_str)
        @test occursin("mock-server:5000", u_str)
    end

    @testset "uri_artifacts with parameters" begin
        u = MLFlowClient.uri_artifacts(mlf, "artifacts";
            parameters=Dict{Symbol,Any}(:path => "subdir"))
        u_str = string(u)
        @test occursin("path=subdir", u_str)
    end

    @testset "headers merging" begin
        h = MLFlowClient.headers(mlf, Dict("Content-Type" => "application/json"))
        @test h["Content-Type"] == "application/json"
    end

    @testset "headers merging with existing" begin
        old_uri = get(ENV, "MLFLOW_TRACKING_URI", nothing)
        haskey(ENV, "MLFLOW_TRACKING_URI") && delete!(ENV, "MLFLOW_TRACKING_URI")

        mlf_with_auth = MLFlow("http://test:5000/api"; username="user", password="pass")
        h = MLFlowClient.headers(mlf_with_auth, Dict("Content-Type" => "application/json"))
        @test haskey(h, "Authorization")
        @test h["Content-Type"] == "application/json"

        !isnothing(old_uri) && (ENV["MLFLOW_TRACKING_URI"] = old_uri)
    end
end
