using MLFlowClient
using Test
using UUIDs

function mlflow_server_is_running(mlf::MLFlow)
    try
        @info "Querying mlflow server at $mlf"
        response = MLFlowClient.mlfget(mlf, "experiments/list")
        return isa(response, Dict)
    catch e
        return false
    end
end

@testset "MLFlowClient.jl" begin
    mlflowbaseuri = "http://localhost:5000"
    mlf = MLFlow(mlflowbaseuri)
    @test mlf.baseuri == mlflowbaseuri
    @test mlf.apiversion == 2.0

    if mlflow_server_is_running(mlf)

        exptags = [:key => "val"]
        expname = "expname-$(UUIDs.uuid4())"

        @test ismissing(getexperiment(mlf, "$(UUIDs.uuid4()) - $(UUIDs.uuid4())"))

        experiment_id = createexperiment(mlf; name=expname, tags=exptags)
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.experiment_id == experiment_id
        experimentbyname = getexperiment(mlf, expname)
        @test experimentbyname.name == experiment.name


        exprun = createrun(mlf, experiment_id)
        @test exprun.info.experiment_id == experiment_id
        @test exprun.info.lifecycle_stage == "active"
        @test exprun.info.status == MLFlowRunStatus("RUNNING")
        exprunid = exprun.info.run_id

        logparam(mlf, exprunid, "paramkey", "paramval")
        logparam(mlf, exprunid, Dict("k" => "v", "k1" => "v1"))
        logparam(mlf, exprun, Dict("test1" => "test2"))

        logmetric(mlf, exprun, "metrickeyrun", 1.0)
        logmetric(mlf, exprun.info, "metrickeyrun", 2.0)
        logmetric(mlf, exprun.info, "metrickeyrun", [2.5, 3.5])
        logmetric(mlf, exprunid, "metrickey", 1.0)
        logmetric(mlf, exprunid, "metrickey2", [1.0, 1.5, 2.0])

        retrieved_run = getrun(mlf, exprunid)
        @test exprun.info == retrieved_run.info

        tmpfiletoupload = tempname()
        f = open(tmpfiletoupload, "w")
        write(f, "samplecontents")
        close(f)
        logartifact(mlf, retrieved_run, tmpfiletoupload)
        rm(tmpfiletoupload)

        running_run = updaterun(mlf, exprunid, "RUNNING")
        @test running_run.info.experiment_id == experiment_id
        @test running_run.info.status == MLFlowRunStatus("RUNNING")
        finished_run = updaterun(mlf, exprun, MLFlowRunStatus("FINISHED")) 
        finishedrun = getrun(mlf, finished_run.info.run_id)
    
        # NOTE: seems like MLFlow API never returns `end_time` as documented in https://mlflow.org/docs/latest/rest-api.html#runinfo
        # Consider raising an issue with MLFlow itself.
        @test_broken !ismissing(finishedrun.info.end_time)

        deleterun(mlf, exprunid)

        deleteexperiment(mlf, experiment_id)
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.experiment_id == experiment_id
        @test experiment.lifecycle_stage == "deleted"
    end
end
