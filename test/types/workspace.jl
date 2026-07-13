@testset verbose = true "workspace types" begin
    @testset "TraceArchivalConfig from dict" begin
        config = TraceArchivalConfig(fixture_trace_archival_config(location="s3://bucket"))
        @test config.location == "s3://bucket"
        @test config.retention == "30d"
    end

    @testset "TraceArchivalConfig defaults" begin
        config = TraceArchivalConfig(Dict{String,Any}())
        @test isnothing(config.location)
        @test isnothing(config.retention)
    end

    @testset "Workspace from dict" begin
        data = fixture_workspace(default_artifact_root="s3://root",
            trace_archival_config=fixture_trace_archival_config())
        ws = Workspace(data)
        @test ws.name == "test-workspace"
        @test ws.description == "a test workspace"
        @test ws.default_artifact_root == "s3://root"
        @test !isnothing(ws.trace_archival_config)
        @test ws.trace_archival_config.retention == "30d"
    end

    @testset "Workspace defaults" begin
        ws = Workspace(Dict{String,Any}())
        @test ws.name == ""
        @test isnothing(ws.description)
        @test isnothing(ws.default_artifact_root)
        @test isnothing(ws.trace_archival_config)
    end

    @testset "Workspace without trace_archival_config" begin
        ws = Workspace(fixture_workspace())
        @test ws.name == "test-workspace"
        @test isnothing(ws.trace_archival_config)
    end
end
