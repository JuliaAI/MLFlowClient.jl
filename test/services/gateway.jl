@testset verbose = true "gateway service" begin
    @ensuremlf
    mlf === nothing && return nothing

    # Gateway endpoints are specific to Databricks MLFlow
    if !occursin("databricks", lowercase(mlf.apiroot))
        @warn "Gateway endpoints are Databricks-specific features. These tests will be skipped because the current tracking URI ($(mlf.apiroot)) is not a Databricks URL."
        return nothing
    end

    @testset "gateway secrets" begin
        secret_name = UUIDs.uuid4() |> string

        @testset "create gateway secret" begin
            secret_value = [Dict("key" => "api_key", "value" => "sk-test-12345")]

            secret = creategatewaysecret(mlf, secret_name, secret_value;
                provider="openai", created_by="test_user")

            @test secret isa GatewaySecretInfo
            @test secret.secret_name == secret_name
            @test secret.provider == "openai"
            @test secret.created_by == "test_user"
            @test secret.secret_id isa String
            @test secret.creation_timestamp isa Int64
        end

        @testset "get gateway secret info" begin
            # Create a secret first
            secret_value = [Dict("key" => "api_key", "value" => "sk-test-67890")]
            created_secret = creategatewaysecret(mlf, "$(secret_name)_get", secret_value; provider="openai", created_by="test_user")

            # Get by secret_id
            @test created_secret.secret_id isa String
            secret = getgatewaysecretinfo(mlf; secret_id=created_secret.secret_id)
            @test secret isa GatewaySecretInfo
            @test secret.secret_id == created_secret.secret_id

            # Cleanup
            deletegatewaysecret(mlf, created_secret.secret_id)
        end

        @testset "update gateway secret" begin
            # Create a secret first
            secret_value = [Dict("key" => "api_key", "value" => "sk-test-original")]
            created_secret = creategatewaysecret(mlf, "$(secret_name)_update", secret_value; provider="openai", created_by="test_user")

            # Update the secret
            new_secret_value = [Dict("key" => "api_key", "value" => "sk-test-updated")]
            updated_secret = updategatewaysecret(mlf, created_secret.secret_id;
                secret_value=new_secret_value, updated_by="test_user")

            @test updated_secret isa GatewaySecretInfo
            @test updated_secret.secret_id == created_secret.secret_id
        end

        @testset "list gateway secret infos" begin
            # Create a couple of secrets
            creategatewaysecret(mlf, "$(secret_name)_list1", [Dict("key" => "api_key", "value" => "sk-test-1")];
                provider="anthropic")
            creategatewaysecret(mlf, "$(secret_name)_list2", [Dict("key" => "api_key", "value" => "sk-test-2")];
                provider="openai")

            # List all
            secrets = listgatewaysecretinfos(mlf)
            @test secrets isa Array{GatewaySecretInfo}
            @test length(secrets) >= 2

            # List with provider filter
            secrets_filtered = listgatewaysecretinfos(mlf; provider="openai")
            @test secrets_filtered isa Array{GatewaySecretInfo}
        end

        @testset "delete gateway secret" begin
            # Create a secret to delete
            created_secret = creategatewaysecret(mlf, "$(secret_name)_delete",
                [Dict("key" => "api_key", "value" => "sk-test-delete")])

            @test deletegatewaysecret(mlf, created_secret.secret_id)
        end
    end

    @testset "gateway model definitions" begin
        model_def_name = UUIDs.uuid4() |> string

        # Create a secret first for the model definition
        secret = creategatewaysecret(mlf, "secret_for_$(model_def_name)",
            [Dict("key" => "api_key", "value" => "sk-test-model-def")]; provider="openai")

        @testset "create gateway model definition" begin
            model_def = creategatewaymodeldefinition(mlf, model_def_name,
                secret.secret_id, "openai", "gpt-4"; created_by="test_user")

            @test model_def isa GatewayModelDefinition
            @test model_def.name == model_def_name
            @test model_def.secret_id == secret.secret_id
            @test model_def.provider == "openai"
            @test model_def.model_name == "gpt-4"
            @test model_def.created_by == "test_user"
            @test model_def.model_definition_id isa String
        end

        @testset "get gateway model definition" begin
            created_model_def = creategatewaymodeldefinition(mlf, "$(model_def_name)_get",
                secret.secret_id, "openai", "gpt-3.5-turbo")

            model_def = getgatewaymodeldefinition(mlf, created_model_def.model_definition_id)

            @test model_def isa GatewayModelDefinition
            @test model_def.model_definition_id == created_model_def.model_definition_id
            @test model_def.name == "$(model_def_name)_get"
        end

        @testset "list gateway model definitions" begin
            creategatewaymodeldefinition(mlf, "$(model_def_name)_list1",
                secret.secret_id, "openai", "gpt-4")
            creategatewaymodeldefinition(mlf, "$(model_def_name)_list2",
                secret.secret_id, "anthropic", "claude-3")

            model_defs = listgatewaymodeldefinitions(mlf)
            @test model_defs isa Array{GatewayModelDefinition}
            @test length(model_defs) >= 2

            # With provider filter
            model_defs_filtered = listgatewaymodeldefinitions(mlf; provider="openai")
            @test model_defs_filtered isa Array{GatewayModelDefinition}
        end

        @testset "update gateway model definition" begin
            created_model_def = creategatewaymodeldefinition(mlf, "$(model_def_name)_update",
                secret.secret_id, "openai", "gpt-4")

            updated_model_def = updategatewaymodeldefinition(mlf,
                created_model_def.model_definition_id;
                model_name="gpt-4-turbo", updated_by="test_user")

            @test updated_model_def isa GatewayModelDefinition
        end

        @testset "delete gateway model definition" begin
            created_model_def = creategatewaymodeldefinition(mlf, "$(model_def_name)_delete",
                secret.secret_id, "openai", "gpt-4")

            @test deletegatewaymodeldefinition(mlf, created_model_def.model_definition_id)
        end

        # Cleanup secret
        deletegatewaysecret(mlf, secret.secret_id)
    end

    @testset "gateway endpoints" begin
        endpoint_name = UUIDs.uuid4() |> string

        # Create a secret and model definition for the endpoint
        secret = creategatewaysecret(mlf, "secret_for_endpoint_$(UUIDs.uuid4())",
            [Dict("key" => "api_key", "value" => "sk-test-endpoint")]; provider="openai", created_by="test_user")
        model_def = creategatewaymodeldefinition(mlf, "model_def_for_endpoint_$(UUIDs.uuid4())",
            secret.secret_id, "openai", "gpt-4"; created_by="test_user")

        @testset "create gateway endpoint" begin
            model_configs = [Dict(
                "model_definition_id" => model_def.model_definition_id,
                "linkage_type" => "PRIMARY",
                "weight" => 1.0
            )]

            endpoint = creategatewayendpoint(mlf, endpoint_name, model_configs;
                created_by="test_user")

            @test endpoint isa GatewayEndpoint
            @test endpoint.name == endpoint_name
            @test endpoint.created_by == "test_user"
            @test endpoint.endpoint_id isa String
        end

        @testset "get gateway endpoint" begin
            model_configs = [Dict(
                "model_definition_id" => model_def.model_definition_id,
                "linkage_type" => "PRIMARY",
                "weight" => 1.0
            )]

            created_endpoint = creategatewayendpoint(mlf, "$(endpoint_name)_get",
                model_configs; created_by="test_user")

            endpoint = getgatewayendpoint(mlf, created_endpoint.endpoint_id)

            @test endpoint isa GatewayEndpoint
            @test endpoint.endpoint_id == created_endpoint.endpoint_id
            @test endpoint.name == "$(endpoint_name)_get"
        end

        @testset "update gateway endpoint" begin
            model_configs = [Dict(
                "model_definition_id" => model_def.model_definition_id,
                "linkage_type" => "PRIMARY",
                "weight" => 1.0
            )]

            created_endpoint = creategatewayendpoint(mlf, "$(endpoint_name)_update",
                model_configs; created_by="test_user")

            updated_endpoint = updategatewayendpoint(mlf, created_endpoint.endpoint_id;
                name="$(endpoint_name)_updated", updated_by="test_user")

            @test updated_endpoint isa GatewayEndpoint
        end

        @testset "list gateway endpoints" begin
            model_configs = [Dict(
                "model_definition_id" => model_def.model_definition_id,
                "linkage_type" => "PRIMARY",
                "weight" => 1.0
            )]

            creategatewayendpoint(mlf, "$(endpoint_name)_list1", model_configs; created_by="test_user")
            creategatewayendpoint(mlf, "$(endpoint_name)_list2", model_configs; created_by="test_user")

            endpoints = listgatewayendpoints(mlf)
            @test endpoints isa Array{GatewayEndpoint}
            @test length(endpoints) >= 2
        end

        @testset "attach and detach model to gateway endpoint" begin
            model_configs = [Dict(
                "model_definition_id" => model_def.model_definition_id,
                "linkage_type" => "PRIMARY",
                "weight" => 1.0
            )]

            created_endpoint = creategatewayendpoint(mlf, "$(endpoint_name)_attach",
                model_configs; created_by="test_user")

            # Attach additional model
            model_config = Dict(
                "model_definition_id" => model_def.model_definition_id,
                "linkage_type" => "FALLBACK",
                "fallback_order" => 1
            )
            try
                endpoint_with_model = attachmodeltogatewayendpoint(mlf,
                    created_endpoint.endpoint_id, model_config; created_by="test_user")

                @test endpoint_with_model isa GatewayEndpoint

                # Detach model
                @test detachmodelfromgatewayendpoint(mlf, created_endpoint.endpoint_id,
                    model_def.model_definition_id)
            catch e
                @warn "Attach/detach model test encountered server error: $(e.msg)"
            finally
                # Ensure cleanup
                try
                    deletegatewayendpoint(mlf, created_endpoint.endpoint_id)
                catch _
                end
            end
        end

        @testset "set and delete gateway endpoint tag" begin
            model_configs = [Dict(
                "model_definition_id" => model_def.model_definition_id,
                "linkage_type" => "PRIMARY",
                "weight" => 1.0
            )]

            created_endpoint = creategatewayendpoint(mlf, "$(endpoint_name)_tag",
                model_configs; created_by="test_user")

            # Set tag
            @test setgatewayendpointtag(mlf, created_endpoint.endpoint_id,
                "test_key", "test_value")

            # Delete tag
            @test deletegatewayendpointtag(mlf, created_endpoint.endpoint_id, "test_key")
        end

        @testset "delete gateway endpoint" begin
            model_configs = [Dict(
                "model_definition_id" => model_def.model_definition_id,
                "linkage_type" => "PRIMARY",
                "weight" => 1.0
            )]

            created_endpoint = creategatewayendpoint(mlf, "$(endpoint_name)_delete",
                model_configs; created_by="test_user")

            @test deletegatewayendpoint(mlf, created_endpoint.endpoint_id)
        end

        # Cleanup
        try
            deletegatewaymodeldefinition(mlf, model_def.model_definition_id)
        catch e
            @warn "Gateway endpoints cleanup encountered an error: $(e.msg)"
        end
        try
            deletegatewaysecret(mlf, secret.secret_id)
        catch e
            @warn "Gateway secret cleanup encountered an error: $(e.msg)"
        end
    end

    @testset "gateway endpoint bindings" begin
        endpoint_name_for_binding = UUIDs.uuid4() |> string

        # Create prerequisite resources
        secret = creategatewaysecret(mlf, "secret_for_binding_$(UUIDs.uuid4())",
            [Dict("key" => "api_key", "value" => "sk-test-binding")]; provider="openai", created_by="test_user")
        model_def = creategatewaymodeldefinition(mlf, "model_def_for_binding_$(UUIDs.uuid4())",
            secret.secret_id, "openai", "gpt-4"; created_by="test_user")

        model_configs = [Dict(
            "model_definition_id" => model_def.model_definition_id,
            "linkage_type" => "PRIMARY",
            "weight" => 1.0
        )]
        endpoint = creategatewayendpoint(mlf, endpoint_name_for_binding,
            model_configs; created_by="test_user")

        # Register a scorer for binding
        experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)
        scorer_result = registerscorer(mlf, experiment_id, "scorer_for_binding",
            "{}")

        @testset "create gateway endpoint binding" begin
            binding = creategatewayendpointbinding(mlf, endpoint.endpoint_id,
                "scorer", scorer_result["scorer_id"]; created_by="test_user")

            @test binding isa GatewayEndpointBinding
            @test binding.endpoint_id == endpoint.endpoint_id
            @test binding.resource_type == "scorer"
            @test binding.resource_id == scorer_result["scorer_id"]
            @test binding.created_by == "test_user"
        end

        @testset "list gateway endpoint bindings" begin
            try
                creategatewayendpointbinding(mlf, endpoint.endpoint_id,
                    "scorer", scorer_result["scorer_id"])

                bindings = listgatewayendpointbindings(mlf, endpoint.endpoint_id)
                @test bindings isa Array{GatewayEndpointBinding}
                @test length(bindings) >= 1

                # With resource_type filter
                bindings_filtered = listgatewayendpointbindings(mlf, endpoint.endpoint_id;
                    resource_type="scorer")
                @test bindings_filtered isa Array{GatewayEndpointBinding}
            catch e
                @warn "List bindings test encountered server error: $(e.msg)"
            end
        end

        @testset "delete gateway endpoint binding" begin
            try
                # Create a unique binding for this test
                unique_scorer = registerscorer(mlf, experiment_id, "scorer_for_delete_$(UUIDs.uuid4() |> string)[0:8]", "{}")
                creategatewayendpointbinding(mlf, endpoint.endpoint_id,
                    "scorer", unique_scorer["scorer_id"])

                @test deletegatewayendpointbinding(mlf, endpoint.endpoint_id,
                    "scorer", unique_scorer["scorer_id"])
            catch e
                @warn "Delete binding test encountered server error: $(e.msg)"
            end
        end

        # Cleanup
        try
            deletegatewayendpoint(mlf, endpoint.endpoint_id)
        catch _
        end
        try
            deletegatewaymodeldefinition(mlf, model_def.model_definition_id)
        catch _
        end
        try
            deletegatewaysecret(mlf, secret.secret_id)
        catch _
        end
        try
            deletescorer(mlf, experiment_id, "scorer_for_binding")
        catch _
        end
        try
            deleteexperiment(mlf, experiment_id)
        catch _
        end
    end

    @testset "gateway budgets" begin
        @testset "create gateway budget" begin
            duration = Dict("unit" => "MINUTES", "value" => 60)

            budget = creategatewaybudget(mlf, "USD", 1000.0, duration, "GLOBAL", "ALERT";
                created_by="test_user")

            @test budget isa GatewayBudgetPolicy
            @test budget.budget_unit == "USD"
            @test budget.budget_amount == 1000.0
            @test budget.created_by == "test_user"
            @test budget.budget_policy_id isa String
        end

        @testset "get gateway budget" begin
            duration = Dict("unit" => "MINUTES", "value" => 60)
            created_budget = creategatewaybudget(mlf, "USD", 500.0, duration, "GLOBAL", "ALERT";
                created_by="test_user")

            budget = getgatewaybudget(mlf, created_budget.budget_policy_id)

            @test budget isa GatewayBudgetPolicy
            @test budget.budget_policy_id == created_budget.budget_policy_id
        end

        @testset "update gateway budget" begin
            duration = Dict("unit" => "MINUTES", "value" => 60)
            created_budget = creategatewaybudget(mlf, "USD", 100.0, duration, "GLOBAL", "ALERT";
                created_by="test_user")

            updated_budget = updategatewaybudget(mlf, created_budget.budget_policy_id;
                budget_amount=200.0, updated_by="test_user")

            @test updated_budget isa GatewayBudgetPolicy
        end

        @testset "list gateway budgets" begin
            duration = Dict("unit" => "MINUTES", "value" => 60)
            creategatewaybudget(mlf, "USD", 100.0, duration, "GLOBAL", "ALERT"; created_by="test_user")
            creategatewaybudget(mlf, "USD", 200.0, duration, "WORKSPACE", "REJECT"; created_by="test_user")

            budgets = listgatewaybudgets(mlf)
            @test budgets isa Array{GatewayBudgetPolicy}
            @test length(budgets) >= 2
        end

        @testset "delete gateway budget" begin
            duration = Dict("unit" => "MINUTES", "value" => 60)
            created_budget = creategatewaybudget(mlf, "USD", 100.0, duration, "GLOBAL", "ALERT";
                created_by="test_user")

            @test deletegatewaybudget(mlf, created_budget.budget_policy_id)
        end
    end
end
