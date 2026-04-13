@testset verbose = true "scorer service" begin
    @ensuremlf
    mlf === nothing && return nothing

    # Create an experiment for scorer tests
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    scorer_name = UUIDs.uuid4() |> string
    serialized_scorer = """{"type": "test_scorer", "config": {"threshold": 0.5}}"""

    @testset "register scorer" begin
        result = registerscorer(mlf, experiment_id, scorer_name, serialized_scorer)

        @test result isa Dict
        @test haskey(result, "scorer_id")
        @test haskey(result, "version")
        @test haskey(result, "experiment_id")
        @test haskey(result, "name")
        @test haskey(result, "serialized_scorer")
        @test haskey(result, "creation_time")
        @test result["experiment_id"] == experiment_id
        @test result["name"] == scorer_name
    end

    @testset "list scorers" begin
        # Register another scorer
        registerscorer(mlf, experiment_id, "$(scorer_name)_v2", serialized_scorer)

        scorers = listscorers(mlf, experiment_id)

        @test scorers isa Array{Scorer}
        @test length(scorers) >= 1

        # Verify scorer structure
        if length(scorers) > 0
            scorer = scorers[1]
            @test scorer isa Scorer
            @test scorer.experiment_id == experiment_id
            @test scorer.name isa String
            @test scorer.version isa Int64
            @test scorer.scorer_id isa String
            @test scorer.serialized_scorer isa String
            @test scorer.creation_time isa Int64
        end
    end

    @testset "list scorer versions" begin
        scorer_name_for_versions = UUIDs.uuid4() |> string

        # Register multiple versions
        registerscorer(mlf, experiment_id, scorer_name_for_versions, serialized_scorer)
        registerscorer(mlf, experiment_id, scorer_name_for_versions, serialized_scorer)

        versions = listscorerversions(mlf, experiment_id, scorer_name_for_versions)

        @test versions isa Array{Scorer}
        @test length(versions) >= 1
        if length(versions) > 0
            @test all(v -> v.experiment_id == experiment_id, versions)
        end
    end

    @testset "get scorer" begin
        # Register a scorer
        registerscorer(mlf, experiment_id, "$(scorer_name)_get", serialized_scorer)

        scorer = getscorer(mlf, experiment_id, "$(scorer_name)_get")

        @test scorer isa Scorer
        @test scorer.experiment_id == experiment_id || scorer.experiment_id == ""
    end

    @testset "get scorer with version" begin
        scorer_name_with_version = UUIDs.uuid4() |> string
        registerscorer(mlf, experiment_id, scorer_name_with_version, serialized_scorer)
        registerscorer(mlf, experiment_id, scorer_name_with_version, serialized_scorer)

        # Get latest version (no version specified)
        scorer = getscorer(mlf, experiment_id, scorer_name_with_version)
        @test scorer isa Scorer
        @test scorer.experiment_id == experiment_id || scorer.experiment_id == ""
    end

    @testset "delete scorer" begin
        scorer_to_delete = UUIDs.uuid4() |> string
        registerscorer(mlf, experiment_id, scorer_to_delete, serialized_scorer)

        @test deletescorer(mlf, experiment_id, scorer_to_delete)

        # Verify deletion - should get error when trying to list (or scorer not in list)
        scorers = listscorers(mlf, experiment_id)
        @test !any(s -> s.name == scorer_to_delete, scorers)
    end

    @testset "delete scorer with version" begin
        scorer_versioned = UUIDs.uuid4() |> string
        result1 = registerscorer(mlf, experiment_id, scorer_versioned, serialized_scorer)
        result2 = registerscorer(mlf, experiment_id, scorer_versioned, serialized_scorer)

        # Delete specific version
        version_to_delete = result1["version"]
        @test deletescorer(mlf, experiment_id, scorer_versioned; version=version_to_delete)
    end

    # Cleanup
    deleteexperiment(mlf, experiment_id)
end
