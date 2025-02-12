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
