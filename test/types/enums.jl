@testset verbose = true "enum parsing" begin
    @testset "RunStatus" begin
        @test RunStatus.parse("RUNNING") == RunStatus.RUNNING
        @test RunStatus.parse("SCHEDULED") == RunStatus.SCHEDULED
        @test RunStatus.parse("FINISHED") == RunStatus.FINISHED
        @test RunStatus.parse("FAILED") == RunStatus.FAILED
        @test RunStatus.parse("KILLED") == RunStatus.KILLED
    end

    @testset "ModelVersionStatus" begin
        @test ModelVersionStatus.parse("PENDING_REGISTRATION") == ModelVersionStatus.PENDING_REGISTRATION
        @test ModelVersionStatus.parse("FAILED_REGISTRATION") == ModelVersionStatus.FAILED_REGISTRATION
        @test ModelVersionStatus.parse("READY") == ModelVersionStatus.READY
    end

    @testset "Permission" begin
        @test Permission.parse("READ") == Permission.READ
        @test Permission.parse("EDIT") == Permission.EDIT
        @test Permission.parse("MANAGE") == Permission.MANAGE
        @test Permission.parse("NO_PERMISSIONS") == Permission.NO_PERMISSIONS
    end

    @testset "DeploymentJobRunState" begin
        @test DeploymentJobRunState.parse("DEPLOYMENT_JOB_RUN_STATE_UNSPECIFIED") == DeploymentJobRunState.DEPLOYMENT_JOB_RUN_STATE_UNSPECIFIED
        @test DeploymentJobRunState.parse("NO_VALID_DEPLOYMENT_JOB_FOUND") == DeploymentJobRunState.NO_VALID_DEPLOYMENT_JOB_FOUND
        @test DeploymentJobRunState.parse("RUNNING") == DeploymentJobRunState.RUNNING
        @test DeploymentJobRunState.parse("SUCCEEDED") == DeploymentJobRunState.SUCCEEDED
        @test DeploymentJobRunState.parse("FAILED") == DeploymentJobRunState.FAILED
        @test DeploymentJobRunState.parse("PENDING") == DeploymentJobRunState.PENDING
        @test DeploymentJobRunState.parse("APPROVAL") == DeploymentJobRunState.APPROVAL
    end

    @testset "State" begin
        @test State.parse("DEPLOYMENT_JOB_CONNECTION_STATE_UNSPECIFIED") == State.DEPLOYMENT_JOB_CONNECTION_STATE_UNSPECIFIED
        @test State.parse("NOT_SET_UP") == State.NOT_SET_UP
        @test State.parse("CONNECTED") == State.CONNECTED
        @test State.parse("NOT_FOUND") == State.NOT_FOUND
        @test State.parse("REQUIRED_PARAMETERS_CHANGED") == State.REQUIRED_PARAMETERS_CHANGED
    end

    @testset "JobState" begin
        @test JobState.parse("PENDING") == JobState.PENDING
        @test JobState.parse("RUNNING") == JobState.RUNNING
        @test JobState.parse("COMPLETED") == JobState.COMPLETED
        @test JobState.parse("FAILED") == JobState.FAILED
        @test JobState.parse("CANCELED") == JobState.CANCELED
    end

    @testset "OptimizerType" begin
        @test OptimizerType.parse("GEPA") == OptimizerType.GEPA
        @test OptimizerType.parse("META_PROMPT") == OptimizerType.META_PROMPT
    end

    @testset "RoutingStrategy" begin
        @test RoutingStrategy.parse("ROUTING_STRATEGY_UNSPECIFIED") == RoutingStrategy.ROUTING_STRATEGY_UNSPECIFIED
        @test RoutingStrategy.parse("REQUEST_BASED_TRAFFIC_SPLIT") == RoutingStrategy.REQUEST_BASED_TRAFFIC_SPLIT
    end

    @testset "FallbackStrategy" begin
        @test FallbackStrategy.parse("FALLBACK_STRATEGY_UNSPECIFIED") == FallbackStrategy.FALLBACK_STRATEGY_UNSPECIFIED
        @test FallbackStrategy.parse("SEQUENTIAL") == FallbackStrategy.SEQUENTIAL
    end

    @testset "BudgetUnit" begin
        @test BudgetUnit.parse("BUDGET_UNIT_UNSPECIFIED") == BudgetUnit.BUDGET_UNIT_UNSPECIFIED
        @test BudgetUnit.parse("USD") == BudgetUnit.USD
    end

    @testset "BudgetDurationUnit" begin
        @test BudgetDurationUnit.parse("DURATION_UNIT_UNSPECIFIED") == BudgetDurationUnit.DURATION_UNIT_UNSPECIFIED
        @test BudgetDurationUnit.parse("MINUTES") == BudgetDurationUnit.MINUTES
        @test BudgetDurationUnit.parse("HOURS") == BudgetDurationUnit.HOURS
        @test BudgetDurationUnit.parse("DAYS") == BudgetDurationUnit.DAYS
        @test BudgetDurationUnit.parse("WEEKS") == BudgetDurationUnit.WEEKS
        @test BudgetDurationUnit.parse("MONTHS") == BudgetDurationUnit.MONTHS
    end

    @testset "BudgetTargetScope" begin
        @test BudgetTargetScope.parse("TARGET_SCOPE_UNSPECIFIED") == BudgetTargetScope.TARGET_SCOPE_UNSPECIFIED
        @test BudgetTargetScope.parse("GLOBAL") == BudgetTargetScope.GLOBAL
        @test BudgetTargetScope.parse("WORKSPACE") == BudgetTargetScope.WORKSPACE
    end

    @testset "BudgetAction" begin
        @test BudgetAction.parse("BUDGET_ACTION_UNSPECIFIED") == BudgetAction.BUDGET_ACTION_UNSPECIFIED
        @test BudgetAction.parse("ALERT") == BudgetAction.ALERT
        @test BudgetAction.parse("REJECT") == BudgetAction.REJECT
    end

    @testset "GatewayModelLinkageType" begin
        @test GatewayModelLinkageType.parse("LINKAGE_TYPE_UNSPECIFIED") == GatewayModelLinkageType.LINKAGE_TYPE_UNSPECIFIED
        @test GatewayModelLinkageType.parse("PRIMARY") == GatewayModelLinkageType.PRIMARY
        @test GatewayModelLinkageType.parse("FALLBACK") == GatewayModelLinkageType.FALLBACK
    end

    @testset "WebhookStatus" begin
        @test WebhookStatus.parse("ACTIVE") == WebhookStatus.ACTIVE
        @test WebhookStatus.parse("DISABLED") == WebhookStatus.DISABLED
    end

    @testset "WebhookEntity" begin
        @test WebhookEntity.parse("REGISTERED_MODEL") == WebhookEntity.REGISTERED_MODEL
        @test WebhookEntity.parse("MODEL_VERSION") == WebhookEntity.MODEL_VERSION
        @test WebhookEntity.parse("MODEL_VERSION_TAG") == WebhookEntity.MODEL_VERSION_TAG
        @test WebhookEntity.parse("MODEL_VERSION_ALIAS") == WebhookEntity.MODEL_VERSION_ALIAS
        @test WebhookEntity.parse("PROMPT") == WebhookEntity.PROMPT
        @test WebhookEntity.parse("PROMPT_VERSION") == WebhookEntity.PROMPT_VERSION
        @test WebhookEntity.parse("PROMPT_TAG") == WebhookEntity.PROMPT_TAG
        @test WebhookEntity.parse("PROMPT_VERSION_TAG") == WebhookEntity.PROMPT_VERSION_TAG
        @test WebhookEntity.parse("PROMPT_ALIAS") == WebhookEntity.PROMPT_ALIAS
        @test WebhookEntity.parse("BUDGET_POLICY") == WebhookEntity.BUDGET_POLICY
        # Test with ENTITY_ prefix stripping
        @test WebhookEntity.parse("ENTITY_REGISTERED_MODEL") == WebhookEntity.REGISTERED_MODEL
    end

    @testset "WebhookAction" begin
        @test WebhookAction.parse("CREATED") == WebhookAction.CREATED
        @test WebhookAction.parse("UPDATED") == WebhookAction.UPDATED
        @test WebhookAction.parse("DELETED") == WebhookAction.DELETED
        @test WebhookAction.parse("SET") == WebhookAction.SET
        @test WebhookAction.parse("EXCEEDED") == WebhookAction.EXCEEDED
        # Test with ACTION_ prefix stripping
        @test WebhookAction.parse("ACTION_CREATED") == WebhookAction.CREATED
    end

    @testset "ViewType enum values" begin
        @test Integer(ViewType.ACTIVE_ONLY) == 1
        @test Integer(ViewType.DELETED_ONLY) == 2
        @test Integer(ViewType.ALL) == 3
    end
end
