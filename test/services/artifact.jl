@testset verbose = true "list artifacts" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment_id)

    @testset "using run id" begin
        root_uri, files, next_page_token = listartifacts(mlf, run.info.run_id)

        @test run.info.artifact_uri == root_uri
        @test isempty(files)
        @test isnothing(next_page_token)
    end

    @testset "using run" begin
        root_uri, files, next_page_token = listartifacts(mlf, run)

        @test run.info.artifact_uri == root_uri
        @test isempty(files)
        @test isnothing(next_page_token)
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "mlflow-artifacts proxy" begin
    @ensuremlf

    # Check if mlflow-artifacts server is available
    artifacts_available = true
    try
        listartifactsdirect(mlf)
    catch e
        @warn "mlflow-artifacts server not available, skipping artifact proxy tests"
        artifacts_available = false
    end

    artifacts_available || return nothing

    @testset "list artifacts direct" begin
        files = listartifactsdirect(mlf)
        @test files isa Array{FileInfo}
    end

    @testset "upload and download artifact" begin
        artifact_path = "test/artifact_$(UUIDs.uuid4()).txt"
        test_content = "test artifact content for MLFlowClient.jl"
        test_data = Vector{UInt8}(codeunits(test_content))

        @test uploadartifact(mlf, artifact_path, test_data)

        downloaded_data = downloadartifact(mlf, artifact_path)
        @test downloaded_data isa Vector{UInt8}
        @test String(downloaded_data) == test_content

        # Clean up
        deleteartifact(mlf, artifact_path)
    end

    @testset "list artifacts direct with path" begin
        # Upload a file to a subdirectory first
        artifact_path = "test/subdir_$(UUIDs.uuid4())/file.txt"
        test_data = Vector{UInt8}(codeunits("subdir test"))
        uploadartifact(mlf, artifact_path, test_data)

        files = listartifactsdirect(mlf; path="test")
        @test files isa Array{FileInfo}
        @test !isempty(files)

        # Verify FileInfo fields
        for f in files
            @test f.path isa String
            @test f.is_dir isa Bool
            @test f.file_size isa Int64
        end

        deleteartifact(mlf, artifact_path)
    end

    @testset "delete artifact" begin
        artifact_path = "test/delete_$(UUIDs.uuid4()).txt"
        test_data = Vector{UInt8}(codeunits("delete test"))

        uploadartifact(mlf, artifact_path, test_data)
        @test deleteartifact(mlf, artifact_path)
    end

    @testset "get presigned download url" begin
        artifact_path = "test/presigned_$(UUIDs.uuid4()).txt"
        test_data = Vector{UInt8}(codeunits("presigned test"))

        uploadartifact(mlf, artifact_path, test_data)

        try
            url, resp_headers, file_size = getpresigneddownloadurl(mlf, artifact_path)
            @test url isa String
            @test resp_headers isa Dict{String,String}
            @test file_size isa Int64
        catch e
            @warn "Presigned download URL not supported on this server"
        end

        deleteartifact(mlf, artifact_path)
    end
end
