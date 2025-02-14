@testset verbose = true "create registered model" begin
    @ensuremlf

    @testset "base" begin
        registered_model = createregisteredmodel(mlf, "missy"; description="gala")

        @test registered_model isa RegisteredModel
        @test registered_model.name == "missy"
        @test registered_model.description == "gala"
    end

    @testset "name exists" begin
        registered_model = getregisteredmodel(mlf, "missy")
        @test_throws ErrorException createregisteredmodel(mlf, registered_model.name)
        deleteregisteredmodel(mlf, "missy")
    end

    @testset "with tags as array of tags" begin
        createregisteredmodel(mlf, "missy"; tags=[Tag("test_key", "test_value")])
        deleteregisteredmodel(mlf, "missy")
    end

    @testset "with tags as array of pairs" begin
        createregisteredmodel(mlf, "missy"; tags=["test_key" => "test_value"])
        deleteregisteredmodel(mlf, "missy")
    end

    @testset "with tags as array of dicts" begin
        createregisteredmodel(mlf, "missy";
            tags=[Dict("key" => "test_key", "value" => "test_value")])
        deleteregisteredmodel(mlf, "missy")
    end

    @testset "with tags as dict" begin
        createregisteredmodel(mlf, "missy"; tags=Dict("test_key" => "test_value"))
        deleteregisteredmodel(mlf, "missy")
    end
end

@testset verbose = true "get registered model" begin
    @ensuremlf

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    retrieved_registered_model = getregisteredmodel(mlf, registered_model.name)

    @test retrieved_registered_model isa RegisteredModel
    @test retrieved_registered_model.name == registered_model.name
    @test retrieved_registered_model.description == registered_model.description

    deleteregisteredmodel(mlf, "missy")
end

@testset verbose = true "rename registered model" begin
    @ensuremlf

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    renamed_registered_model = renameregisteredmodel(mlf, registered_model.name, "gala")

    @test renamed_registered_model isa RegisteredModel
    @test renamed_registered_model.name == "gala"
    @test renamed_registered_model.description == registered_model.description

    deleteregisteredmodel(mlf, "gala")
end

@testset verbose = true "update registered model" begin
    @ensuremlf

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    updated_registered_model = updateregisteredmodel(mlf, registered_model.name;
        description="ana")

    @test updated_registered_model isa RegisteredModel
    @test updated_registered_model.name == registered_model.name
    @test updated_registered_model.description == "ana"

    deleteregisteredmodel(mlf, "missy")
end

@testset verbose = true "delete registered model" begin
    @ensuremlf

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    deleteregisteredmodel(mlf, "missy")

    @test_throws ErrorException getregisteredmodel(mlf, "missy")
end

@testset verbose = true "search registered models" begin
    @ensuremlf

    createregisteredmodel(mlf, "missy"; description="gala")
    createregisteredmodel(mlf, "gala"; description="missy")

    @testset "default search" begin
        registered_models, next_page_token = searchregisteredmodels(mlf)

        @test length(registered_models) == 2 # four because of the default experiment
        @test next_page_token |> isnothing
    end

    @testset "with pagination" begin
        registered_models, next_page_token = searchregisteredmodels(mlf; max_results=1)

        @test length(registered_models) == 1
        @test next_page_token |> !isnothing
        @test next_page_token isa String
    end

    deleteregisteredmodel(mlf, "missy")
    deleteregisteredmodel(mlf, "gala")
end

@testset verbose = true "set registered model tag" begin
    @ensuremlf

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    setregisteredmodeltag(mlf, registered_model.name, "test_key", "test_value")

    retrieved_registered_model = getregisteredmodel(mlf, registered_model.name)
    @test retrieved_registered_model.tags |> !isempty
    @test (retrieved_registered_model.tags |> first).key == "test_key"
    @test (retrieved_registered_model.tags |> first).value == "test_value"

    deleteregisteredmodel(mlf, "missy")
end

@testset verbose = true "delete registered model tag" begin
    @ensuremlf

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    setregisteredmodeltag(mlf, registered_model.name, "test_key", "test_value")
    deleteregisteredmodeltag(mlf, registered_model.name, "test_key")

    retrieved_registered_model = getregisteredmodel(mlf, registered_model.name)
    @test retrieved_registered_model.tags |> isempty

    deleteregisteredmodel(mlf, "missy")
end

@testset verbose = true "delete registered model alias" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    model_version = createmodelversion(mlf, "missy", run.info.artifact_uri)

    setregisteredmodelalias(mlf, registered_model.name, "gala", model_version.version)
    deleteregisteredmodelalias(mlf, registered_model.name, "gala")

    retrieved_registered_model = getregisteredmodel(mlf, registered_model.name)
    @test retrieved_registered_model.aliases |> isempty

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "delete registered model alias" begin
    @ensuremlf

    experiment = createexperiment(mlf, UUIDs.uuid4() |> string)
    run = createrun(mlf, experiment)

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    model_version = createmodelversion(mlf, "missy", run.info.artifact_uri)

    setregisteredmodelalias(mlf, registered_model.name, "gala", model_version.version)
    setregisteredmodelalias(mlf, registered_model.name, "missy", model_version.version)

    retrieved_registered_model = getregisteredmodel(mlf, registered_model.name)
    @test retrieved_registered_model.aliases |> !isempty
    @test length(retrieved_registered_model.aliases) == 2

    deleteregisteredmodel(mlf, "missy")
    deleteexperiment(mlf, experiment)
end

@testset verbose = true "create registered model permission" begin
    @ensuremlf

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    user = createuser(mlf, "missy", "gala")
    permission = createregisteredmodelpermission(mlf, registered_model.name, user.username, Permission("READ"))

    @test permission isa RegisteredModelPermission
    @test permission.name == registered_model.name
    @test permission.user_id == user.id
    @test permission.permission == Permission("READ")

    deleteregisteredmodelpermission(mlf, registered_model.name, user.username)
    deleteuser(mlf, user.username)
    deleteregisteredmodel(mlf, "missy")
end

@testset verbose = true "get registered model permission" begin
    @ensuremlf

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    user = createuser(mlf, "missy", "gala")
    permission = createregisteredmodelpermission(mlf, registered_model.name, user.username, Permission("READ"))
    retrieved_permission = getregisteredmodelpermission(mlf, registered_model.name, user.username)

    @test retrieved_permission isa RegisteredModelPermission
    @test retrieved_permission.name == registered_model.name
    @test retrieved_permission.user_id == user.id
    @test retrieved_permission.permission == Permission("READ")

    deleteregisteredmodelpermission(mlf, registered_model.name, user.username)
    deleteuser(mlf, user.username)
    deleteregisteredmodel(mlf, "missy")
end

@testset verbose = true "update registered model permission" begin
    @ensuremlf

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    user = createuser(mlf, "missy", "gala")
    permission = createregisteredmodelpermission(mlf, registered_model.name, user.username, Permission("READ"))
    updateregisteredmodelpermission(mlf, registered_model.name, user.username, Permission("MANAGE"))
    retrieved_permission = getregisteredmodelpermission(mlf, registered_model.name, user.username)

    @test retrieved_permission isa RegisteredModelPermission
    @test retrieved_permission.name == registered_model.name
    @test retrieved_permission.user_id == user.id
    @test retrieved_permission.permission == Permission("MANAGE")

    deleteregisteredmodelpermission(mlf, registered_model.name, user.username)
    deleteuser(mlf, user.username)
    deleteregisteredmodel(mlf, "missy")
end
#
@testset verbose = true "delete registered model permission" begin
    @ensuremlf

    registered_model = createregisteredmodel(mlf, "missy"; description="gala")
    user = createuser(mlf, "missy", "gala")
    permission = createregisteredmodelpermission(mlf, registered_model.name, user.username, Permission("READ"))
    deleteregisteredmodelpermission(mlf, registered_model.name, user.username)

    @test_throws ErrorException getregisteredmodelpermission(mlf, registered_model.name, user.username)
    deleteuser(mlf, user.username)
    deleteregisteredmodel(mlf, "missy")
end
