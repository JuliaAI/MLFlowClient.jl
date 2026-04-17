@testset verbose = true "run types" begin
    @testset "Metric from dict" begin
        data = Dict{String,Any}("key" => "accuracy", "value" => 0.95, "timestamp" => 1700000000000, "step" => 10)
        metric = Metric(data)
        @test metric.key == "accuracy"
        @test metric.value == 0.95
        @test metric.timestamp == 1700000000000
        @test metric.step == 10
    end

    @testset "Metric show" begin
        metric = Metric("acc", 0.9, 123, 1)
        io = IOBuffer()
        show(io, metric)
        @test !isempty(String(take!(io)))
    end

    @testset "Param from dict" begin
        data = Dict{String,Any}("key" => "lr", "value" => "0.01")
        param = Param(data)
        @test param.key == "lr"
        @test param.value == "0.01"
    end

    @testset "Param show" begin
        param = Param("lr", "0.01")
        io = IOBuffer()
        show(io, param)
        @test !isempty(String(take!(io)))
    end

    @testset "RunInfo from dict" begin
        data = fixture_run_info(end_time=1700001000000)
        info = RunInfo(data)
        @test info.run_id == "abc123"
        @test info.run_name == "test-run"
        @test info.experiment_id == "1"
        @test info.status == RunStatus.RUNNING
        @test info.start_time == 1700000000000
        @test info.end_time == 1700001000000
        @test info.artifact_uri == "mlflow-artifacts:/0/abc123/artifacts"
        @test info.lifecycle_stage == "active"
    end

    @testset "RunInfo without end_time" begin
        data = fixture_run_info()
        info = RunInfo(data)
        @test isnothing(info.end_time)
    end

    @testset "RunInfo show" begin
        data = fixture_run_info()
        info = RunInfo(data)
        io = IOBuffer()
        show(io, info)
        @test !isempty(String(take!(io)))
    end

    @testset "RunData from dict" begin
        data = Dict{String,Any}(
            "metrics" => [Dict{String,Any}("key" => "acc", "value" => 0.9, "timestamp" => 123, "step" => 1)],
            "params" => [Dict{String,Any}("key" => "lr", "value" => "0.01")],
            "tags" => [Dict{String,Any}("key" => "env", "value" => "test")]
        )
        rd = RunData(data)
        @test length(rd.metrics) == 1
        @test rd.metrics[1].key == "acc"
        @test length(rd.params) == 1
        @test rd.params[1].key == "lr"
        @test length(rd.tags) == 1
        @test rd.tags[1].key == "env"
    end

    @testset "RunData empty" begin
        rd = RunData(Dict{String,Any}())
        @test isempty(rd.metrics)
        @test isempty(rd.params)
        @test isempty(rd.tags)
    end

    @testset "RunData show" begin
        rd = RunData(Dict{String,Any}())
        io = IOBuffer()
        show(io, rd)
        @test !isempty(String(take!(io)))
    end

    @testset "RunInputs from dict" begin
        data = Dict{String,Any}(
            "dataset_inputs" => [Dict{String,Any}(
                "tags" => [Dict{String,Any}("key" => "context", "value" => "training")],
                "dataset" => Dict{String,Any}(
                    "name" => "ds1", "digest" => "abc", "source_type" => "local",
                    "source" => "/data"
                )
            )],
            "model_inputs" => [Dict{String,Any}("model_id" => "model-1")]
        )
        ri = RunInputs(data)
        @test length(ri.dataset_inputs) == 1
        @test ri.dataset_inputs[1].dataset.name == "ds1"
        @test length(ri.model_inputs) == 1
        @test ri.model_inputs[1].model_id == "model-1"
    end

    @testset "RunInputs empty" begin
        ri = RunInputs(Dict{String,Any}())
        @test isempty(ri.dataset_inputs)
        @test isempty(ri.model_inputs)
    end

    @testset "RunInputs show" begin
        ri = RunInputs(Dict{String,Any}())
        io = IOBuffer()
        show(io, ri)
        @test !isempty(String(take!(io)))
    end

    @testset "RunOutputs from dict" begin
        data = Dict{String,Any}(
            "model_outputs" => [Dict{String,Any}("model_id" => "model-1", "step" => 5)]
        )
        ro = RunOutputs(data)
        @test length(ro.model_outputs) == 1
        @test ro.model_outputs[1].model_id == "model-1"
        @test ro.model_outputs[1].step == 5
    end

    @testset "RunOutputs empty" begin
        ro = RunOutputs(Dict{String,Any}())
        @test isempty(ro.model_outputs)
    end

    @testset "RunOutputs show" begin
        ro = RunOutputs(Dict{String,Any}())
        io = IOBuffer()
        show(io, ro)
        @test !isempty(String(take!(io)))
    end

    @testset "Run from dict" begin
        data = fixture_run(
            metrics=[Dict{String,Any}("key" => "acc", "value" => 0.9, "timestamp" => 123, "step" => 1)],
            params=[Dict{String,Any}("key" => "lr", "value" => "0.01")],
            tags=[Dict{String,Any}("key" => "env", "value" => "test")]
        )
        run = Run(data)
        @test run.info isa RunInfo
        @test run.data isa RunData
        @test run.inputs isa RunInputs
        @test run.outputs isa RunOutputs
        @test run.info.run_id == "abc123"
        @test length(run.data.metrics) == 1
    end

    @testset "Run without outputs" begin
        data = fixture_run()
        # outputs key not present -> should default to empty
        run = Run(data)
        @test run.outputs isa RunOutputs
        @test isempty(run.outputs.model_outputs)
    end

    @testset "Run with outputs" begin
        data = fixture_run()
        data["outputs"] = Dict{String,Any}(
            "model_outputs" => [Dict{String,Any}("model_id" => "m1", "step" => 1)]
        )
        run = Run(data)
        @test length(run.outputs.model_outputs) == 1
    end

    @testset "Run show" begin
        data = fixture_run()
        run = Run(data)
        io = IOBuffer()
        show(io, run)
        @test !isempty(String(take!(io)))
    end
end
