@testset verbose = true "user types" begin
    @testset "User from dict" begin
        data = fixture_user()
        user = User(data)
        @test user.id == "1"
        @test user.username == "testuser"
        @test user.is_admin == false
    end

    @testset "User with admin and integer id" begin
        data = fixture_user(id=42, is_admin=true)
        user = User(data)
        @test user.id == "42"
        @test user.is_admin == true
    end

    @testset "User show" begin
        data = fixture_user()
        user = User(data)
        io = IOBuffer()
        show(io, user)
        @test !isempty(String(take!(io)))
    end
end
