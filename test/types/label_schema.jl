@testset verbose = true "label schema types" begin
    @testset "InputPassFail from dict" begin
        input = InputPassFail(Dict("positive_label" => "Correct",
            "negative_label" => "Incorrect"))
        @test input.positive_label == "Correct"
        @test input.negative_label == "Incorrect"
    end

    @testset "InputPassFail defaults" begin
        input = InputPassFail(Dict{String,Any}())
        @test isnothing(input.positive_label)
        @test isnothing(input.negative_label)
    end

    @testset "InputCategorical from dict" begin
        input = InputCategorical(Dict("options" => ["a", "b", "c"], "multi_select" => true))
        @test input.options == ["a", "b", "c"]
        @test input.multi_select == true
    end

    @testset "InputCategorical defaults" begin
        input = InputCategorical(Dict{String,Any}())
        @test isempty(input.options)
        @test input.multi_select == false
    end

    @testset "InputNumeric from dict" begin
        input = InputNumeric(Dict("min_value" => 0.0, "max_value" => 10.0))
        @test input.min_value == 0.0
        @test input.max_value == 10.0
    end

    @testset "InputNumeric defaults" begin
        input = InputNumeric(Dict{String,Any}())
        @test isnothing(input.min_value)
        @test isnothing(input.max_value)
    end

    @testset "InputText from dict" begin
        input = InputText(Dict("max_length" => 500))
        @test input.max_length == 500
    end

    @testset "InputText defaults" begin
        input = InputText(Dict{String,Any}())
        @test isnothing(input.max_length)
    end

    @testset "LabelSchemaInput with categorical variant" begin
        wrapper = LabelSchemaInput(Dict("categorical" =>
            Dict("options" => ["good", "bad"], "multi_select" => false)))
        @test !isnothing(wrapper.categorical)
        @test wrapper.categorical.options == ["good", "bad"]
        @test isnothing(wrapper.pass_fail)
        @test isnothing(wrapper.numeric)
        @test isnothing(wrapper.text)
    end

    @testset "LabelSchemaInput with numeric variant" begin
        wrapper = LabelSchemaInput(Dict("numeric" =>
            Dict("min_value" => 1.0, "max_value" => 5.0)))
        @test !isnothing(wrapper.numeric)
        @test wrapper.numeric.min_value == 1.0
        @test isnothing(wrapper.categorical)
    end

    @testset "LabelSchema from dict" begin
        schema = LabelSchema(fixture_label_schema())
        @test schema.schema_id == "ls-abc"
        @test schema.experiment_id == "1"
        @test schema.name == "quality"
        @test schema.type == "FEEDBACK"
        @test schema.instruction == "Rate the response"
        @test schema.enable_comment == true
        @test !isnothing(schema.input)
        @test schema.input.categorical.options == ["good", "bad"]
        @test schema.created_by == "user1"
        @test schema.created_at == 1700000000000
        @test schema.last_updated_at == 1700000000000
        @test schema.is_default == false
    end

    @testset "LabelSchema defaults" begin
        schema = LabelSchema(Dict{String,Any}())
        @test schema.schema_id == ""
        @test schema.experiment_id == ""
        @test schema.name == ""
        @test schema.type == ""
        @test schema.instruction == ""
        @test schema.enable_comment == false
        @test isnothing(schema.input)
        @test schema.is_default == false
    end

    @testset "LabelSchema with integer experiment_id" begin
        schema = LabelSchema(fixture_label_schema(experiment_id=42))
        @test schema.experiment_id == "42"
    end
end
