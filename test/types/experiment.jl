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
        @test exp.effective_trace_archival_retention == ""
        @test exp.workspace == ""
    end

    @testset "Experiment with workspace" begin
        data = fixture_experiment(workspace="my-workspace")
        exp = Experiment(data)
        @test exp.workspace == "my-workspace"
    end

    @testset "Experiment with empty tags" begin
        data = fixture_experiment()
        exp = Experiment(data)
        @test isempty(exp.tags)
    end

    @testset "Experiment with effective_trace_archival_retention" begin
        data = fixture_experiment()
        data["effective_trace_archival_retention"] = "30d"
        exp = Experiment(data)
        @test exp.effective_trace_archival_retention == "30d"
    end

    @testset "Experiment show" begin
        data = fixture_experiment()
        exp = Experiment(data)
        io = IOBuffer()
        show(io, exp)
        @test !isempty(String(take!(io)))
    end
end
