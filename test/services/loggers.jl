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

    @testset "with run id as string" begin
        run = createrun(mlf, experiment_id)
        logbatch(mlf, run.info.run_id, metrics=[("gala", 0.1)])
        
        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "gala"
        @test last_metric.value == 0.1
        deleterun(mlf, run)
    end

    @testset "with run" begin
        run = createrun(mlf, experiment_id)
        logbatch(mlf, run, metrics=[("missy", 0.9)])

        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "missy"
        @test last_metric.value == 0.9
        deleterun(mlf, run)
    end

    @testset "with metrics, params and tags as dict" begin
        run = createrun(mlf, experiment_id)
        logbatch(mlf, run, metrics=Dict("ana" => 0.5),
            params=Dict("test_param" => "0.9"),
            tags=Dict("test_tag" => "gala"))

        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last
        last_param = run.data.params |> last
        last_tag = run.data.tags |> first
        
        @test last_metric isa Metric
        @test last_metric.key == "ana"
        @test last_metric.value == 0.5

        @test last_param isa Param
        @test last_param.key == "test_param"
        @test last_param.value == "0.9"

        @test last_tag isa Tag
        @test last_tag.key == "test_tag"
        @test last_tag.value == "gala"

        deleterun(mlf, run)
    end

    @testset "with metrics, params and tags as pair array" begin
        run = createrun(mlf, experiment_id)
        logbatch(mlf, run, metrics=["ana" => 0.5],
            params=["test_param" => "0.9"], tags=["test_tag" => "gala"])

        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last
        last_param = run.data.params |> last
        last_tag = run.data.tags |> first
        
        @test last_metric isa Metric
        @test last_metric.key == "ana"
        @test last_metric.value == 0.5

        @test last_param isa Param
        @test last_param.key == "test_param"
        @test last_param.value == "0.9"

        @test last_tag isa Tag
        @test last_tag.key == "test_tag"
        @test last_tag.value == "gala"

        deleterun(mlf, run)
    end

    @testset "with metrics, params and tags as tuple array" begin
        run = createrun(mlf, experiment_id)
        logbatch(mlf, run, metrics=[("ana", 0.5)],
            params=[("test_param", "0.9")], tags=[("test_tag", "gala")])

        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last
        last_param = run.data.params |> last
        last_tag = run.data.tags |> first
        
        @test last_metric isa Metric
        @test last_metric.key == "ana"
        @test last_metric.value == 0.5

        @test last_param isa Param
        @test last_param.key == "test_param"
        @test last_param.value == "0.9"

        @test last_tag isa Tag
        @test last_tag.key == "test_tag"
        @test last_tag.value == "gala"

        deleterun(mlf, run)
    end

    @testset "with metrics, params and tags as dict array" begin
        run = createrun(mlf, experiment_id)
        logbatch(mlf, run,
            metrics=[Dict("key" => "ana", "value" => 0.5, "timestamp" => 123)],
            params=[Dict("key" => "test_param", "value" => "0.9")],
            tags=[Dict("key" => "test_tag", "value" => "gala")])

        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last
        last_param = run.data.params |> last
        last_tag = run.data.tags |> first
        
        @test last_metric isa Metric
        @test last_metric.key == "ana"
        @test last_metric.value == 0.5
        @test last_metric.timestamp == 123

        @test last_param isa Param
        @test last_param.key == "test_param"
        @test last_param.value == "0.9"

        @test last_tag isa Tag
        @test last_tag.key == "test_tag"
        @test last_tag.value == "gala"

        deleterun(mlf, run)
    end

    deleteexperiment(mlf, experiment_id)
end
