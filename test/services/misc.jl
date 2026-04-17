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

    @testset "with pagination" begin
        metrics, next_page_token = getmetrichistory(mlf, run.info.run_id, "missy";
            max_results=5)

        @test length(metrics) == 5
        @test next_page_token |> !isnothing

        # Fetch next page
        metrics2, _ = getmetrichistory(mlf, run.info.run_id, "missy";
            page_token=next_page_token, max_results=5)
        @test length(metrics2) == 5
    end

    @testset "with Metric argument" begin
        metric = Metric("missy", 0.0, 0, nothing)
        metrics, _ = getmetrichistory(mlf, run, metric; max_results=3)
        @test length(metrics) == 3
        @test all(m -> m.key == "missy", metrics)
    end

    @testset "refresh run" begin
        refreshed = refresh(mlf, run)
        @test refreshed isa Run
        @test refreshed.info.run_id == run.info.run_id
    end

    @testset "refresh experiment" begin
        experiment = getexperiment(mlf, experiment_id)
        refreshed = refresh(mlf, experiment)
        @test refreshed isa Experiment
        @test refreshed.experiment_id == experiment.experiment_id
    end

    deleteexperiment(mlf, experiment_id)
end
