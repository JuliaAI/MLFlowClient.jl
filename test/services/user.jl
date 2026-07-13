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

    updateuserpassword(getmlfinstance(encoded_credentials), "missy", "ana12345678";
        current_password="gala12345678")
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

@testset verbose = true "list users and current user" begin
    @ensuremlf

    username = "rbac-$(UUIDs.uuid4() |> string)"
    createuser(mlf, username, "gala12345678")

    @testset "list users" begin
        users = listusers(mlf)
        @test users isa Array{User}
        @test any(u -> u.username == username, users)
    end

    @testset "get current user" begin
        current = getcurrentuser(mlf)
        @test current isa User
        @test current.username == "admin"
        @test current.is_admin == true
    end

    @testset "list current user permissions" begin
        result = listcurrentuserpermissions(mlf)
        @test result.is_admin == true
        @test result.permissions isa Array{UserPermission}
    end

    deleteuser(mlf, username)
end

@testset verbose = true "roles" begin
    @ensuremlf

    @testset "create, get, list, update, delete role" begin
        role = createrole(mlf, "role-$(UUIDs.uuid4() |> string)", "default";
            description="a test role")
        @test role isa Role
        @test !iszero(role.id)
        @test role.workspace == "default"

        fetched = getrole(mlf, role.id)
        @test fetched.id == role.id

        roles = listroles(mlf)
        @test roles isa Array{Role}
        @test any(r -> r.id == role.id, roles)

        updated = updaterole(mlf, role.id; description="updated description")
        @test updated.description == "updated description"

        @test deleterole(mlf, role.id)
    end

    @testset "role permissions" begin
        experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
        role = createrole(mlf, "rp-$(UUIDs.uuid4() |> string)", "default")

        rp = addrolepermission(mlf, role.id, "experiment", experiment_id, "READ")
        @test rp isa RolePermission
        @test rp.resource_type == "experiment"
        @test rp.permission == "READ"

        perms = listrolepermissions(mlf, role.id)
        @test perms isa Array{RolePermission}
        @test any(p -> p.id == rp.id, perms)

        updated = updaterolepermission(mlf, rp.id, "MANAGE")
        @test updated.permission == "MANAGE"

        @test removerolepermission(mlf, rp.id)

        deleterole(mlf, role.id)
        deleteexperiment(mlf, experiment_id)
    end

    @testset "role assignment" begin
        username = "asg-$(UUIDs.uuid4() |> string)"
        createuser(mlf, username, "gala12345678")
        role = createrole(mlf, "asg-$(UUIDs.uuid4() |> string)", "default")

        assignment = assignrole(mlf, username, role.id)
        @test assignment isa UserRoleAssignment
        @test assignment.role_id == role.id

        user_roles = listuserroles(mlf, username)
        @test user_roles isa Array{Role}
        @test any(r -> r.id == role.id, user_roles)

        role_users = listroleusers(mlf, role.id)
        @test role_users isa Array{UserRoleAssignment}
        @test any(a -> a.role_id == role.id, role_users)

        @test unassignrole(mlf, username, role.id)

        deleterole(mlf, role.id)
        deleteuser(mlf, username)
    end
end

@testset verbose = true "user permissions" begin
    @ensuremlf

    username = "perm-$(UUIDs.uuid4() |> string)"
    createuser(mlf, username, "gala12345678")
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "grant, get, list, revoke" begin
        @test grantuserpermission(mlf, username, "experiment", experiment_id, "MANAGE")

        resolved = getuserpermission(mlf, username, "experiment", experiment_id)
        @test resolved.allowed == true
        @test resolved.permission == "MANAGE"

        listed = listuserpermissions(mlf, username)
        @test listed.permissions isa Array{UserPermission}
        @test any(p -> p.resource_pattern == experiment_id, listed.permissions)

        @test revokeuserpermission(mlf, username, "experiment", experiment_id)
    end

    deleteexperiment(mlf, experiment_id)
    deleteuser(mlf, username)
end
