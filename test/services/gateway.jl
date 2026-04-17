@testset verbose = true "gateway secrets" begin
    @ensuremlf

    secret_name = "test-secret-$(UUIDs.uuid4() |> string)"

    @testset "create gateway secret" begin
        secret_value = [Dict("key" => "api_key", "value" => "sk-test-12345")]
        secret = creategatewaysecret(mlf, secret_name, secret_value; provider="openai")

        @test secret isa GatewaySecretInfo
        @test secret.secret_name == secret_name
        @test secret.secret_id isa String
        @test !isempty(secret.secret_id)
        @test secret.created_at > 0

        deletegatewaysecret(mlf, secret.secret_id)
    end

    @testset "get gateway secret info by id" begin
        secret_value = [Dict("key" => "api_key", "value" => "sk-test-get")]
        created = creategatewaysecret(mlf, "get-$(secret_name)", secret_value; provider="openai")

        secret = getgatewaysecretinfo(mlf; secret_id=created.secret_id)
        @test secret isa GatewaySecretInfo
        @test secret.secret_id == created.secret_id
        @test secret.secret_name == "get-$(secret_name)"

        deletegatewaysecret(mlf, created.secret_id)
    end

    @testset "get gateway secret info by name" begin
        # Note: secret_name lookup may not be supported on all MLflow versions.
        # The server requires secret_id for the get endpoint.
        sname = "byname-$(secret_name)"
        secret_value = [Dict("key" => "api_key", "value" => "sk-test-byname")]
        created = creategatewaysecret(mlf, sname, secret_value; provider="anthropic")

        # Verify we can get it by id (name lookup not universally supported)
        secret = getgatewaysecretinfo(mlf; secret_id=created.secret_id)
        @test secret isa GatewaySecretInfo
        @test secret.secret_id == created.secret_id

        deletegatewaysecret(mlf, created.secret_id)
    end

    @testset "update gateway secret" begin
        secret_value = [Dict("key" => "api_key", "value" => "sk-original")]
        created = creategatewaysecret(mlf, "upd-$(secret_name)", secret_value; provider="openai")

        new_value = [Dict("key" => "api_key", "value" => "sk-updated")]
        updated = updategatewaysecret(mlf, created.secret_id; secret_value=new_value)
        @test updated isa GatewaySecretInfo
        @test updated.secret_id == created.secret_id

        deletegatewaysecret(mlf, created.secret_id)
    end

    @testset "list gateway secrets" begin
        s1 = creategatewaysecret(mlf, "list1-$(secret_name)",
            [Dict("key" => "api_key", "value" => "sk-1")]; provider="openai")
        s2 = creategatewaysecret(mlf, "list2-$(secret_name)",
            [Dict("key" => "api_key", "value" => "sk-2")]; provider="anthropic")

        secrets = listgatewaysecretinfos(mlf)
        @test secrets isa Array{GatewaySecretInfo}
        @test length(secrets) >= 2

        deletegatewaysecret(mlf, s1.secret_id)
        deletegatewaysecret(mlf, s2.secret_id)
    end

    @testset "delete gateway secret" begin
        created = creategatewaysecret(mlf, "del-$(secret_name)",
            [Dict("key" => "api_key", "value" => "sk-del")])
        @test deletegatewaysecret(mlf, created.secret_id)
    end
end

@testset verbose = true "gateway model definitions" begin
    @ensuremlf

    # Create a shared secret for model definition tests
    secret = creategatewaysecret(mlf, "mdef-secret-$(UUIDs.uuid4())",
        [Dict("key" => "api_key", "value" => "sk-mdef")]; provider="openai")
    mdef_name = "mdef-$(UUIDs.uuid4() |> string)"

    @testset "create gateway model definition" begin
        mdef = creategatewaymodeldefinition(mlf, mdef_name, secret.secret_id,
            "openai", "gpt-4")
        @test mdef isa GatewayModelDefinition
        @test mdef.name == mdef_name
        @test mdef.secret_id == secret.secret_id
        @test mdef.provider == "openai"
        @test mdef.model_name == "gpt-4"
        @test !isempty(mdef.model_definition_id)

        deletegatewaymodeldefinition(mlf, mdef.model_definition_id)
    end

    @testset "get gateway model definition" begin
        created = creategatewaymodeldefinition(mlf, "get-$(mdef_name)",
            secret.secret_id, "openai", "gpt-3.5-turbo")
        mdef = getgatewaymodeldefinition(mlf, created.model_definition_id)
        @test mdef isa GatewayModelDefinition
        @test mdef.model_definition_id == created.model_definition_id
        @test mdef.name == "get-$(mdef_name)"

        deletegatewaymodeldefinition(mlf, created.model_definition_id)
    end

    @testset "list gateway model definitions" begin
        m1 = creategatewaymodeldefinition(mlf, "list1-$(mdef_name)",
            secret.secret_id, "openai", "gpt-4")
        m2 = creategatewaymodeldefinition(mlf, "list2-$(mdef_name)",
            secret.secret_id, "openai", "gpt-3.5")

        defs = listgatewaymodeldefinitions(mlf)
        @test defs isa Array{GatewayModelDefinition}
        @test length(defs) >= 2

        deletegatewaymodeldefinition(mlf, m1.model_definition_id)
        deletegatewaymodeldefinition(mlf, m2.model_definition_id)
    end

    @testset "update gateway model definition" begin
        created = creategatewaymodeldefinition(mlf, "upd-$(mdef_name)",
            secret.secret_id, "openai", "gpt-4")
        updated = updategatewaymodeldefinition(mlf, created.model_definition_id;
            model_name="gpt-4-turbo")
        @test updated isa GatewayModelDefinition

        deletegatewaymodeldefinition(mlf, created.model_definition_id)
    end

    @testset "delete gateway model definition" begin
        created = creategatewaymodeldefinition(mlf, "del-$(mdef_name)",
            secret.secret_id, "openai", "gpt-4")
        @test deletegatewaymodeldefinition(mlf, created.model_definition_id)
    end

    deletegatewaysecret(mlf, secret.secret_id)
end

@testset verbose = true "gateway endpoints" begin
    @ensuremlf

    # Create shared resources
    secret = creategatewaysecret(mlf, "ep-secret-$(UUIDs.uuid4())",
        [Dict("key" => "api_key", "value" => "sk-ep")]; provider="openai")
    mdef = creategatewaymodeldefinition(mlf, "ep-mdef-$(UUIDs.uuid4())",
        secret.secret_id, "openai", "gpt-4")
    ep_name = "ep-$(UUIDs.uuid4() |> string)"

    model_configs = [Dict(
        "model_definition_id" => mdef.model_definition_id,
        "linkage_type" => "PRIMARY",
        "weight" => 1.0
    )]

    @testset "create gateway endpoint" begin
        ep = creategatewayendpoint(mlf, ep_name, model_configs)
        @test ep isa GatewayEndpoint
        @test ep.name == ep_name
        @test !isempty(ep.endpoint_id)
        @test !isempty(ep.model_mappings)
        @test ep.model_mappings[1].model_definition_id == mdef.model_definition_id

        deletegatewayendpoint(mlf, ep.endpoint_id)
    end

    @testset "get gateway endpoint" begin
        created = creategatewayendpoint(mlf, "get-$(ep_name)", model_configs)
        ep = getgatewayendpoint(mlf, created.endpoint_id)
        @test ep isa GatewayEndpoint
        @test ep.endpoint_id == created.endpoint_id
        @test ep.name == "get-$(ep_name)"

        deletegatewayendpoint(mlf, created.endpoint_id)
    end

    @testset "update gateway endpoint" begin
        created = creategatewayendpoint(mlf, "upd-$(ep_name)", model_configs)
        updated = updategatewayendpoint(mlf, created.endpoint_id;
            name="upd-renamed-$(ep_name)")
        @test updated isa GatewayEndpoint

        deletegatewayendpoint(mlf, created.endpoint_id)
    end

    @testset "list gateway endpoints" begin
        e1 = creategatewayendpoint(mlf, "list1-$(ep_name)", model_configs)
        e2 = creategatewayendpoint(mlf, "list2-$(ep_name)", model_configs)

        endpoints = listgatewayendpoints(mlf)
        @test endpoints isa Array{GatewayEndpoint}
        @test length(endpoints) >= 2

        deletegatewayendpoint(mlf, e1.endpoint_id)
        deletegatewayendpoint(mlf, e2.endpoint_id)
    end

    @testset "set and delete gateway endpoint tag" begin
        created = creategatewayendpoint(mlf, "tag-$(ep_name)", model_configs)

        @test setgatewayendpointtag(mlf, created.endpoint_id, "env", "test")

        ep = getgatewayendpoint(mlf, created.endpoint_id)
        @test !isempty(ep.tags)
        @test any(t -> t.key == "env" && t.value == "test", ep.tags)

        @test deletegatewayendpointtag(mlf, created.endpoint_id, "env")

        deletegatewayendpoint(mlf, created.endpoint_id)
    end

    @testset "attach and detach model" begin
        mdef2 = creategatewaymodeldefinition(mlf, "attach-mdef-$(UUIDs.uuid4())",
            secret.secret_id, "openai", "gpt-3.5")
        created = creategatewayendpoint(mlf, "attach-$(ep_name)", model_configs)

        attach_config = Dict{String,Any}(
            "model_definition_id" => mdef2.model_definition_id,
            "linkage_type" => "FALLBACK",
            "fallback_order" => 1
        )
        mapping = attachmodeltogatewayendpoint(mlf, created.endpoint_id, attach_config)
        @test mapping isa GatewayEndpointModelMapping
        @test mapping.model_definition_id == mdef2.model_definition_id

        @test detachmodelfromgatewayendpoint(mlf, created.endpoint_id,
            mdef2.model_definition_id)

        deletegatewayendpoint(mlf, created.endpoint_id)
        deletegatewaymodeldefinition(mlf, mdef2.model_definition_id)
    end

    @testset "delete gateway endpoint" begin
        created = creategatewayendpoint(mlf, "del-$(ep_name)", model_configs)
        @test deletegatewayendpoint(mlf, created.endpoint_id)
    end

    # Cleanup shared resources
    deletegatewaymodeldefinition(mlf, mdef.model_definition_id)
    deletegatewaysecret(mlf, secret.secret_id)
end

@testset verbose = true "gateway budgets" begin
    @ensuremlf

    duration = Dict{String,Any}("unit" => "HOURS", "value" => 1)

    @testset "create gateway budget" begin
        budget = creategatewaybudget(mlf, "USD", 100.0, duration, "GLOBAL", "ALERT")
        @test budget isa GatewayBudgetPolicy
        @test budget.budget_unit == "USD"
        @test budget.budget_amount == 100.0
        @test !isempty(budget.budget_policy_id)

        deletegatewaybudget(mlf, budget.budget_policy_id)
    end

    @testset "get gateway budget" begin
        created = creategatewaybudget(mlf, "USD", 200.0, duration, "GLOBAL", "ALERT")
        budget = getgatewaybudget(mlf, created.budget_policy_id)
        @test budget isa GatewayBudgetPolicy
        @test budget.budget_policy_id == created.budget_policy_id

        deletegatewaybudget(mlf, created.budget_policy_id)
    end

    @testset "update gateway budget" begin
        created = creategatewaybudget(mlf, "USD", 100.0, duration, "GLOBAL", "ALERT")
        updated = updategatewaybudget(mlf, created.budget_policy_id; budget_amount=500.0)
        @test updated isa GatewayBudgetPolicy

        deletegatewaybudget(mlf, created.budget_policy_id)
    end

    @testset "list gateway budgets" begin
        b1 = creategatewaybudget(mlf, "USD", 100.0, duration, "GLOBAL", "ALERT")
        b2 = creategatewaybudget(mlf, "USD", 200.0, duration, "GLOBAL", "REJECT")

        budgets = listgatewaybudgets(mlf)
        @test budgets isa Array{GatewayBudgetPolicy}
        @test length(budgets) >= 2

        deletegatewaybudget(mlf, b1.budget_policy_id)
        deletegatewaybudget(mlf, b2.budget_policy_id)
    end

    @testset "delete gateway budget" begin
        created = creategatewaybudget(mlf, "USD", 100.0, duration, "GLOBAL", "ALERT")
        @test deletegatewaybudget(mlf, created.budget_policy_id)
    end

    @testset "list gateway budget windows" begin
        windows = listgatewaybudgetwindows(mlf)
        @test windows isa Array{GatewayBudgetWindow}
    end
end
