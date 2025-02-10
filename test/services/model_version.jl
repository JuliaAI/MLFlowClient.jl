@testset verbose = true "get latest model versions" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)
    createregisteredmodel(mlf, "missy")

    createmodelversion(mlf, "missy", run.info.artifact_uri)
    createmodelversion(mlf, "missy", run.info.artifact_uri)

    model_versions = getlatestmodelversions(mlf, "missy")

    @test model_versions isa Array{ModelVersion}
    @test length(model_versions) == 1
    @test (model_versions |> first).name == "missy"
    @test (model_versions |> first).source == run.info.artifact_uri

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "create model version" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)
    createregisteredmodel(mlf, "missy")

    @testset "base" begin
        model_version = createmodelversion(mlf, "missy", run.info.artifact_uri)

        @test model_version isa ModelVersion
        @test model_version.name == "missy"
        @test model_version.source == run.info.artifact_uri
    end

    @testset "with all params" begin
        model_version = createmodelversion(mlf, "missy", run.info.artifact_uri;
            run_id=run.info.run_id, tags=[Tag("test_key", "test_value")],
            run_link="run.link", description="test_description")
    end

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "get model version" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)
    createregisteredmodel(mlf, "missy")

    model_version = createmodelversion(mlf, "missy", run.info.artifact_uri)
    retrieved_model_version = getmodelversion(mlf, "missy", model_version.version)

    @test retrieved_model_version isa ModelVersion
    @test retrieved_model_version.name == model_version.name
    @test retrieved_model_version.version == model_version.version
    @test retrieved_model_version.source == model_version.source
    @test retrieved_model_version.run_id == model_version.run_id

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "update model version" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)
    createregisteredmodel(mlf, "missy")

    model_version = createmodelversion(mlf, "missy", run.info.artifact_uri)
    updated_model_version = updatemodelversion(mlf, "missy", model_version.version;
        description="test_description")

    @test updated_model_version isa ModelVersion
    @test updated_model_version.name == model_version.name
    @test updated_model_version.version == model_version.version
    @test updated_model_version.source == model_version.source
    @test updated_model_version.run_id == model_version.run_id
    @test updated_model_version.description != model_version.description
    @test updated_model_version.description == "test_description"

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "delete model version" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)
    createregisteredmodel(mlf, "missy")

    model_version = createmodelversion(mlf, "missy", run.info.artifact_uri)
    deletemodelversion(mlf, "missy", model_version.version)

    @test_throws ErrorException getmodelversion(mlf, "missy", model_version.version)

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "search model versions" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)
    createregisteredmodel(mlf, "missy")
    createregisteredmodel(mlf, "gala")

    createmodelversion(mlf, "missy", run.info.artifact_uri)
    createmodelversion(mlf, "gala", run.info.artifact_uri)

    @testset "default search" begin
        model_versions, next_page_token = searchmodelversions(mlf)

        @test length(model_versions) == 2 # four because of the default experiment
        @test next_page_token |> isnothing
    end

    @testset "with pagination" begin
        experiments, next_page_token = searchexperiments(mlf; max_results=1)

        @test length(experiments) == 1
        @test next_page_token |> !isnothing
        @test next_page_token isa String
    end

    deleteregisteredmodel(mlf, "missy")
    deleteregisteredmodel(mlf, "gala")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "get download uri for model version artifacts" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)
    createregisteredmodel(mlf, "missy")

    model_version = createmodelversion(mlf, "missy", run.info.artifact_uri)
    download_uri = getdownloaduriformodelversionartifacts(mlf, model_version.name,
        model_version.version)

    @test download_uri isa String
    @test download_uri == run.info.artifact_uri

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "transition model version stage" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)
    createregisteredmodel(mlf, "missy")

    model_version = createmodelversion(mlf, "missy", run.info.artifact_uri)
    updated_model_version = transitionmodelversionstage(mlf, model_version.name,
        model_version.version, "Production", true)

    @test updated_model_version isa ModelVersion
    @test updated_model_version.name == model_version.name
    @test updated_model_version.version == model_version.version
    @test updated_model_version.source == model_version.source
    @test updated_model_version.run_id == model_version.run_id
    @test updated_model_version.current_stage == "Production"

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "set model version tag" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)
    createregisteredmodel(mlf, "missy")

    model_version = createmodelversion(mlf, "missy", run.info.artifact_uri)
    setmodelversiontag(mlf, model_version.name, model_version.version, "test_key",
        "test_value")
    retrieved_model_version = getmodelversion(mlf, "missy", model_version.version)

    @test retrieved_model_version.tags |> length == 1
    @test (retrieved_model_version.tags |> first).key == "test_key"
    @test (retrieved_model_version.tags |> first).value == "test_value"

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "delete model version tag" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)
    createregisteredmodel(mlf, "missy")

    model_version = createmodelversion(mlf, "missy", run.info.artifact_uri)
    setmodelversiontag(mlf, model_version.name, model_version.version, "test_key",
        "test_value")
    deletemodelversiontag(mlf, model_version.name, model_version.version, "test_key")
    retrieved_model_version = getmodelversion(mlf, "missy", model_version.version)

    @test isempty(retrieved_model_version.tags)

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end
