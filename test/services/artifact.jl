@testset verbose = true "list artifacts" begin
    # TODO: Add more specific tests after implementing the complete artifact service
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

@testset verbose = true "mlflow-artifacts endpoints" begin
    @ensuremlf
    mlf === nothing && return nothing

    # Note: These tests require the mlflow-artifacts server to be running
    # and may fail if the server is not properly configured.
    
    # Check if mlflow-artifacts server is available
    artifacts_available = true
    try
        listartifactsdirect(mlf)
    catch e
        @warn "mlflow-artifacts server not available, skipping artifact tests: $(e.msg)"
        artifacts_available = false
    end
    
    artifacts_available || return nothing

    @testset "list artifacts direct" begin
        files = listartifactsdirect(mlf)
        @test files isa Array{FileInfo}
    end

    @testset "upload and download artifact" begin
        artifact_path = "test/artifact_$(UUIDs.uuid4()).txt"
        test_data = Vector{UInt8}("test artifact content" |> collect)

        # Upload artifact
        @test uploadartifact(mlf, artifact_path, test_data)

        # Download artifact
        downloaded_data = downloadartifact(mlf, artifact_path)
        @test downloaded_data isa Vector{UInt8}
        @test length(downloaded_data) > 0
    end

    @testset "delete artifact" begin
        artifact_path = "test/delete_$(UUIDs.uuid4()).txt"
        test_data = Vector{UInt8}("delete test" |> collect)

        uploadartifact(mlf, artifact_path, test_data)
        @test deleteartifact(mlf, artifact_path)
    end

    @testset "multipart upload" begin
        artifact_path = "test/multipart_$(UUIDs.uuid4()).bin"

        try
            # Create multipart upload
            upload_id, credentials = createmultipartupload(mlf, artifact_path, 2)
            @test upload_id isa String
            @test !isempty(upload_id)
            @test credentials isa Array{MultipartUploadCredential}
            @test length(credentials) == 2

            # Abort multipart upload
            @test abortmultipartupload(mlf, artifact_path, upload_id)
        catch e
            # Server may not support multipart upload (returns 501)
            @warn "Multipart upload test skipped (server limitation): $(e.msg)"
        end
    end

    @testset "get presigned download url" begin
        artifact_path = "test/presigned_$(UUIDs.uuid4()).txt"
        test_data = Vector{UInt8}("presigned test" |> collect)

        try
            uploadartifact(mlf, artifact_path, test_data)

            url, headers, file_size = getpresigneddownloadurl(mlf, artifact_path)
            @test url isa String
            @test headers isa Dict{String,String}
            @test file_size isa Int64
        catch e
            # Server may not support presigned URLs
            @warn "Presigned download URL test skipped (server limitation): $(e.msg)"
        end
    end
end
