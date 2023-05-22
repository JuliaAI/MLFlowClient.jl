include("test_base.jl")

@testset "MLFlow" begin
    mlf = MLFlow()
    @test mlf.baseuri == "http://localhost:5000"
    @test mlf.apiversion == 2.0
    @test mlf.headers == Dict()
    mlf = MLFlow("https://localhost:5001", apiversion=3.0)
    @test mlf.baseuri == "https://localhost:5001"
    @test mlf.apiversion == 3.0
    @test mlf.headers == Dict()
    let custom_headers=Dict("Authorization"=>"Bearer EMPTY")
        mlf = MLFlow("https://localhost:5001", apiversion=3.0,headers=custom_headers)
        @test mlf.baseuri == "https://localhost:5001"
        @test mlf.apiversion == 3.0
        @test mlf.headers == custom_headers
    end
end

# test that sensitive fields are not displayed by show()
@testset "MLFLow/show" begin
    let io=IOBuffer(),
        secret_token="SECRET"

        custom_headers=Dict("Authorization"=>"Bearer $secret_token")
        mlf = MLFlow("https://localhost:5001", apiversion=3.0,headers=custom_headers)
        @test mlf.baseuri == "https://localhost:5001"
        @test mlf.apiversion == 3.0
        @test mlf.headers == custom_headers
        show(io,mlf)
        show_output=String(take!(io))
        @test !(occursin(secret_token,show_output))
    end
end

@testset "utils" begin
    using MLFlowClient: uri, headers
    using URIs: URI
    let baseuri = "http://localhost:5001", apiversion = "2.0", endpoint = "experiments/get"
        mlf = MLFlow(baseuri; apiversion)
        apiuri = uri(mlf, endpoint)
        @test apiuri == URI("$baseuri/api/$apiversion/mlflow/$endpoint")
    end
    let baseuri = "http://localhost:5001", auth_headers = Dict("Authorization" => "Bearer 123456"),
        custom_headers = Dict("Content-Type" => "application/json")
        mlf = MLFlow(baseuri; headers=auth_headers)
        apiheaders = headers(mlf, custom_headers)
        @test apiheaders == Dict("Authorization" => "Bearer 123456", "Content-Type" => "application/json")
    end
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
    expname = "createrun-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    runname = "run-$(UUIDs.uuid4())"
    r = createrun(mlf, e.experiment_id; run_name=runname)

    @test isa(r, MLFlowRun)
    @test r.info.run_name == runname
    deleteexperiment(mlf, e)
end

@testset "deleterun" begin
    @ensuremlf
    expname = "deleterun-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    r = createrun(mlf, e.experiment_id)

    @test deleterun(mlf, r)
    deleteexperiment(mlf, e)
end

@testset "updaterun" begin
    @ensuremlf
    expname = "updaterun-$(UUIDs.uuid4())"
    e = getorcreateexperiment(mlf, expname)
    runname = "run-$(UUIDs.uuid4())"
    r = createrun(mlf, e.experiment_id; run_name=runname)

    new_runname = "new_updaterun-$(UUIDs.uuid4())"
    new_status = "FINISHED"
    r_updated = updaterun(mlf, r, new_status; run_name=new_runname)

    @test isa(r_updated, MLFlowRun)
    @test r_updated.info.run_name != r.info.run_name
    @test r_updated.info.status.status != r.info.status
    @test r_updated.info.run_name == new_runname
    @test r_updated.info.status.status == new_status
    deleteexperiment(mlf, e)
end

@testset "getorcreateexperiment" begin
    @ensuremlf
    expname = "getorcreate"
    artifact_location = "test$(expname)"
    e = getorcreateexperiment(mlf, expname; artifact_location=artifact_location)
    @test isa(e, MLFlowExperiment)
    ee = getorcreateexperiment(mlf, expname)
    @test isa(ee, MLFlowExperiment)
    @test e === ee
    @test occursin(artifact_location, e.artifact_location)
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
    @test get_params(r) == get_params(get_data(r))
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
    deleteexperiment(mlf, experiment)
end
