@testset verbose = true "log metric" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment_id)

    @testset "with run id as string" begin
        logmetric(mlf, run.info.run_id, "missy", 0.9)
        
        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "missy"
        @test last_metric.value == 0.9
    end

    @testset "with run" begin
        logmetric(mlf, run, "gala", 0.1)
        
        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "gala"
        @test last_metric.value == 0.1
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "log batch" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment_id)

    @testset "with run id as string" begin
        logbatch(mlf, run.info.run_id, metrics=[("gala", 0.1)])
        
        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "missy"
        @test last_metric.value == 0.9
    end

    deleteexperiment(mlf, experiment_id)
end
