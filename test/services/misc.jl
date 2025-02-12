@testset verbose = true "get metric history" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment_id)
    for i in 1:20
        logmetric(mlf, run, "missy", i |> Float64)
    end

    @testset "default search" begin
        metrics, next_page_token = getmetrichistory(mlf, run, "missy")

        @test length(metrics) == 20
        @test next_page_token |> isnothing
    end

    deleteexperiment(mlf, experiment_id)
end
