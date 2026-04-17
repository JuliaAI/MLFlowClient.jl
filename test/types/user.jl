@testset verbose = true "user types" begin
    @testset "User from dict" begin
        data = fixture_user()
        user = User(data)
        @test user.id == "1"
        @test user.username == "testuser"
        @test user.is_admin == false
        @test isempty(user.experiment_permissions)
        @test isempty(user.registered_model_permissions)
    end

    @testset "User with permissions" begin
        data = fixture_user(
            experiment_permissions=[
                Dict{String,Any}("experiment_id" => "1", "user_id" => 1, "permission" => "READ")
            ],
            registered_model_permissions=[
                Dict{String,Any}("name" => "model1", "user_id" => 1, "permission" => "EDIT")
            ]
        )
        user = User(data)
        @test length(user.experiment_permissions) == 1
        @test user.experiment_permissions[1].experiment_id == "1"
        @test user.experiment_permissions[1].permission == Permission.READ
        @test length(user.registered_model_permissions) == 1
        @test user.registered_model_permissions[1].name == "model1"
        @test user.registered_model_permissions[1].permission == Permission.EDIT
    end

    @testset "User with integer id" begin
        data = fixture_user(id=42)
        user = User(data)
        @test user.id == "42"
    end

    @testset "User show" begin
        data = fixture_user()
        user = User(data)
        io = IOBuffer()
        show(io, user)
        @test !isempty(String(take!(io)))
    end
end
