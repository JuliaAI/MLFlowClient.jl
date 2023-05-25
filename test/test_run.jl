@testset verbose=true "createrun" begin
    @ensuremlf
    expname = "createrun-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    runname = "run-$(UUIDs.uuid4())"

    function runtests(run)
        @test isa(run, MLFlowRun)
        @test run.info.run_name == runname
    end

    @testset "createrun_by_experiment_id" begin
    r = createrun(mlf, e.experiment_id; run_name=runname)
    runtests(r)
    end

    @testset "createrun_by_experiment_type" begin
    r = createrun(mlf, e; run_name=runname)
    runtests(r)
    end

    deleteexperiment(mlf, e)
end

@testset "getrun" begin
    @ensuremlf
    expname = "createrun-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    runname = "run-$(UUIDs.uuid4())"
    r = createrun(mlf, e.experiment_id; run_name=runname)

    retrieved_r = getrun(mlf, r.info.run_id)

    @test isa(retrieved_r, MLFlowRun)
    @test retrieved_r.info.run_id == r.info.run_id
end

@testset verbose=true "updaterun" begin
    @ensuremlf
    expname = "updaterun-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    runname = "run-$(UUIDs.uuid4())"
    r = createrun(mlf, e.experiment_id; run_name=runname)

    new_runname = "new_updaterun-$(UUIDs.uuid4())"
    new_status = "FINISHED"
    new_status_using_type = MLFlowRunStatus("FINISHED")

    function runtests(run_updated)
        @test isa(run_updated, MLFlowRun)
        @test run_updated.info.run_name != r.info.run_name
        @test run_updated.info.status.status != r.info.status
        @test run_updated.info.run_name == new_runname
        @test run_updated.info.status.status == new_status
    end

    @testset "updaterun_by_run_id" begin
        r_updated = updaterun(mlf, r.info.run_id, new_status; run_name=new_runname)
        runtests(r_updated)
    end
    @testset "updaterun_by_run_info" begin
        r_updated = updaterun(mlf, r.info, new_status; run_name=new_runname)
        runtests(r_updated)
    end
    @testset "updaterun_byrun" begin
        r_updated = updaterun(mlf, r, new_status; run_name=new_runname)
        runtests(r_updated)
    end
    
    @testset "updaterun_by_run_info_and_defined_status" begin
        r_updated = updaterun(mlf, r.info, new_status_using_type; run_name=new_runname)
        runtests(r_updated)
    end
    @testset "updaterun_by_run_and_defined_status" begin
        r_updated = updaterun(mlf, r, new_status_using_type; run_name=new_runname)
        runtests(r_updated)
    end

    deleteexperiment(mlf, e)
end

@testset verbose=true "deleterun" begin
    @ensuremlf
    expname = "deleterun-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)

    function runtests(run)
        @test deleterun(mlf, run)
    end

    @testset "deleterun_by_run_info" begin
        r = createrun(mlf, e.experiment_id)
        runtests(r.info)
    end

    @testset "deleterun_by_run" begin
        r = createrun(mlf, e.experiment_id)
        runtests(r)
    end

    deleteexperiment(mlf, e)
end
