@testset verbose = true "create experiment" begin
    @ensuremlf

    experiment_name = UUIDs.uuid4() |> string

    @testset "base" begin
        experiment_id = createexperiment(mlf, experiment_name)
        @test isa(experiment_id, String)
    end

    @testset "name exists" begin
        experiment = getexperimentbyname(mlf, experiment_name)
        @test_throws ErrorException createexperiment(mlf, experiment.name)
        deleteexperiment(mlf, experiment.experiment_id)
    end

    @testset "with tags as array of tags" begin
        experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string;
            tags=[Tag("test_key", "test_value")])
        deleteexperiment(mlf, experiment_id)
    end

    @testset "with tags as array of pairs" begin
        experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string;
            tags=["test_key" => "test_value"])
        deleteexperiment(mlf, experiment_id)
    end

    @testset "with tags as array of dicts" begin
        experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string;
            tags=[Dict("key" => "test_key", "value" => "test_value")])
        deleteexperiment(mlf, experiment_id)
    end

    @testset "with tags as dict" begin
        experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string;
            tags=Dict("test_key" => "test_value"))
        deleteexperiment(mlf, experiment_id)
    end
end

@testset verbose = true "get experiment" begin
    @ensuremlf
    experiment_name = UUIDs.uuid4() |> string
    artifact_location = "test_location"
    tags = [Tag("test_key", "test_value")]
    experiment_id = createexperiment(mlf, experiment_name;
        artifact_location=artifact_location, tags=tags)

    @testset "using string id" begin
        experiment = getexperiment(mlf, experiment_id)
        @test isa(experiment, Experiment)
        @test experiment.experiment_id == experiment_id
        @test experiment.name == experiment_name
        @test occursin(artifact_location, experiment.artifact_location)
        @test experiment.tags |> !isempty
        @test (experiment.tags |> first).key == (tags |> first).key
        @test (experiment.tags |> first).value == (tags |> first).value
    end

    @testset "using integer id" begin
        experiment = getexperiment(mlf, parse(Int, experiment_id))
        @test isa(experiment, Experiment)
    end

    @testset "using name" begin
        experiment = getexperimentbyname(mlf, experiment_name)
        @test isa(experiment, Experiment)
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "delete experiment" begin
    @ensuremlf
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "using string id" begin
        @test deleteexperiment(mlf, experiment_id)
        restoreexperiment(mlf, experiment_id)
    end

    @testset "using integer id" begin
        @test deleteexperiment(mlf, parse(Int, experiment_id))
        restoreexperiment(mlf, experiment_id)
    end

    @testset "using Experiment" begin
        experiment = getexperiment(mlf, experiment_id)
        @test deleteexperiment(mlf, experiment)
        restoreexperiment(mlf, experiment_id)
    end

    @testset "delete already deleted" begin
        deleteexperiment(mlf, experiment_id)
        @test_throws ErrorException deleteexperiment(mlf, experiment_id)
    end
end

@testset verbose = true "restore experiment" begin
    @ensuremlf
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "using string id" begin
        deleteexperiment(mlf, experiment_id)
        @test restoreexperiment(mlf, experiment_id)
    end

    @testset "using integer id" begin
        deleteexperiment(mlf, experiment_id)
        @test restoreexperiment(mlf, parse(Int, experiment_id))
    end

    @testset "using Experiment" begin
        experiment = getexperiment(mlf, experiment_id)
        deleteexperiment(mlf, experiment_id)
        @test restoreexperiment(mlf, experiment)
    end

    @testset "restore not found" begin
        @test_throws ErrorException restoreexperiment(mlf, 123)
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "update experiment" begin
    @ensuremlf
    experiment_name = UUIDs.uuid4() |> string
    experiment_id = createexperiment(mlf, experiment_name)

    @testset "update name with string id" begin
        new_name = UUIDs.uuid4() |> string
        updateexperiment(mlf, experiment_id, new_name)
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.name == new_name
    end

    @testset "update name with integer id" begin
        new_name = UUIDs.uuid4() |> string
        updateexperiment(mlf, parse(Int, experiment_id), new_name)
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.name == new_name
    end

    @testset "update name with Experiment" begin
        new_name = UUIDs.uuid4() |> string
        experiment = getexperiment(mlf, experiment_id)
        updateexperiment(mlf, experiment, new_name)
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.name == new_name
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "search experiments" begin
    @ensuremlf

    experiment_ids = [
        createexperiment(mlf, UUIDs.uuid4() |> string),
        createexperiment(mlf, UUIDs.uuid4() |> string),
        createexperiment(mlf, UUIDs.uuid4() |> string)]

    @testset "default search" begin
        experiments, next_page_token = searchexperiments(mlf)

        @test length(experiments) == 4 # four because of the default experiment
        @test next_page_token |> isnothing
    end

    @testset "with pagination" begin
        experiments, next_page_token = searchexperiments(mlf; max_results=1)

        @test length(experiments) == 1
        @test next_page_token |> !isnothing
        @test next_page_token isa String
    end

    experiment_ids .|> (id -> deleteexperiment(mlf, id))
end

@testset verbose = true "set experiment tag" begin
    @ensuremlf

    @testset "set tag with string id" begin
        experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
        setexperimenttag(mlf, experiment_id, "test_key", "test_value")
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.tags |> !isempty
        @test (experiment.tags |> first).key == "test_key"
        @test (experiment.tags |> first).value == "test_value"
        deleteexperiment(mlf, experiment_id)
    end

    @testset "set tag with integer id" begin
        experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
        setexperimenttag(mlf, parse(Int, experiment_id), "test_key", "test_value")
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.tags |> !isempty
        @test (experiment.tags |> first).key == "test_key"
        @test (experiment.tags |> first).value == "test_value"
        deleteexperiment(mlf, experiment_id)
    end

    @testset "set tag with Experiment" begin
        experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
        experiment = getexperiment(mlf, experiment_id)
        setexperimenttag(mlf, experiment, "test_key", "test_value")
        experiment = getexperiment(mlf, experiment_id)
        @test experiment.tags |> !isempty
        @test (experiment.tags |> first).key == "test_key"
        @test (experiment.tags |> first).value == "test_value"
        deleteexperiment(mlf, experiment_id)
    end
end

@testset verbose = true "create experiment permission" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    permission = Permission.parse("READ")

    @testset "with string experiment id" begin
        user = createuser(mlf, "missy", "gala12345678")
        experiment_permission = 
            createexperimentpermission(mlf, experiment_id, user.username, permission)

        @test experiment_permission isa ExperimentPermission
        @test experiment_permission.experiment_id == experiment_id
        @test experiment_permission.user_id == user.id
        @test experiment_permission.permission == permission
        deleteexperimentpermission(mlf, experiment_id, user.username)
        deleteuser(mlf, user.username)
    end

    @testset "with integer experiment id" begin
        user = createuser(mlf, "missy", "gala12345678")
        experiment_permission = 
            createexperimentpermission(mlf, parse(Int, experiment_id), user.username, permission)

        @test experiment_permission isa ExperimentPermission
        @test experiment_permission.experiment_id == experiment_id
        @test experiment_permission.user_id == user.id
        @test experiment_permission.permission == permission
        deleteexperimentpermission(mlf, experiment_id, user.username)
        deleteuser(mlf, user.username)
    end

    @testset "with Experiment" begin
        experiment = getexperiment(mlf, experiment_id)
        user = createuser(mlf, "missy", "gala12345678")
        experiment_permission = 
            createexperimentpermission(mlf, experiment, user.username, permission)

        @test experiment_permission isa ExperimentPermission
        @test experiment_permission.experiment_id == experiment_id
        @test experiment_permission.user_id == user.id
        @test experiment_permission.permission == permission
        deleteexperimentpermission(mlf, experiment_id, user.username)
        deleteuser(mlf, user.username)
    end

    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "get experiment permission" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    permission = Permission.parse("READ")
    user = createuser(mlf, "missy", "gala12345678")

    @testset "with string experiment id" begin
        createexperimentpermission(mlf, experiment_id, user.username, permission)
        experiment_permission = getexperimentpermission(mlf, experiment_id, user.username)

        @test experiment_permission isa ExperimentPermission
        @test experiment_permission.experiment_id == experiment_id
        @test experiment_permission.user_id == user.id
        @test experiment_permission.permission == permission
        deleteexperimentpermission(mlf, experiment_id, user.username)
    end

    @testset "with integer experiment id" begin
        createexperimentpermission(mlf, parse(Int, experiment_id), user.username, permission)
        experiment_permission = getexperimentpermission(mlf, parse(Int, experiment_id), user.username)

        @test experiment_permission isa ExperimentPermission
        @test experiment_permission.experiment_id == experiment_id
        @test experiment_permission.user_id == user.id
        @test experiment_permission.permission == permission
        deleteexperimentpermission(mlf, experiment_id, user.username)
    end

    @testset "with Experiment" begin
        experiment = getexperiment(mlf, experiment_id)
        createexperimentpermission(mlf, experiment, user.username, permission)
        experiment_permission = getexperimentpermission(mlf, experiment, user.username)

        @test experiment_permission isa ExperimentPermission
        @test experiment_permission.experiment_id == experiment_id
        @test experiment_permission.user_id == user.id
        @test experiment_permission.permission == permission
        deleteexperimentpermission(mlf, experiment_id, user.username)
    end

    deleteuser(mlf, user.username)
    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "update experiment permission" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    permission = Permission.parse("READ")
    user = createuser(mlf, "missy", "gala12345678")

    @testset "with string experiment id" begin
        createexperimentpermission(mlf, experiment_id, user.username, permission)
        updateexperimentpermission(mlf, experiment_id, user.username, Permission.parse("EDIT"))
        experiment_permission = getexperimentpermission(mlf, experiment_id, user.username)

        @test experiment_permission.permission == Permission.parse("EDIT")
        deleteexperimentpermission(mlf, experiment_id, user.username)
    end

    @testset "with integer experiment id" begin
        createexperimentpermission(mlf, parse(Int, experiment_id), user.username, permission)
        updateexperimentpermission(mlf, parse(Int, experiment_id), user.username, Permission.parse("EDIT"))
        experiment_permission = getexperimentpermission(mlf, parse(Int, experiment_id), user.username)

        @test experiment_permission.permission == Permission.parse("EDIT")
        deleteexperimentpermission(mlf, experiment_id, user.username)
    end

    @testset "with Experiment" begin
        experiment = getexperiment(mlf, experiment_id)
        createexperimentpermission(mlf, experiment, user.username, permission)
        updateexperimentpermission(mlf, experiment, user.username, Permission.parse("EDIT"))
        experiment_permission = getexperimentpermission(mlf, experiment, user.username)

        @test experiment_permission.permission == Permission.parse("EDIT")
        deleteexperimentpermission(mlf, experiment_id, user.username)
    end

    deleteuser(mlf, user.username)
    deleteexperiment(mlf, experiment_id)
end

@testset verbose = true "delete experiment permission" begin
    @ensuremlf

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
    permission = Permission.parse("READ")
    user = createuser(mlf, "missy", "gala12345678")

    @testset "with string experiment id" begin
        createexperimentpermission(mlf, experiment_id, user.username, permission)
        deleteexperimentpermission(mlf, experiment_id, user.username)
        @test_throws ErrorException getexperimentpermission(mlf, experiment_id, user.username)
    end

    @testset "with integer experiment id" begin
        createexperimentpermission(mlf, parse(Int, experiment_id), user.username, permission)
        deleteexperimentpermission(mlf, parse(Int, experiment_id), user.username)
        @test_throws ErrorException getexperimentpermission(mlf, parse(Int, experiment_id), user.username)
    end

    @testset "with Experiment" begin
        experiment = getexperiment(mlf, experiment_id)
        createexperimentpermission(mlf, experiment, user.username, permission)
        deleteexperimentpermission(mlf, experiment, user.username)
        @test_throws ErrorException getexperimentpermission(mlf, experiment, user.username)
    end

    deleteuser(mlf, user.username)
    deleteexperiment(mlf, experiment_id)
end
