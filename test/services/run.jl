@testset verbose = true "create run" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "base" begin
        run = createrun(mlf, experiment_id)

        @test run isa Run
        @test run.info.experiment_id == experiment_id
    end

    deleteexperiment(mlf, experiment_id)
end
