@testset "MLFlow" begin
    mlf = MLFlow()
    @test mlf.apiroot == ENV["MLFLOW_TRACKING_URI"]
    @test mlf.apiversion == 2.0
    @test mlf.headers == Dict()
    mlf = MLFlow("https://localhost:5001/api", apiversion=3.0)
    @test mlf.apiroot == "https://localhost:5001/api"
    @test mlf.apiversion == 3.0
    @test mlf.headers == Dict()
    let custom_headers = Dict("Authorization" => "Bearer EMPTY")
        mlf = MLFlow("https://localhost:5001/api", apiversion=3.0, headers=custom_headers)
        @test mlf.apiroot == "https://localhost:5001/api"
        @test mlf.apiversion == 3.0
        @test mlf.headers == custom_headers
    end
end

# test that sensitive fields are not displayed by show()
@testset "MLFLow/show" begin
    let io = IOBuffer(),
        secret_token = "SECRET"

        custom_headers = Dict("Authorization" => "Bearer $secret_token")
        mlf = MLFlow("https://localhost:5001/api", apiversion=3.0, headers=custom_headers)
        @test mlf.apiroot == "https://localhost:5001/api"
        @test mlf.apiversion == 3.0
        @test mlf.headers == custom_headers
        show(io, mlf)
        show_output = String(take!(io))
        @test !(occursin(secret_token, show_output))
    end
end

@testset "utils" begin
    using MLFlowClient: uri, headers
    using URIs: URI

    let apiroot = "http://localhost:5001/api", apiversion = 2.0, endpoint = "experiments/get"
        mlf = MLFlow(apiroot; apiversion=apiversion)
        apiuri = uri(mlf, endpoint)
        @test apiuri == URI("$apiroot/$apiversion/mlflow/$endpoint")
    end
    let apiroot = "http://localhost:5001/api", auth_headers = Dict("Authorization" => "Bearer 123456"),
        custom_headers = Dict("Content-Type" => "application/json")

        mlf = MLFlow(apiroot; headers=auth_headers)
        apiheaders = headers(mlf, custom_headers)
        @test apiheaders == Dict("Authorization" => "Bearer 123456", "Content-Type" => "application/json")
    end
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
        @test_throws ErrorException logartifact(mlf, exprun, "/etc/shadow")

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
