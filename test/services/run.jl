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
        last_tag = run.data.tags[
            findall(x -> !occursin("mlflow.runName", x.key), run.data.tags)[1]]
        @test last_tag.key == "tag"
        @test last_tag.value == "value"

        deleterun(mlf, run)
    end

    @testset "set tag with run" begin
        run = createrun(mlf, experiment_id)
        setruntag(mlf, run, "tag", "value")

        run = refresh(mlf, run)

        @test run.data.tags |> !isempty
        last_tag = run.data.tags[
            findall(x -> !occursin("mlflow.runName", x.key), run.data.tags)[1]]
        @test last_tag.key == "tag"
        @test last_tag.value == "value"

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

@testset verbose = true "search runs" begin
    @ensuremlf

    experiment_ids = [
        createexperiment(mlf, UUIDs.uuid4() |> string),
        createexperiment(mlf, UUIDs.uuid4() |> string),
    ]
    for experiment_id in experiment_ids
        createrun(mlf, experiment_id)
    end

    @testset "default search" begin
        runs, next_page_token = searchruns(mlf; experiment_ids=experiment_ids)

        @test length(runs) == 2
        @test next_page_token |> isnothing
    end

    @testset "with pagination" begin
        runs, next_page_token = searchruns(mlf; experiment_ids=experiment_ids,
            max_results=1)

        @test length(runs) == 1
        @test next_page_token |> !isnothing
        @test next_page_token isa String
    end

    experiment_ids .|> (id -> deleteexperiment(mlf, id))
end

@testset verbose = true "update run" begin
    @ensuremlf
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment_id)

    @testset "update with string id" begin
        status = MLFlowClient.FINISHED
        end_time = 123
        run_name = "missy"

        run_info = updaterun(mlf, run.info.run_id; status=status, end_time=end_time, run_name=run_name)

        @test run_info.status == status
        @test run_info.end_time == end_time
        @test run_info.run_name == run_name
    end

    @testset "update with Run" begin
        status = MLFlowClient.FAILED
        end_time = 456
        run_name = "gala"

        run_info = updaterun(mlf, run.info.run_id; status=status, end_time=end_time, run_name=run_name)

        @test run_info.status == status
        @test run_info.end_time == end_time
        @test run_info.run_name == run_name
    end

    deleteexperiment(mlf, experiment_id)
end
