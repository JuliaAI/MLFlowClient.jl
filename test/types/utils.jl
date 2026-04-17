@testset verbose = true "utils conversion functions" begin
    @testset "dict_to_T_array for Tag" begin
        dict = Dict{String,String}("key1" => "value1", "key2" => "value2")
        tags = MLFlowClient.dict_to_T_array(Tag, dict)
        @test length(tags) == 2
        @test all(t -> t isa Tag, tags)
        keys_found = Set([t.key for t in tags])
        @test "key1" in keys_found
        @test "key2" in keys_found
    end

    @testset "dict_to_T_array for Param" begin
        dict = Dict{String,String}("lr" => "0.01", "epochs" => "10")
        params = MLFlowClient.dict_to_T_array(Param, dict)
        @test length(params) == 2
        @test all(p -> p isa Param, params)
    end

    @testset "dict_to_T_array for Metric" begin
        dict = Dict{String,Number}("accuracy" => 0.95, "loss" => 0.05)
        metrics = MLFlowClient.dict_to_T_array(Metric, dict)
        @test length(metrics) == 2
        @test all(m -> m isa Metric, metrics)
        @test all(m -> m.timestamp > 0, metrics)
        @test all(m -> isnothing(m.step), metrics)
    end

    @testset "pairarray_to_T_array for Tag" begin
        pairs = ["key1" => "value1", "key2" => "value2"]
        tags = MLFlowClient.pairarray_to_T_array(Tag, pairs)
        @test length(tags) == 2
        @test tags[1].key == "key1"
        @test tags[1].value == "value1"
    end

    @testset "pairarray_to_T_array for Param" begin
        pairs = ["lr" => "0.01"]
        params = MLFlowClient.pairarray_to_T_array(Param, pairs)
        @test length(params) == 1
        @test params[1].key == "lr"
        @test params[1].value == "0.01"
    end

    @testset "pairarray_to_T_array for Metric" begin
        pairs = ["accuracy" => 0.95]
        metrics = MLFlowClient.pairarray_to_T_array(Metric, pairs)
        @test length(metrics) == 1
        @test metrics[1].key == "accuracy"
        @test metrics[1].value == 0.95
        @test metrics[1].timestamp > 0
    end

    @testset "tuplearray_to_T_array for Tag" begin
        tuples = [("key1", "value1"), ("key2", "value2")]
        tags = MLFlowClient.tuplearray_to_T_array(Tag, tuples)
        @test length(tags) == 2
        @test tags[1].key == "key1"
        @test tags[1].value == "value1"
    end

    @testset "tuplearray_to_T_array for Param" begin
        tuples = [("lr", "0.01")]
        params = MLFlowClient.tuplearray_to_T_array(Param, tuples)
        @test length(params) == 1
        @test params[1].key == "lr"
        @test params[1].value == "0.01"
    end

    @testset "tuplearray_to_T_array for Metric" begin
        tuples = [("accuracy", 0.95)]
        metrics = MLFlowClient.tuplearray_to_T_array(Metric, tuples)
        @test length(metrics) == 1
        @test metrics[1].key == "accuracy"
        @test metrics[1].value == 0.95
    end

    @testset "dictarray_to_T_array for Tag" begin
        dicts = [Dict{String,Any}("key" => "k1", "value" => "v1")]
        tags = MLFlowClient.dictarray_to_T_array(Tag, dicts)
        @test length(tags) == 1
        @test tags[1].key == "k1"
        @test tags[1].value == "v1"
    end

    @testset "dictarray_to_T_array for Param" begin
        dicts = [Dict{String,Any}("key" => "lr", "value" => "0.01")]
        params = MLFlowClient.dictarray_to_T_array(Param, dicts)
        @test length(params) == 1
        @test params[1].key == "lr"
        @test params[1].value == "0.01"
    end

    @testset "dictarray_to_T_array for Metric with timestamp" begin
        dicts = [Dict{String,Any}("key" => "acc", "value" => 0.9, "timestamp" => 12345)]
        metrics = MLFlowClient.dictarray_to_T_array(Metric, dicts)
        @test length(metrics) == 1
        @test metrics[1].key == "acc"
        @test metrics[1].value == 0.9
        @test metrics[1].timestamp == 12345
    end

    @testset "dictarray_to_T_array for Metric without timestamp" begin
        dicts = [Dict{String,Any}("key" => "acc", "value" => 0.9)]
        metrics = MLFlowClient.dictarray_to_T_array(Metric, dicts)
        @test length(metrics) == 1
        @test metrics[1].timestamp > 0  # auto-generated
    end

    @testset "parse dispatches correctly for Tag array" begin
        tags = [Tag("k", "v")]
        result = MLFlowClient.parse(Tag, tags)
        @test result === tags
    end

    @testset "parse dispatches correctly for Dict" begin
        dict = Dict{String,String}("k" => "v")
        result = MLFlowClient.parse(Tag, dict)
        @test length(result) == 1
        @test result[1] isa Tag
    end

    @testset "parse dispatches correctly for Pair array" begin
        pairs = ["k" => "v"]
        result = MLFlowClient.parse(Tag, pairs)
        @test length(result) == 1
        @test result[1] isa Tag
    end

    @testset "parse dispatches correctly for Tuple array" begin
        tuples = [("k", "v")]
        result = MLFlowClient.parse(Tag, tuples)
        @test length(result) == 1
        @test result[1] isa Tag
    end

    @testset "parse dispatches correctly for Dict array" begin
        dicts = [Dict{String,Any}("key" => "k", "value" => "v")]
        result = MLFlowClient.parse(Tag, dicts)
        @test length(result) == 1
        @test result[1] isa Tag
    end
end
