@testset verbose = true "label schema service" begin
    @ensuremlf
    mlf === nothing && return nothing

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    schema_name = UUIDs.uuid4() |> string
    input = Dict("categorical" => Dict("options" => ["good", "bad"], "multi_select" => false))

    local schema_id = ""

    @testset "create label schema" begin
        schema = createlabelschema(mlf, experiment_id, schema_name, "FEEDBACK", input;
            instruction="Rate the response", enable_comment=true)
        @test schema isa LabelSchema
        @test schema.experiment_id == experiment_id
        @test schema.name == schema_name
        @test schema.type == "FEEDBACK"
        @test schema.instruction == "Rate the response"
        @test schema.enable_comment == true
        @test !isnothing(schema.input)
        @test !isempty(schema.schema_id)
        schema_id = schema.schema_id
    end

    @testset "get label schema" begin
        schema = getlabelschema(mlf, schema_id)
        @test schema isa LabelSchema
        @test schema.schema_id == schema_id
        @test schema.name == schema_name
    end

    @testset "get label schema by name" begin
        schema = getlabelschemabyname(mlf, experiment_id, schema_name)
        @test schema isa LabelSchema
        @test schema.schema_id == schema_id
        @test schema.name == schema_name
    end

    @testset "list label schemas" begin
        schemas, next_page_token = listlabelschemas(mlf, experiment_id)
        @test schemas isa Array{LabelSchema}
        @test any(s -> s.schema_id == schema_id, schemas)
        @test next_page_token isa Union{String,Nothing}
    end

    @testset "update label schema" begin
        updated = updatelabelschema(mlf, schema_id; instruction="Updated instruction")
        @test updated isa LabelSchema
        @test updated.schema_id == schema_id
        @test updated.instruction == "Updated instruction"
    end

    @testset "delete label schema" begin
        @test deletelabelschema(mlf, schema_id)
        schemas, _ = listlabelschemas(mlf, experiment_id)
        @test !any(s -> s.schema_id == schema_id, schemas)
    end

    deleteexperiment(mlf, experiment_id)
end
