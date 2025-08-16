@testset verbose = true "create user" begin
    @ensuremlf

    user = createuser(mlf, "missy", "gala12345678")

    @test user isa User
    @test user.username == "missy"
    @test user.is_admin == false

    deleteuser(mlf, user.username)
end

@testset verbose = true "get user" begin
    @ensuremlf

    user = createuser(mlf, "missy", "gala12345678")

    retrieved_user = getuser(mlf, "missy")

    @test retrieved_user isa User
    @test retrieved_user.username == "missy"
    @test retrieved_user.is_admin == false

    deleteuser(mlf, retrieved_user.username)
end

@testset verbose = true "update user password" begin
    @ensuremlf

    getmlfinstance(encoded_credentials::String) =
        MLFlow(headers=Dict("Authorization" => "Basic $(encoded_credentials)"))

    user = createuser(mlf, "missy", "gala12345678")
    encoded_credentials = Base64.base64encode("$(user.username):gala12345678")

    updateuserpassword(getmlfinstance(encoded_credentials), "missy", "ana12345678")
    encoded_credentials = Base64.base64encode("$(user.username):ana12345678")

    @test begin 
        try
            searchexperiments(getmlfinstance(encoded_credentials))
            true
        catch
            false
        end
    end
    deleteuser(mlf, user.username)
end

@testset verbose = true "update user admin" begin
    @ensuremlf

    user = createuser(mlf, "missy", "gala12345678")
    updateuseradmin(mlf, "missy", true)

    retrieved_user = getuser(mlf, "missy")
    @test retrieved_user.is_admin == true

    deleteuser(mlf, retrieved_user.username)
end

@testset verbose = true "delete user" begin
    @ensuremlf

    user = createuser(mlf, "missy", "gala12345678")
    deleteuser(mlf, "missy")

    @test_throws ErrorException getuser(mlf, "missy")
end
