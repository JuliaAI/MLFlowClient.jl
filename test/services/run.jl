@testset verbose = true "create run" begin
    @ensuremlf
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "base" begin
        run = createrun(mlf, experiment_id)

        @test run.info isa RunInfo
        @test run.data isa RunData
        @test run.inputs isa RunInputs
        @test run.info.experiment_id == experiment_id
    end

    @testset "with experiment id as string" begin
        run = createrun(mlf, experiment_id)

        @test run.info.experiment_id == experiment_id
    end

    @testset "with experiment id as integer" begin
        run = createrun(mlf, parse(Int, experiment_id))

        @test run.info.experiment_id == experiment_id
    end

    @testset "with experiment" begin
        experiment = getexperiment(mlf, experiment_id)
        run = createrun(mlf, experiment)

        @test run.info.experiment_id == experiment_id
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "delete run" begin
    @ensuremlf
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment_id)

    @testset "using string id" begin
        @test deleterun(mlf, run.info.run_id)
        restorerun(mlf, run.info.run_id)
    end

    @testset "using Run" begin
        @test deleterun(mlf, run)
        restorerun(mlf, run.info.run_id)
    end

    @testset "delete already deleted" begin
        deleterun(mlf, run.info.run_id)
        @test deleterun(mlf, run.info.run_id)
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "restore run" begin
    @ensuremlf
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment_id)

    @testset "using string id" begin
        deleterun(mlf, run.info.run_id)
        @test restorerun(mlf, run.info.run_id)
    end

    @testset "using Run" begin
        deleterun(mlf, run)
        @test restorerun(mlf, run)
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "get run" begin
    @ensuremlf
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment_id)

    @testset "using id" begin
        retrieved_run = getrun(mlf, run.info.run_id)

        @test retrieved_run.info isa RunInfo
        @test retrieved_run.data isa RunData
        @test retrieved_run.inputs isa RunInputs
        @test retrieved_run.info.experiment_id == experiment_id
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "set run tag" begin
    @ensuremlf
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "set tag with run string id" begin
        run = createrun(mlf, experiment_id)
        setruntag(mlf, run.info.run_id, "tag", "value")

        run = refresh(mlf, run)

        @test run.data.tags |> !isempty
        @test (run.data.tags |> first).key == "tag"
        @test (run.data.tags |> first).value == "value"

        deleterun(mlf, run)
    end

    @testset "set tag with run" begin
        run = createrun(mlf, experiment_id)
        setruntag(mlf, run, "tag", "value")

        run = refresh(mlf, run)

        @test run.data.tags |> !isempty
        @test (run.data.tags |> first).key == "tag"
        @test (run.data.tags |> first).value == "value"

        deleterun(mlf, run)
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "delete run tag" begin
    @ensuremlf
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "delete tag with run string id" begin
        run = createrun(mlf, experiment_id)
        setruntag(mlf, run.info.run_id, "tag", "value")
        deleteruntag(mlf, run.info.run_id, "tag")

        run = refresh(mlf, run)

        @test (run.data.tags |> length) == 1 # The default tag
        deleterun(mlf, run)
    end

    @testset "delete tag with run string id" begin
        run = createrun(mlf, experiment_id)
        setruntag(mlf, run, "tag", "value")
        deleteruntag(mlf, run, "tag")

        run = refresh(mlf, run)

        @test (run.data.tags |> length) == 1 # The default tag
        deleterun(mlf, run)
    end
    deleteexperiment(mlf, experiment_id)
end
