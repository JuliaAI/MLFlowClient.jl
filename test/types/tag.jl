@testset verbose = true "tag types" begin
    @testset "Tag from dict" begin
        data = Dict{String,Any}("key" => "env", "value" => "production")
        tag = Tag(data)
        @test tag.key == "env"
        @test tag.value == "production"
    end

    @testset "Tag from dict with numeric value" begin
        data = Dict{String,Any}("key" => "version", "value" => 42)
        tag = Tag(data)
        @test tag.key == "version"
        @test tag.value == "42"  # converted to string
    end

    @testset "Tag direct constructor" begin
        tag = Tag("key1", "value1")
        @test tag.key == "key1"
        @test tag.value == "value1"
    end

    @testset "Tag show" begin
        tag = Tag("k", "v")
        io = IOBuffer()
        show(io, tag)
        @test !isempty(String(take!(io)))
    end
end
