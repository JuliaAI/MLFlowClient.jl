@testset verbose = true "create experiment" begin
    @ensuremlf

    @testset "base" begin
        experiment_id = createexperiment(mlf)
        @test isa(experiment_id, String)
        deleteexperiment(mlf, experiment_id)
    end

    @testset "name exists" begin
        experiment_id = createexperiment(mlf)
        @test_throws ErrorException createexperiment(mlf; name=exp.name)
        deleteexperiment(mlf, experiment_id)
    end

    @testset "with tags as array of tags" begin
        experiment_id = createexperiment(mlf;
            tags=[Tag("test_key", "test_value")])
        deleteexperiment(mlf, experiment_id)
    end

    @testset "with tags as array of pairs" begin
        experiment_id = createexperiment(mlf;
            tags=["test_key" => "test_value"])
        deleteexperiment(mlf, experiment_id)
    end

    @testset "with tags as array of dicts" begin
        experiment_id = createexperiment(mlf;
            tags=[Dict("key" => "test_key", "value" => "test_value")])
        deleteexperiment(mlf, experiment_id)
    end

    @testset "with tags as dict" begin
        experiment_id = createexperiment(mlf;
            tags=Dict("test_key" => "test_value"))
        deleteexperiment(mlf, experiment_id)
    end
end

@testset verbose = true "get experiment" begin
    @ensuremlf
    experiment_name = "test_name"
    artifact_location="test_location"
    tags = [Tag("test_key", "test_value")]
    experiment_id = createexperiment(mlf; name=experiment_name,
        artifact_location=artifact_location, tags=tags)

    @testset "using string id" begin
        experiment = getexperiment(mlf, experiment_id)
        @test isa(experiment, Experiment)
        @test experiment.experiment_id == experiment_id
        @test experiment.name == experiment_name
        @test occursin(artifact_location, experiment.artifact_location)
        @test (experiment.tags |> first).key == (tags |> first).key
        @test (experiment.tags |> first).value == (tags |> first).value
    end

    @testset "using integer id" begin
        experiment = getexperiment(mlf, parse(Int, experiment_id))
        @test isa(experiment, Experiment)
    end

    @testset "using name" begin
        experiment = getexperimentbyname(mlf, experiment_name)
        @test isa(experiment, Experiment)
    end

    @testset "not found" begin
        @test isa(getexperiment(mlf, 123), Missing)
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "delete experiment" begin
    @ensuremlf
    experiment_id = createexperiment(mlf)

    @testset "using string id" begin
        @test deleteexperiment(mlf, experiment_id)
        restoreexperiment(mlf, experiment_id)
    end

    @testset "using integer id" begin
        @test deleteexperiment(mlf, parse(Int, experiment_id))
        restoreexperiment(mlf, experiment_id)
    end

    @testset "using Experiment" begin
        experiment = getexperiment(mlf, experiment_id)
        @test deleteexperiment(mlf, experiment)
        restoreexperiment(mlf, experiment_id)
    end

    @testset "delete already deleted" begin
        deleteexperiment(mlf, experiment_id)
        @test deleteexperiment(mlf, experiment_id)
    end
end

@testset verbose = true "restore experiment" begin
    @ensuremlf
    experiment_id = createexperiment(mlf)

    @testset "using string id" begin
        deleteexperiment(mlf, experiment_id)
        @test restoreexperiment(mlf, experiment_id)
    end

    @testset "using integer id" begin
        deleteexperiment(mlf, experiment_id)
        @test restoreexperiment(mlf, parse(Int, experiment_id))
    end

    @testset "using Experiment" begin
        experiment = getexperiment(mlf, experiment_id)
        deleteexperiment(mlf, experiment_id)
        @test restoreexperiment(mlf, experiment)
    end
end

@testset verbose = true "update experiment" begin
    @ensuremlf
    experiment_name = "test_name"
    experiment_id = createexperiment(mlf; name=experiment_name)

    @testset "update name with string id" begin
        new_name = "new_name_str"
        updateexperiment(mlf, experiment_id, new_name)
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.name == new_name
    end

    @testset "update name with integer id" begin
        new_name = "new_name_int"
        updateexperiment(mlf, parse(Int, experiment_id), new_name)
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.name == new_name
    end

    @testset "update name with Experiment" begin
        new_name = "new_name_exp"
        experiment = getexperiment(mlf, experiment_id)
        updateexperiment(mlf, experiment, new_name)
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.name == new_name
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "search experiments" begin
    @ensuremlf

    experiment_ids = [
        createexperiment(mlf; name="missy"),
        createexperiment(mlf; name="gala"),
        createexperiment(mlf; name="bizcochito")]

    @testset "default search" begin
        experiments = searchexperiments(mlf)
        @test length(experiments) == 4 # four because of the default experiment
    end

    experiment_ids .|> (id -> deleteexperiment(mlf, id))
end
