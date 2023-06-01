@testset verbose = true "logparam" begin
    @ensuremlf
    expname = "logparam-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    runname = "run-$(UUIDs.uuid4())"
    r = createrun(mlf, e.experiment_id)

    @testset "logparam_by_run_id_and_key_value" begin
        logparam(mlf, r.info.run_id, "run_id_key_value", "test")
        retrieved_run = searchruns(mlf, e; filter_params=Dict("run_id_key_value" => "test"))
        @test length(retrieved_run) == 1
        @test retrieved_run[1].info.run_id == r.info.run_id
    end

    @testset "logparam_by_run_info_and_key_value" begin
        logparam(mlf, r.info, "run_id_key_value", "test")
        retrieved_run = searchruns(mlf, e; filter_params=Dict("run_id_key_value" => "test"))
        @test length(retrieved_run) == 1
        @test retrieved_run[1].info.run_id == r.info.run_id
    end

    @testset "logparam_by_run_and_key_value" begin
        logparam(mlf, r, "run_id_key_value", "test")
        retrieved_run = searchruns(mlf, e; filter_params=Dict("run_id_key_value" => "test"))
        @test length(retrieved_run) == 1
        @test retrieved_run[1].info.run_id == r.info.run_id
    end

    @testset "logparam_by_union_and_dict_key_value" begin
        logparam(mlf, r, Dict("run_id_key_value" => "test"))
        retrieved_run = searchruns(mlf, e; filter_params=Dict("run_id_key_value" => "test"))
        @test length(retrieved_run) == 1
        @test retrieved_run[1].info.run_id == r.info.run_id
    end

    deleteexperiment(mlf, e)
end

@testset verbose = true "logmetric" begin
    @ensuremlf
    expname = "logmetric-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    runname = "run-$(UUIDs.uuid4())"
    r = createrun(mlf, e.experiment_id)

    @testset "logmetric_by_run_id_and_key_value" begin
        logmetric(mlf, r.info.run_id, "run_id_key_value", 1)
        retrieved_run = searchruns(mlf, e)
        @test length(retrieved_run) == 1
        @test isa(retrieved_run[1].data.metrics["run_id_key_value"], MLFlowRunDataMetric)
        @test retrieved_run[1].data.metrics["run_id_key_value"].value == 1
    end

    @testset "logmetric_by_run_info_and_key_value" begin
        logmetric(mlf, r.info, "run_id_key_value", 1)
        retrieved_run = searchruns(mlf, e)
        @test length(retrieved_run) == 1
        @test isa(retrieved_run[1].data.metrics["run_id_key_value"], MLFlowRunDataMetric)
        @test retrieved_run[1].data.metrics["run_id_key_value"].value == 1
    end

    @testset "logmetric_by_run_and_key_value" begin
        logmetric(mlf, r, "run_id_key_value", 1)
        retrieved_run = searchruns(mlf, e)
        @test length(retrieved_run) == 1
        @test isa(retrieved_run[1].data.metrics["run_id_key_value"], MLFlowRunDataMetric)
        @test retrieved_run[1].data.metrics["run_id_key_value"].value == 1
    end

    @testset "logmetric_by_union_and_key_arrayvalue" begin
        logmetric(mlf, r, "run_id_key_value", [1, 2, 3])
        retrieved_run = searchruns(mlf, e)
        @test length(retrieved_run) == 1
        @test isa(retrieved_run[1].data.metrics["run_id_key_value"], MLFlowRunDataMetric)
        @test retrieved_run[1].data.metrics["run_id_key_value"].value == 3
    end

    deleteexperiment(mlf, e)
end

@testset verbose = true "logartifact" begin
    @ensuremlf
    expname = "logartifact-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname; artifact_location="/tmp/mlflow")
    runname = "run-$(UUIDs.uuid4())"
    r = createrun(mlf, e.experiment_id)
    artifact_uri = r.info.artifact_uri

    tmpfile = "/tmp/mlflowclient-tempfile.txt"
    open(tmpfile, "w") do f
        write(f, "test")
    end

    @testset "logartifact_by_run_and_filenameanddata" begin
        artifact = logartifact(mlf, r, tmpfile, "testing")
        @test isfile(artifact)
    end

    @testset "logartifact_by_run_id_and_file" begin
        artifact = logartifact(mlf, r.info.run_id, tmpfile)
        @test isfile(artifact)
    end

    @testset "logartifact_by_run_and_file" begin
        artifact = logartifact(mlf, r, tmpfile)
        @test isfile(artifact)
    end

    @testset "logartifact_by_run_info_and_file" begin
        artifact = logartifact(mlf, r.info, tmpfile)
        @test isfile(artifact)
    end

    @testset "logartifact_error" begin
        @test_broken logartifact(mlf, r, "/etc/shadow")
    end

    deleteexperiment(mlf, e)
end

@testset verbose=true "listartifacts" begin
    @ensuremlf
    expname = "listartifacts-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    runname = "run-$(UUIDs.uuid4())"
    r = createrun(mlf, e.experiment_id)

    @testset "listartifacts_by_run_id" begin
        artifacts = listartifacts(mlf, r.info.run_id)
        @test length(artifacts) == 0
    end

    @testset "listartifacts_by_run" begin
        artifacts = listartifacts(mlf, r)
        @test length(artifacts) == 0
    end

    @testset "listartifacts_by_run_info" begin
        artifacts = listartifacts(mlf, r.info)
        @test length(artifacts) == 0
    end

    deleteexperiment(mlf, e)
end
