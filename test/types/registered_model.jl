@testset verbose = true "registered model types" begin
    @testset "RegisteredModelAlias from dict" begin
        data = Dict{String,Any}("alias" => "production", "version" => "3")
        alias = RegisteredModelAlias(data)
        @test alias.alias == "production"
        @test alias.version == "3"
    end

    @testset "RegisteredModelAlias show" begin
        alias = RegisteredModelAlias("prod", "1")
        io = IOBuffer()
        show(io, alias)
        @test !isempty(String(take!(io)))
    end

    @testset "RegisteredModel from dict" begin
        data = fixture_registered_model(
            tags=[Dict{String,Any}("key" => "team", "value" => "ml")],
            aliases=[Dict{String,Any}("alias" => "prod", "version" => "2")]
        )
        rm = RegisteredModel(data)
        @test rm.name == "test-model"
        @test rm.creation_timestamp == 1700000000000
        @test rm.last_updated_timestamp == 1700000000000
        @test isnothing(rm.user_id)
        @test rm.description == "A test model"
        @test isempty(rm.latest_versions)
        @test length(rm.tags) == 1
        @test rm.tags[1].key == "team"
        @test length(rm.aliases) == 1
        @test rm.aliases[1].alias == "prod"
        @test isnothing(rm.deployment_job_id)
        @test isnothing(rm.deployment_job_state)
    end

    @testset "RegisteredModel with deployment_job_state" begin
        data = fixture_registered_model()
        data["deployment_job_state"] = "CONNECTED"
        rm = RegisteredModel(data)
        @test rm.deployment_job_state == State.CONNECTED
    end

    @testset "RegisteredModel with deployment_job_id" begin
        data = fixture_registered_model()
        data["deployment_job_id"] = "job-123"
        rm = RegisteredModel(data)
        @test rm.deployment_job_id == "job-123"
    end

    @testset "RegisteredModel show" begin
        data = fixture_registered_model()
        rm = RegisteredModel(data)
        io = IOBuffer()
        show(io, rm)
        @test !isempty(String(take!(io)))
    end

    @testset "RegisteredModelPermission from dict" begin
        data = Dict{String,Any}(
            "name" => "my-model",
            "user_id" => 42,
            "permission" => "MANAGE"
        )
        perm = RegisteredModelPermission(data)
        @test perm.name == "my-model"
        @test perm.user_id == "42"
        @test perm.permission == Permission.MANAGE
    end

    @testset "RegisteredModelPermission show" begin
        perm = RegisteredModelPermission("model", "1", Permission.READ)
        io = IOBuffer()
        show(io, perm)
        @test !isempty(String(take!(io)))
    end
end
