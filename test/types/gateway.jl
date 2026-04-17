@testset verbose = true "gateway types" begin
    @testset "FallbackConfig from dict" begin
        data = Dict{String,Any}("strategy" => "SEQUENTIAL", "max_attempts" => 3)
        fc = FallbackConfig(data)
        @test fc.strategy == "SEQUENTIAL"
        @test fc.max_attempts == 3
    end

    @testset "FallbackConfig defaults" begin
        fc = FallbackConfig(Dict{String,Any}())
        @test fc.strategy == ""
        @test fc.max_attempts == 0
    end

    @testset "BudgetDuration from dict" begin
        data = Dict{String,Any}("unit" => "HOURS", "value" => 24)
        bd = BudgetDuration(data)
        @test bd.unit == "HOURS"
        @test bd.value == 24
    end

    @testset "BudgetDuration defaults" begin
        bd = BudgetDuration(Dict{String,Any}())
        @test bd.unit == ""
        @test bd.value == 0
    end

    @testset "GatewayEndpointModelConfig from dict" begin
        data = Dict{String,Any}(
            "model_definition_id" => "mdef-1",
            "linkage_type" => "PRIMARY",
            "weight" => 0.75,
            "fallback_order" => 2
        )
        config = GatewayEndpointModelConfig(data)
        @test config.model_definition_id == "mdef-1"
        @test config.linkage_type == "PRIMARY"
        @test config.weight == 0.75
        @test config.fallback_order == 2
    end

    @testset "GatewayEndpointModelConfig defaults" begin
        config = GatewayEndpointModelConfig(Dict{String,Any}())
        @test config.model_definition_id == ""
        @test config.linkage_type == ""
        @test config.weight == 0.0
        @test config.fallback_order == 0
    end

    @testset "GatewayEndpointTag from dict" begin
        data = Dict{String,Any}("key" => "env", "value" => "prod")
        tag = GatewayEndpointTag(data)
        @test tag.key == "env"
        @test tag.value == "prod"
    end

    @testset "GatewayEndpointModelMapping from dict" begin
        data = Dict{String,Any}(
            "mapping_id" => "map-1",
            "endpoint_id" => "ep-1",
            "model_definition_id" => "mdef-1",
            "weight" => 0.5,
            "created_at" => 1700000000000,
            "created_by" => "user1",
            "linkage_type" => "PRIMARY",
            "fallback_order" => 0
        )
        mapping = GatewayEndpointModelMapping(data)
        @test mapping.mapping_id == "map-1"
        @test mapping.endpoint_id == "ep-1"
        @test mapping.model_definition_id == "mdef-1"
        @test isnothing(mapping.model_definition)
        @test mapping.weight == 0.5
        @test mapping.created_at == 1700000000000
        @test mapping.created_by == "user1"
        @test mapping.linkage_type == "PRIMARY"
        @test mapping.fallback_order == 0
    end

    @testset "GatewayEndpointModelMapping with nested model_definition" begin
        data = Dict{String,Any}(
            "mapping_id" => "map-1",
            "endpoint_id" => "ep-1",
            "model_definition_id" => "mdef-1",
            "model_definition" => Dict{String,Any}(
                "model_definition_id" => "mdef-1",
                "name" => "gpt-4-def",
                "secret_id" => "s-1",
                "provider" => "openai",
                "model_name" => "gpt-4"
            ),
            "weight" => 1.0,
            "created_at" => 1700000000000,
            "linkage_type" => "PRIMARY"
        )
        mapping = GatewayEndpointModelMapping(data)
        @test !isnothing(mapping.model_definition)
        @test mapping.model_definition.name == "gpt-4-def"
        @test mapping.model_definition.provider == "openai"
    end

    @testset "GatewayEndpointModelMapping defaults" begin
        mapping = GatewayEndpointModelMapping(Dict{String,Any}())
        @test mapping.mapping_id == ""
        @test mapping.endpoint_id == ""
        @test mapping.model_definition_id == ""
        @test isnothing(mapping.model_definition)
        @test mapping.weight == 0.0
        @test mapping.created_at == 0
        @test mapping.created_by == ""
        @test mapping.linkage_type == ""
        @test mapping.fallback_order == 0
    end

    @testset "GatewaySecretInfo from dict" begin
        data = fixture_gateway_secret()
        secret = GatewaySecretInfo(data)
        @test secret.secret_id == "secret-abc"
        @test secret.secret_name == "my-secret"
        @test secret.provider == "openai"
        @test secret.created_by == "user1"
        @test secret.last_updated_by == "user1"
        @test secret.created_at == 1700000000000
        @test secret.last_updated_at == 1700000000000
    end

    @testset "GatewaySecretInfo defaults" begin
        secret = GatewaySecretInfo(Dict{String,Any}())
        @test secret.secret_id == ""
        @test secret.secret_name == ""
        @test secret.provider == ""
        @test secret.created_by == ""
        @test secret.last_updated_by == ""
        @test secret.created_at == 0
        @test secret.last_updated_at == 0
    end

    @testset "GatewayModelDefinition from dict" begin
        data = fixture_gateway_model_definition()
        mdef = GatewayModelDefinition(data)
        @test mdef.model_definition_id == "mdef-abc"
        @test mdef.name == "gpt-4-def"
        @test mdef.secret_id == "secret-abc"
        @test mdef.secret_name == "probe-secret"
        @test mdef.provider == "openai"
        @test mdef.model_name == "gpt-4"
        @test mdef.created_by == "user1"
        @test mdef.last_updated_by == "user1"
        @test mdef.created_at == 1700000000000
        @test mdef.last_updated_at == 1700000000000
    end

    @testset "GatewayModelDefinition defaults" begin
        mdef = GatewayModelDefinition(Dict{String,Any}())
        @test mdef.model_definition_id == ""
        @test mdef.name == ""
        @test mdef.secret_id == ""
        @test mdef.secret_name == ""
        @test mdef.provider == ""
        @test mdef.model_name == ""
    end

    @testset "GatewayEndpointConfig from dict" begin
        data = Dict{String,Any}(
            "model_definition_id" => "mdef-1",
            "route" => "/v1/chat",
            "limits" => "{}",
            "auth" => "{}",
            "metadata" => "{}"
        )
        config = GatewayEndpointConfig(data)
        @test config.model_definition_id == "mdef-1"
        @test config.route == "/v1/chat"
    end

    @testset "GatewayEndpoint from dict" begin
        data = fixture_gateway_endpoint(
            tags=[Dict{String,Any}("key" => "env", "value" => "prod")],
            model_mappings=[Dict{String,Any}(
                "mapping_id" => "map-1",
                "endpoint_id" => "ep-abc",
                "model_definition_id" => "mdef-1",
                "weight" => 1.0,
                "created_at" => 1700000000000,
                "linkage_type" => "PRIMARY"
            )]
        )
        ep = GatewayEndpoint(data)
        @test ep.endpoint_id == "ep-abc"
        @test ep.name == "test-endpoint"
        @test ep.created_by == "user1"
        @test ep.last_updated_by == "user1"
        @test ep.created_at == 1700000000000
        @test ep.last_updated_at == 1700000000000
        @test length(ep.tags) == 1
        @test ep.tags[1].key == "env"
        @test ep.tags[1].value == "prod"
        @test length(ep.model_mappings) == 1
        @test ep.model_mappings[1].model_definition_id == "mdef-1"
        @test ep.experiment_id == ""
        @test ep.usage_tracking == false
    end

    @testset "GatewayEndpoint with fallback_config" begin
        data = fixture_gateway_endpoint()
        data["fallback_config"] = Dict{String,Any}("strategy" => "SEQUENTIAL", "max_attempts" => 3)
        ep = GatewayEndpoint(data)
        @test ep.fallback_config.strategy == "SEQUENTIAL"
        @test ep.fallback_config.max_attempts == 3
    end

    @testset "GatewayEndpoint defaults" begin
        ep = GatewayEndpoint(Dict{String,Any}())
        @test ep.endpoint_id == ""
        @test ep.name == ""
        @test isempty(ep.model_mappings)
        @test isempty(ep.tags)
        @test isnothing(ep.fallback_config)
        @test ep.experiment_id == ""
        @test ep.usage_tracking == false
    end

    @testset "GatewayEndpointBinding from dict" begin
        data = fixture_gateway_endpoint_binding()
        binding = GatewayEndpointBinding(data)
        @test binding.endpoint_id == "ep-abc"
        @test binding.resource_type == "scorer"
        @test binding.resource_id == "scorer-abc"
        @test binding.created_by == "user1"
        @test binding.created_at == 1700000000000
    end

    @testset "GatewayEndpointBinding defaults" begin
        binding = GatewayEndpointBinding(Dict{String,Any}())
        @test binding.endpoint_id == ""
        @test binding.resource_type == ""
        @test binding.resource_id == ""
        @test binding.created_by == ""
        @test binding.created_at == 0
    end

    @testset "GatewayBudgetWindow from dict" begin
        data = fixture_gateway_budget_window()
        window = GatewayBudgetWindow(data)
        @test window.budget_policy_id == "bp-abc"
        @test window.window_start_ms == 1700000000000
        @test window.window_end_ms == 1700003600000
        @test window.current_spend == 42.5
    end

    @testset "GatewayBudgetPolicy from dict" begin
        data = fixture_gateway_budget_policy()
        policy = GatewayBudgetPolicy(data)
        @test policy.budget_policy_id == "bp-abc"
        @test policy.budget_unit == "USD"
        @test policy.budget_amount == 1000.0
        @test policy.duration.unit == "HOURS"
        @test policy.duration.value == 1
        @test policy.target_scope == "GLOBAL"
        @test policy.budget_action == "ALERT"
        @test policy.created_by == "user1"
        @test policy.last_updated_by == "user1"
        @test policy.created_at == 1700000000000
        @test policy.last_updated_at == 1700000000000
    end
end
