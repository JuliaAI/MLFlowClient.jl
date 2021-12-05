using MLFlowClient
using Test
using UUIDs
using Dates

function mlflow_server_is_running(mlf::MLFlow)
    try
        response = MLFlowClient.mlfget(mlf, "experiments/list")
        return isa(response, Dict)
    catch e
        return false
    end
end

# creates an instance of mlf
# skips test if mlflow is not available on default location, http://localhost:5000
macro ensuremlf()
    e = quote
        mlf = MLFlow()
        mlflow_server_is_running(mlf) || return nothing
    end
    eval(e)
end

@testset "MLFlow" begin
    mlf = MLFlow()
    @test mlf.baseuri == "http://localhost:5000"
    @test mlf.apiversion == 2.0
    mlf = MLFlow("https://localhost:5001", apiversion=3.0)
    @test mlf.baseuri == "https://localhost:5001"
    @test mlf.apiversion == 3.0
end

@testset "createexperiment" begin
    @ensuremlf
    exp = createexperiment(mlf)
    @test isa(exp, MLFlowExperiment)
    @test deleteexperiment(mlf, exp)
    experiment = getexperiment(mlf, exp.experiment_id)
    @test experiment.experiment_id == exp.experiment_id
    @test experiment.lifecycle_stage == "deleted"
end

@testset "createrun" begin
    @ensuremlf
    expname = "getorcreate-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    r = createrun(mlf, e.experiment_id)
    @test isa(r, MLFlowRun)
    @test deleterun(mlf, r)
    rr = createrun(mlf, e)
    @test isa(rr, MLFlowRun)
    @test deleterun(mlf, rr)
    @test deleteexperiment(mlf, e)
end

@testset "getorcreateexperiment" begin
    @ensuremlf
    expname = "getorcreate"
    e = getorcreateexperiment(mlf, expname)
    @test isa(e, MLFlowExperiment)
    ee = getorcreateexperiment(mlf, expname)
    @test isa(ee, MLFlowExperiment)
    @test e === ee
    @test deleteexperiment(mlf, ee)
    @test deleteexperiment(mlf, ee)
end

@testset "generatefilterfromparama" begin
    filter_params = Dict("k1" => "v1")
    filter = generatefilterfromparams(filter_params)
    @test filter == "param.\"k1\" = \"v1\""
    filter_params = Dict("k1" => "v1", "started" => Date("2020-01-01"))
    filter = generatefilterfromparams(filter_params)
    @test occursin("param.\"k1\" = \"v1\"", filter)
    @test occursin("param.\"started\" = \"2020-01-01\"", filter)
    @test occursin(" and ", filter)
end

@testset "searchruns" begin
    @ensuremlf
    exp = createexperiment(mlf)
    expid = exp.experiment_id
    exprun = createrun(mlf, exp)
    @test exprun.info.experiment_id == expid
    @test exprun.info.lifecycle_stage == "active"
    @test exprun.info.status == MLFlowRunStatus("RUNNING")
    exprunid = exprun.info.run_id

    runparams = Dict(
        "k1" => "v1",
        "started" => Date("2020-01-01")
    )
    logparam(mlf, exprun, runparams)

    findrun = searchruns(mlf, exp; filter_params=runparams)
    @test length(findrun) == 1
    r = only(findrun)
    @test get_run_id(get_info(r)) == exprun.info.run_id
    @test get_run_id(r) == get_run_id(get_info(r))
    @test sort(collect(keys(get_params(get_data(r))))) == sort(string.(keys(runparams)))
    @test sort(collect(values(get_params(get_data(r))))) == sort(string.(values(runparams)))

    @test deleteexperiment(mlf, exp)
end

@testset "artifacts" begin
    @ensuremlf
    exp = createexperiment(mlf)
    @test isa(exp, MLFlowExperiment)
    exprun = createrun(mlf, exp)
    @test isa(exprun, MLFlowRun)
    # only run the below if artifact_uri is a local directory
    # i.e. when running mlflow server as a separate process next to the testset
    # when running mlflow in a container, the below tests will be skipped
    # this is what happens in github actions - mlflow runs in a container, the artifact_uri is not immediately available, and tests are skipped
    artifact_uri = exprun.info.artifact_uri
    if isdir(artifact_uri)
        @test_throws SystemError logartifact(mlf, exprun, "/etc/shadow")

        tmpfiletoupload = "sometempfilename.txt"
        f = open(tmpfiletoupload, "w")
        write(f, "samplecontents")
        close(f)
        artifactpath = logartifact(mlf, exprun, tmpfiletoupload)
        @test isfile(artifactpath)
        rm(tmpfiletoupload)
        artifactpath = logartifact(mlf, exprun, "randbytes.bin", b"some rand bytes here")
        @test isfile(artifactpath)

        mkdir(joinpath(artifact_uri, "newdir"))
        artifactpath = logartifact(mlf, exprun, joinpath("newdir", "randbytesindir.bin"), b"bytes here")
        artifactpath = logartifact(mlf, exprun, joinpath("newdir", "randbytesindir2.bin"), b"bytes here")
        mkdir(joinpath(artifact_uri, "newdir", "new2"))
        artifactpath = logartifact(mlf, exprun, joinpath("newdir", "new2", "randbytesindir.bin"), b"bytes here")
        artifactpath = logartifact(mlf, exprun, joinpath("newdir", "new2", "randbytesindir2.bin"), b"bytes here")
        mkdir(joinpath(artifact_uri, "newdir", "new2", "new3"))
        artifactpath = logartifact(mlf, exprun, joinpath("newdir", "new2", "new3", "randbytesindir.bin"), b"bytes here")
        artifactpath = logartifact(mlf, exprun, joinpath("newdir", "new2", "new3", "randbytesindir2.bin"), b"bytes here")
        mkdir(joinpath(artifact_uri, "newdir", "new2", "new3", "new4"))
        artifactpath = logartifact(mlf, exprun, joinpath("newdir", "new2", "new3", "new4", "randbytesindir.bin"), b"bytes here")
        artifactpath = logartifact(mlf, exprun, joinpath("newdir", "new2", "new3", "new4", "randbytesindir2.bin"), b"bytes here")

        # artifact tree should now look like this:
        # 
        # ├── newdir
        # │   ├── new2
        # │   │   ├── new3
        # │   │   │   ├── new4
        # │   │   │   │   ├── randbytesindir2.bin
        # │   │   │   │   └── randbytesindir.bin
        # │   │   │   ├── randbytesindir2.bin
        # │   │   │   └── randbytesindir.bin
        # │   │   ├── randbytesindir2.bin
        # │   │   └── randbytesindir.bin
        # │   ├── randbytesindir2.bin
        # │   └── randbytesindir.bin
        # ├── randbytes.bin
        # └── sometempfilename.txt

        # 4 directories, 10 files

        artifactlist = listartifacts(mlf, exprun)
        @test sort(basename.(get_path.(artifactlist))) == ["newdir", "randbytes.bin", "sometempfilename.txt"]
        @test sort(get_size.(artifactlist)) == [0, 14, 20]

        ald2 = listartifacts(mlf, exprun, maxdepth=2)
        @test length(ald2) == 6
        @test sort(basename.(get_path.(ald2))) == ["new2", "newdir", "randbytes.bin", "randbytesindir.bin", "randbytesindir2.bin", "sometempfilename.txt"]
        aldrecursion = listartifacts(mlf, exprun, maxdepth=-1)
        @test length(aldrecursion) == 14 # 4 directories, 10 files
        @test sum(typeof.(aldrecursion) .== MLFlowArtifactDirInfo) == 4 # 4 directories
        @test sum(typeof.(aldrecursion) .== MLFlowArtifactFileInfo) == 10 # 10 files
    end
    deleterun(mlf, exprun)
    deleteexperiment(mlf, exp)
end

@testset "MLFlowClient.jl" begin
    @ensuremlf
    exp = createexperiment(mlf)
    @test isa(exp, MLFlowExperiment)

    exptags = [:key => "val"]
    expname = "expname-$(UUIDs.uuid4())"

    @test ismissing(getexperiment(mlf, "$(UUIDs.uuid4()) - $(UUIDs.uuid4())"))

    experiment = createexperiment(mlf; name=expname, tags=exptags)
    experiment_id = experiment.experiment_id
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

    running_run = updaterun(mlf, exprunid, "RUNNING")
    @test running_run.info.experiment_id == experiment_id
    @test running_run.info.status == MLFlowRunStatus("RUNNING")
    finished_run = updaterun(mlf, exprun, MLFlowRunStatus("FINISHED"))
    finishedrun = getrun(mlf, finished_run.info.run_id)
    
    @test !ismissing(finishedrun.info.end_time)

    exprun2 = createrun(mlf, experiment_id)
    exprun2id = exprun.info.run_id
    logparam(mlf, exprun2, "param2", "key2")
    logmetric(mlf, exprun2, "metric2", [1.0, 2.0])
    updaterun(mlf, exprun2, "FINISHED")

    runs = searchruns(mlf, experiment_id)
    @test length(runs) == 2
    runs = searchruns(mlf, experiment_id; filter="param.param2 = \"key2\"")
    @test length(runs) == 1
    @test_throws ErrorException searchruns(mlf, experiment_id; run_view_type="ERR")
    runs = searchruns(mlf, experiment_id; filter="param.param2 = \"key3\"")
    @test length(runs) == 0
    runs = searchruns(mlf, experiment_id; max_results=1) # test paging functionality
    @test length(runs) == 2
    deleterun(mlf, exprunid)
    deleterun(mlf, exprun2)

    deleteexperiment(mlf, exp)
end
