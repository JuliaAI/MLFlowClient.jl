@testset verbose = true "log metric" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "with run id as string" begin
        run = createrun(mlf, experiment_id)
        logmetric(mlf, run.info.run_id, "missy", 0.9)
        
        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "missy"
        @test last_metric.value == 0.9
        deleterun(mlf, run)
    end

    @testset "with run" begin
        run = createrun(mlf, experiment_id)
        logmetric(mlf, run, "gala", 0.1)
        
        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "gala"
        @test last_metric.value == 0.1
        deleterun(mlf, run)
    end

    @testset "with run id as string and metric" begin
        run = createrun(mlf, experiment_id)
        logmetric(mlf, run.info.run_id, Metric("missy", 0.9, 123, 1))
        
        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "missy"
        @test last_metric.value == 0.9
        @test last_metric.timestamp == 123
        @test last_metric.step == 1
        deleterun(mlf, run)
    end

    @testset "with run and metric" begin
        run = createrun(mlf, experiment_id)
        logmetric(mlf, run, Metric("gala", 0.1, 123, 1))
        
        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "gala"
        @test last_metric.value == 0.1
        @test last_metric.timestamp == 123
        @test last_metric.step == 1
        deleterun(mlf, run)
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "log batch" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "with run id as string" begin
        run = createrun(mlf, experiment_id)
        logbatch(mlf, run.info.run_id; metrics=[("gala", 0.1)])
        
        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "gala"
        @test last_metric.value == 0.1
        deleterun(mlf, run)
    end

    @testset "with run" begin
        run = createrun(mlf, experiment_id)
        logbatch(mlf, run; metrics=[("missy", 0.9)])

        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last

        @test last_metric isa Metric
        @test last_metric.key == "missy"
        @test last_metric.value == 0.9
        deleterun(mlf, run)
    end

    @testset "with metrics, params and tags as dict" begin
        run = createrun(mlf, experiment_id)
        logbatch(mlf, run; metrics=Dict("ana" => 0.5),
            params=Dict("test_param" => "0.9"),
            tags=Dict("test_tag" => "gala"))

        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last
        last_param = run.data.params |> last
        last_tag = run.data.tags[
            findall(x -> !occursin("mlflow.runName", x.key), run.data.tags)[1]]
        
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
        logbatch(mlf, run; metrics=["ana" => 0.5],
            params=["test_param" => "0.9"], tags=["test_tag" => "gala"])

        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last
        last_param = run.data.params |> last
        last_tag = run.data.tags[
            findall(x -> !occursin("mlflow.runName", x.key), run.data.tags)[1]]
        
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
        logbatch(mlf, run; metrics=[("ana", 0.5)],
            params=[("test_param", "0.9")], tags=[("test_tag", "gala")])

        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last
        last_param = run.data.params |> last
        last_tag = run.data.tags[
            findall(x -> !occursin("mlflow.runName", x.key), run.data.tags)[1]]
        
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
        logbatch(mlf, run;
            metrics=[Dict("key" => "ana", "value" => 0.5, "timestamp" => 123)],
            params=[Dict("key" => "test_param", "value" => "0.9")],
            tags=[Dict("key" => "test_tag", "value" => "gala")])

        run = refresh(mlf, run)
        last_metric = run.data.metrics |> last
        last_param = run.data.params |> last
        last_tag = run.data.tags[
            findall(x -> !occursin("mlflow.runName", x.key), run.data.tags)[1]]
        
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

@testset verbose = true "log inputs" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "with run id as string" begin
        run = createrun(mlf, experiment_id)
        inputs = [DatasetInput([Tag("tag_key", "tag_value")],
            Dataset("dataset_name", "dataset_digest", "dataset_source_type",
                "dataset_source", nothing, nothing))]
        loginputs(mlf, run.info.run_id, inputs)

        run = refresh(mlf, run)

        @test run.inputs.dataset_inputs |> length == 1

        dataset_input = run.inputs.dataset_inputs |> first
        dataset_input_tag = dataset_input.tags |> first

        @test dataset_input_tag isa Tag
        @test dataset_input_tag.key == "tag_key"
        @test dataset_input_tag.value == "tag_value"

        @test dataset_input.dataset isa Dataset
        @test dataset_input.dataset.name == "dataset_name"
        @test dataset_input.dataset.digest == "dataset_digest"
        @test dataset_input.dataset.source_type == "dataset_source_type"
        @test dataset_input.dataset.source == "dataset_source"
        @test dataset_input.dataset.schema |> isnothing
        @test dataset_input.dataset.profile |> isnothing
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "log param" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "with run id as string" begin
        run = createrun(mlf, experiment_id)
        logparam(mlf, run.info.run_id, "missy", "0.9")
        
        run = refresh(mlf, run)
        last_param = run.data.params |> last

        @test last_param isa Param
        @test last_param.key == "missy"
        @test last_param.value == "0.9"
        deleterun(mlf, run)
    end

    @testset "with run" begin
        run = createrun(mlf, experiment_id)
        logparam(mlf, run, "gala", "0.1")
        
        run = refresh(mlf, run)
        last_param = run.data.params |> last

        @test last_param isa Param
        @test last_param.key == "gala"
        @test last_param.value == "0.1"
        deleterun(mlf, run)
    end

    @testset "with run id as string and param" begin
        run = createrun(mlf, experiment_id)
        logparam(mlf, run.info.run_id, Param("missy", "0.9"))
        
        run = refresh(mlf, run)
        last_param = run.data.params |> last

        @test last_param isa Param
        @test last_param.key == "missy"
        @test last_param.value == "0.9"
        deleterun(mlf, run)
    end

    @testset "with run and param" begin
        run = createrun(mlf, experiment_id)
        logparam(mlf, run, Param("gala", "0.1"))
        
        run = refresh(mlf, run)
        last_param = run.data.params |> last

        @test last_param isa Param
        @test last_param.key == "gala"
        @test last_param.value == "0.1"
        deleterun(mlf, run)
    end

    deleteexperiment(mlf, experiment_id)
end
