@testset verbose = true "scorer types" begin
    @testset "Scorer from dict" begin
        data = fixture_scorer()
        scorer = Scorer(data)
        @test scorer.experiment_id == "1"
        @test scorer.name == "test-scorer"
        @test scorer.version == 1
        @test scorer.scorer_id == "scorer-abc"
        @test scorer.serialized_scorer == "{}"
        @test scorer.creation_time == 1700000000000
    end

    @testset "Scorer defaults" begin
        scorer = Scorer(Dict{String,Any}())
        @test scorer.experiment_id == ""
        @test scorer.name == ""
        @test scorer.version == 0
        @test scorer.scorer_id == ""
        @test scorer.serialized_scorer == ""
        @test scorer.creation_time == 0
    end

    @testset "Scorer with integer experiment_id" begin
        data = fixture_scorer(experiment_id=42)
        scorer = Scorer(data)
        @test scorer.experiment_id == "42"
    end

    @testset "Scorer direct constructor" begin
        scorer = Scorer("1", "my-scorer", 2, "sid-1", "{\"type\":\"test\"}", 1700000000000)
        @test scorer.experiment_id == "1"
        @test scorer.name == "my-scorer"
        @test scorer.version == 2
        @test scorer.scorer_id == "sid-1"
        @test scorer.serialized_scorer == "{\"type\":\"test\"}"
        @test scorer.creation_time == 1700000000000
    end
end
