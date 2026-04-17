@testset verbose = true "experiment types" begin
    @testset "Experiment from dict" begin
        data = fixture_experiment(
            tags=[Dict{String,Any}("key" => "env", "value" => "test")]
        )
        exp = Experiment(data)
        @test exp.experiment_id == "1"
        @test exp.name == "test-experiment"
        @test exp.artifact_location == "mlflow-artifacts:/0"
        @test exp.lifecycle_stage == "active"
        @test exp.last_update_time == 1700000000000
        @test exp.creation_time == 1700000000000
        @test length(exp.tags) == 1
        @test exp.tags[1].key == "env"
        @test exp.tags[1].value == "test"
    end

    @testset "Experiment with empty tags" begin
        data = fixture_experiment()
        exp = Experiment(data)
        @test isempty(exp.tags)
    end

    @testset "Experiment show" begin
        data = fixture_experiment()
        exp = Experiment(data)
        io = IOBuffer()
        show(io, exp)
        @test !isempty(String(take!(io)))
    end

    @testset "ExperimentPermission from dict" begin
        data = Dict{String,Any}(
            "experiment_id" => "1",
            "user_id" => 42,
            "permission" => "READ"
        )
        perm = ExperimentPermission(data)
        @test perm.experiment_id == "1"
        @test perm.user_id == "42"
        @test perm.permission == Permission.READ
    end

    @testset "ExperimentPermission show" begin
        data = Dict{String,Any}("experiment_id" => "1", "user_id" => 1, "permission" => "EDIT")
        perm = ExperimentPermission(data)
        io = IOBuffer()
        show(io, perm)
        @test !isempty(String(take!(io)))
    end
end
