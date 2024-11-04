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
    renamed_registered_model = renameregisteredmodel(mlf, registered_model.name, "mister")

    @test renamed_registered_model isa RegisteredModel
    @test renamed_registered_model.name == "mister"
    @test renamed_registered_model.description == registered_model.description

    deleteregisteredmodel(mlf, "mister")
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
