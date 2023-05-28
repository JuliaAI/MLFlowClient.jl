@testset verbose = true "createrun" begin
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
    expname = "getrun-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    runname = "run-$(UUIDs.uuid4())"
    r = createrun(mlf, e.experiment_id; run_name=runname)

    retrieved_r = getrun(mlf, r.info.run_id)

    @test isa(retrieved_r, MLFlowRun)
    @test retrieved_r.info.run_id == r.info.run_id
    deleteexperiment(mlf, e)
end

@testset verbose = true "updaterun" begin
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

@testset verbose = true "deleterun" begin
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

@testset verbose = true "searchruns" begin
    @ensuremlf
    getexpname() = "searchruns-$(UUIDs.uuid4())"
    e1 = getorcreateexperiment(mlf, getexpname())
    e2 = getorcreateexperiment(mlf, getexpname())

    run_array1 = MLFlowRun[]
    run_array2 = MLFlowRun[]
    run_status = ["FINISHED", "FINISHED", "FAILED"]
    failed_runs = 0

    function addruns!(run_array, experiment, run_status)
        for status in run_status
            run = createrun(mlf, experiment.experiment_id)
            run = updaterun(mlf, run, status)
            if status == "FAILED"
                logparam(mlf, run, "test", "failed")
                failed_runs += 1
            else
                logparam(mlf, run, "test", "test")
            end
            push!(run_array, run)
        end
    end

    addruns!(run_array1, e1, run_status)
    addruns!(run_array2, e2, run_status)

    @testset "searchruns_by_experiment_id" begin
        runs = searchruns(mlf, e1.experiment_id)
        @test runs |> length == run_array1 |> length
    end

    @testset "searchruns_by_experiment" begin
        runs = searchruns(mlf, e1)
        @test runs |> length == run_array1 |> length
    end

    @testset "searchruns_by_experiments_array" begin
        runs = searchruns(mlf, [e1, e2])
        @test runs |> length == (run_array1 |> length) + (run_array2 |> length)
    end

    @testset "searchruns_by_filter" begin
        runs = searchruns(mlf, [e1, e2]; filter="param.test = \"failed\"")
        @test failed_runs == runs |> length
    end

    @testset "searchruns_by_filter_params" begin
        runs = searchruns(mlf, [e1, e2]; filter_params=Dict("test" => "failed"))
        @test failed_runs == runs |> length
    end

    @testset "searchruns_filter_exception" begin
        @test_throws ErrorException searchruns(mlf, [e1, e2]; filter="test", filter_params=Dict("test" => "test"))
    end

    @testset "runs_get_methods" begin
        runs = searchruns(mlf, [e1, e2]; filter_params=Dict("test" => "failed"))
        @test get_info(runs[1]) == runs[1].info
        @test get_data(runs[1]) == runs[1].data
        @test get_run_id(runs[1]) == runs[1].info.run_id
        @test get_params(runs[1]) == runs[1].data.params
    end

    deleteexperiment(mlf, e1)
    deleteexperiment(mlf, e2)
end
