@testset verbose = true "role types" begin
    @testset "RolePermission from dict" begin
        data = fixture_role_permission()
        rp = RolePermission(data)
        @test rp.id == 1
        @test rp.role_id == 1
        @test rp.resource_type == "experiment"
        @test rp.resource_pattern == "1"
        @test rp.permission == "MANAGE"
    end

    @testset "RolePermission defaults" begin
        rp = RolePermission(Dict{String,Any}())
        @test rp.id == 0
        @test rp.role_id == 0
        @test rp.resource_type == ""
        @test rp.resource_pattern == ""
        @test rp.permission == ""
    end

    @testset "Role from dict" begin
        data = fixture_role(description="a test role",
            permissions=[fixture_role_permission()])
        role = Role(data)
        @test role.id == 1
        @test role.name == "test-role"
        @test role.workspace == "default"
        @test role.description == "a test role"
        @test length(role.permissions) == 1
        @test role.permissions[1].permission == "MANAGE"
    end

    @testset "Role defaults" begin
        role = Role(Dict{String,Any}())
        @test role.id == 0
        @test role.name == ""
        @test role.workspace == ""
        @test isnothing(role.description)
        @test isempty(role.permissions)
    end

    @testset "UserRoleAssignment from dict" begin
        data = fixture_user_role_assignment(user_id=42, role_id=7)
        assignment = UserRoleAssignment(data)
        @test assignment.id == 1
        @test assignment.user_id == "42"
        @test assignment.role_id == 7
    end

    @testset "UserRoleAssignment defaults" begin
        assignment = UserRoleAssignment(Dict{String,Any}())
        @test assignment.id == 0
        @test assignment.user_id == ""
        @test assignment.role_id == 0
    end

    @testset "UserPermission from dict" begin
        data = fixture_user_permission()
        up = UserPermission(data)
        @test up.role_id == 1
        @test up.role_name == "__user_1__"
        @test up.workspace == "default"
        @test up.resource_type == "experiment"
        @test up.resource_pattern == "1"
        @test up.permission == "MANAGE"
    end

    @testset "UserPermission defaults" begin
        up = UserPermission(Dict{String,Any}())
        @test up.role_id == 0
        @test up.role_name == ""
        @test up.workspace == ""
        @test up.resource_type == ""
        @test up.resource_pattern == ""
        @test up.permission == ""
    end
end
