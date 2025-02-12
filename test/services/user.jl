@testset verbose = true "create user" begin
    @ensuremlf

    user = createuser(mlf, "missy", "gala")

    @test user isa User
    @test user.username == "missy"
    @test user.is_admin == false

    deleteuser(mlf, user.username)
end

@testset verbose = true "get user" begin
    @ensuremlf

    user = createuser(mlf, "missy", "gala")

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

    user = createuser(mlf, "missy", "gala")
    encoded_credentials = Base64.base64encode("$(user.username):gala")

    updateuserpassword(getmlfinstance(encoded_credentials), "missy", "ana")
    encoded_credentials = Base64.base64encode("$(user.username):ana")

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

    user = createuser(mlf, "missy", "gala")
    updateuseradmin(mlf, "missy", true)

    retrieved_user = getuser(mlf, "missy")
    @test retrieved_user.is_admin == true

    deleteuser(mlf, retrieved_user.username)
end

@testset verbose = true "delete user" begin
    @ensuremlf

    user = createuser(mlf, "missy", "gala")
    deleteuser(mlf, "missy")

    @test_throws ErrorException getuser(mlf, "missy")
end
