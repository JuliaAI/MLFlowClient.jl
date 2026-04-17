@testset verbose = true "dataset types" begin
    @testset "Dataset from dict" begin
        data = Dict{String,Any}(
            "name" => "my-dataset",
            "digest" => "abc123",
            "source_type" => "local",
            "source" => "/data/train.csv",
            "schema" => "{\"columns\": []}",
            "profile" => "{\"rows\": 1000}"
        )
        ds = Dataset(data)
        @test ds.name == "my-dataset"
        @test ds.digest == "abc123"
        @test ds.source_type == "local"
        @test ds.source == "/data/train.csv"
        @test ds.schema == "{\"columns\": []}"
        @test ds.profile == "{\"rows\": 1000}"
    end

    @testset "Dataset without optional fields" begin
        data = Dict{String,Any}(
            "name" => "ds", "digest" => "d", "source_type" => "s3", "source" => "s3://b"
        )
        ds = Dataset(data)
        @test isnothing(ds.schema)
        @test isnothing(ds.profile)
    end

    @testset "Dataset show" begin
        ds = Dataset("ds", "d", "local", "/data", nothing, nothing)
        io = IOBuffer()
        show(io, ds)
        @test !isempty(String(take!(io)))
    end

    @testset "DatasetInput from dict" begin
        data = Dict{String,Any}(
            "tags" => [Dict{String,Any}("key" => "context", "value" => "training")],
            "dataset" => Dict{String,Any}(
                "name" => "ds1", "digest" => "abc", "source_type" => "local",
                "source" => "/data"
            )
        )
        di = DatasetInput(data)
        @test length(di.tags) == 1
        @test di.tags[1].key == "context"
        @test di.dataset.name == "ds1"
    end

    @testset "DatasetInput with empty tags" begin
        data = Dict{String,Any}(
            "dataset" => Dict{String,Any}(
                "name" => "ds1", "digest" => "abc", "source_type" => "local",
                "source" => "/data"
            )
        )
        di = DatasetInput(data)
        @test isempty(di.tags)
    end

    @testset "DatasetInput show" begin
        di = DatasetInput(
            [Tag("k", "v")],
            Dataset("ds", "d", "local", "/data", nothing, nothing)
        )
        io = IOBuffer()
        show(io, di)
        @test !isempty(String(take!(io)))
    end
end
