module ModelVersionStatus
    """
        ModelVersionStatus
    
    # Members
    - `PENDING_REGISTRATION`: Request to register a new model version is pending as server
        performs background tasks.
    - `FAILED_REGISTRATION`: Request to register a new model version has failed.
    - `READY`: Model version is ready for use.
    """
    @enum ModelVersionStatusEnum begin
        PENDING_REGISTRATION = 1
        FAILED_REGISTRATION = 2
        READY = 3
    end
    parse(status::String) = Dict(value => key for (key, value) in ModelVersionStatusEnum |> Base.Enums.namemap)[status|>Symbol] |> ModelVersionStatusEnum
end

module RunStatus
    """
        RunStatus
    
    Status of a run.
    
    # Members
    - `RUNNING`: Run has been initiated.
    - `SCHEDULED`: Run is scheduled to run at a later time.
    - `FINISHED`: Run has completed.
    - `FAILED`: Run execution failed.
    - `KILLED`: Run killed by user.
    """
    @enum RunStatusEnum begin
        RUNNING = 1
        SCHEDULED = 2
        FINISHED = 3
        FAILED = 4
        KILLED = 5
    end
    parse(status::String) = Dict(value => key for (key, value) in RunStatusEnum |> Base.Enums.namemap)[status|>Symbol] |> RunStatusEnum
end

module ViewType
    """
        ViewType
    
    View type for ListExperiments query.
    
    # Members
    - `ACTIVE_ONLY`: Default. Return only active experiments.
    - `DELETED_ONLY`: Return only deleted experiments.
    - `ALL`: Get all experiments.
    """
    @enum ViewTypeEnum begin
        ACTIVE_ONLY = 1
        DELETED_ONLY = 2
        ALL = 3
    end
end

module Permission
    """
        Permission
    
    Permission of a user to an experiment or a registered model.
    
    # Members
    - `READ`: Can read.
    - `EDIT`: Can read and update.
    - `MANAGE`: Can read, update, delete and manage.
    - `NO_PERMISSIONS`: No permissions.
    """
    @enum PermissionEnum begin
        READ = 1
        EDIT = 2
        MANAGE = 3
        NO_PERMISSIONS = 4
    end
    parse(permission::String) = Dict(value => key for (key, value) in PermissionEnum |> Base.Enums.namemap)[permission|>Symbol] |> PermissionEnum
end

module DeploymentJobRunState
    @enum DeploymentJobRunStateEnum begin
        DEPLOYMENT_JOB_RUN_STATE_UNSPECIFIED = 1
        NO_VALID_DEPLOYMENT_JOB_FOUND = 2
        RUNNING = 3
        SUCCEEDED = 4
        FAILED = 5
        PENDING = 6
        APPROVAL = 7
    end
    parse(state::String) = Dict(value => key for (key, value) in DeploymentJobRunStateEnum |> Base.Enums.namemap)[state|>Symbol] |> DeploymentJobRunStateEnum
end

module State
    """
        State

    # Members
    - `DEPLOYMENT_JOB_CONNECTION_STATE_UNSPECIFIED`
    - `NOT_SET_UP`: Default state.
    - `CONNECTED`: Connected job: job exists, owner has ACLs, and required job parameters are
        present.
    - `NOT_FOUND`: Job was deleted or owner had job ACLs removed.
    - `REQUIRED_PARAMETERS_CHANGED`: Required job parameters were changed.
    """
    @enum StateEnum begin
        DEPLOYMENT_JOB_CONNECTION_STATE_UNSPECIFIED = 1
        NOT_SET_UP = 2
        CONNECTED = 3
        NOT_FOUND = 4
        REQUIRED_PARAMETERS_CHANGED = 5
    end
    parse(state::String) = Dict(value => key for (key, value) in StateEnum |> Base.Enums.namemap)[state|>Symbol] |> StateEnum
end

module JobState
    """
        JobState

    State of a prompt optimization job.

    # Members
    - `PENDING`: Job is pending.
    - `RUNNING`: Job is running.
    - `COMPLETED`: Job has completed successfully.
    - `FAILED`: Job has failed.
    - `CANCELED`: Job has been canceled.
    """
    @enum JobStateEnum begin
        PENDING = 1
        RUNNING = 2
        COMPLETED = 3
        FAILED = 4
        CANCELED = 5
    end
    parse(state::String) = Dict(value => key for (key, value) in JobStateEnum |> Base.Enums.namemap)[state|>Symbol] |> JobStateEnum
end

module OptimizerType
    """
        OptimizerType

    Type of optimizer for prompt optimization.

    # Members
    - `GEPA`: GEPA optimizer.
    - `META_PROMPT`: Meta-prompt optimizer.
    """
    @enum OptimizerTypeEnum begin
        GEPA = 1
        META_PROMPT = 2
    end
    parse(optimizer_type::String) = Dict(value => key for (key, value) in OptimizerTypeEnum |> Base.Enums.namemap)[optimizer_type|>Symbol] |> OptimizerTypeEnum
end

module RoutingStrategy
    """
        RoutingStrategy

    Routing strategy for endpoints.

    # Members
    - `ROUTING_STRATEGY_UNSPECIFIED`: Unspecified.
    - `REQUEST_BASED_TRAFFIC_SPLIT`: Request-based traffic split: distributes traffic based on weights.
    """
    @enum RoutingStrategyEnum begin
        ROUTING_STRATEGY_UNSPECIFIED = 0
        REQUEST_BASED_TRAFFIC_SPLIT = 1
    end
    parse(strategy::String) = Dict(value => key for (key, value) in RoutingStrategyEnum |> Base.Enums.namemap)[Symbol(strategy)] |> RoutingStrategyEnum
end

module FallbackStrategy
    """
        FallbackStrategy

    Fallback strategy for routing.

    # Members
    - `FALLBACK_STRATEGY_UNSPECIFIED`: Unspecified.
    - `SEQUENTIAL`: Sequential fallback: tries models in the order specified.
    """
    @enum FallbackStrategyEnum begin
        FALLBACK_STRATEGY_UNSPECIFIED = 0
        SEQUENTIAL = 1
    end
    parse(strategy::String) = Dict(value => key for (key, value) in FallbackStrategyEnum |> Base.Enums.namemap)[Symbol(strategy)] |> FallbackStrategyEnum
end

module BudgetUnit
    """
        BudgetUnit

    Budget measurement unit.

    # Members
    - `BUDGET_UNIT_UNSPECIFIED`: Unspecified.
    - `USD`: US Dollars.
    """
    @enum BudgetUnitEnum begin
        BUDGET_UNIT_UNSPECIFIED = 0
        USD = 1
    end
    parse(unit::String) = Dict(value => key for (key, value) in BudgetUnitEnum |> Base.Enums.namemap)[Symbol(unit)] |> BudgetUnitEnum
end

module BudgetDurationUnit
    """
        BudgetDurationUnit

    Duration unit for budget policy fixed windows.

    # Members
    - `DURATION_UNIT_UNSPECIFIED`: Unspecified.
    - `MINUTES`: Minutes.
    - `HOURS`: Hours.
    - `DAYS`: Days.
    - `WEEKS`: Weeks.
    - `MONTHS`: Months.
    """
    @enum BudgetDurationUnitEnum begin
        DURATION_UNIT_UNSPECIFIED = 0
        MINUTES = 1
        HOURS = 2
        DAYS = 3
        WEEKS = 4
        MONTHS = 5
    end
    parse(unit::String) = Dict(value => key for (key, value) in BudgetDurationUnitEnum |> Base.Enums.namemap)[Symbol(unit)] |> BudgetDurationUnitEnum
end

module BudgetTargetScope
    """
        BudgetTargetScope

    Target scope for a budget policy.

    # Members
    - `TARGET_SCOPE_UNSPECIFIED`: Unspecified.
    - `GLOBAL`: Global scope.
    - `WORKSPACE`: Workspace scope.
    """
    @enum BudgetTargetScopeEnum begin
        TARGET_SCOPE_UNSPECIFIED = 0
        GLOBAL = 1
        WORKSPACE = 2
    end
    parse(scope::String) = Dict(value => key for (key, value) in BudgetTargetScopeEnum |> Base.Enums.namemap)[Symbol(scope)] |> BudgetTargetScopeEnum
end

module BudgetAction
    """
        BudgetAction

    Action to take when a budget is exceeded.

    # Members
    - `BUDGET_ACTION_UNSPECIFIED`: Unspecified.
    - `ALERT`: Send alert.
    - `REJECT`: Reject requests.
    """
    @enum BudgetActionEnum begin
        BUDGET_ACTION_UNSPECIFIED = 0
        ALERT = 1
        REJECT = 2
    end
    parse(action::String) = Dict(value => key for (key, value) in BudgetActionEnum |> Base.Enums.namemap)[Symbol(action)] |> BudgetActionEnum
end

module GatewayModelLinkageType
    """
        GatewayModelLinkageType

    Type of linkage between endpoint and model definition.

    # Members
    - `LINKAGE_TYPE_UNSPECIFIED`: Unspecified.
    - `PRIMARY`: Primary linkage: used for routing traffic.
    - `FALLBACK`: Fallback linkage: used for failover.
    """
    @enum GatewayModelLinkageTypeEnum begin
        LINKAGE_TYPE_UNSPECIFIED = 0
        PRIMARY = 1
        FALLBACK = 2
    end
    parse(linkage_type::String) = Dict(value => key for (key, value) in GatewayModelLinkageTypeEnum |> Base.Enums.namemap)[Symbol(linkage_type)] |> GatewayModelLinkageTypeEnum
end

module GuardrailStage
    """
        GuardrailStage

    Whether a guardrail runs before or after LLM invocation.

    # Members
    - `GUARDRAIL_STAGE_UNSPECIFIED`: Unspecified.
    - `BEFORE`: Runs before LLM invocation.
    - `AFTER`: Runs after LLM invocation.
    """
    @enum GuardrailStageEnum begin
        GUARDRAIL_STAGE_UNSPECIFIED = 0
        BEFORE = 1
        AFTER = 2
    end
    parse(stage::String) = Dict(value => key for (key, value) in GuardrailStageEnum |> Base.Enums.namemap)[Symbol(stage)] |> GuardrailStageEnum
end

module GuardrailAction
    """
        GuardrailAction

    Whether a guardrail blocks or modifies the request/response.

    # Members
    - `GUARDRAIL_ACTION_UNSPECIFIED`: Unspecified.
    - `VALIDATION`: Validates and may block the request/response.
    - `SANITIZATION`: Modifies the request/response.
    """
    @enum GuardrailActionEnum begin
        GUARDRAIL_ACTION_UNSPECIFIED = 0
        VALIDATION = 1
        SANITIZATION = 2
    end
    parse(action::String) = Dict(value => key for (key, value) in GuardrailActionEnum |> Base.Enums.namemap)[Symbol(action)] |> GuardrailActionEnum
end

module LabelSchemaType
    """
        LabelSchemaType

    Type of a label schema.

    # Members
    - `LABEL_SCHEMA_TYPE_UNSPECIFIED`: Unspecified.
    - `FEEDBACK`: Feedback schema with a bounded value space (pass/fail, options, min/max).
    - `EXPECTATION`: Expectation schema, typically ground-truth labels supplied by reviewers.
    """
    @enum LabelSchemaTypeEnum begin
        LABEL_SCHEMA_TYPE_UNSPECIFIED = 0
        FEEDBACK = 1
        EXPECTATION = 2
    end
    parse(type::String) = Dict(value => key for (key, value) in LabelSchemaTypeEnum |> Base.Enums.namemap)[Symbol(type)] |> LabelSchemaTypeEnum
end

module ReviewItemType
    """
        ReviewItemType

    What kind of object a review queue item points at.

    # Members
    - `REVIEW_ITEM_TYPE_UNSPECIFIED`: Unspecified.
    - `TRACE`: The item references a trace.
    """
    @enum ReviewItemTypeEnum begin
        REVIEW_ITEM_TYPE_UNSPECIFIED = 0
        TRACE = 1
    end
    parse(item_type::String) = Dict(value => key for (key, value) in ReviewItemTypeEnum |> Base.Enums.namemap)[Symbol(item_type)] |> ReviewItemTypeEnum
end

module ReviewQueueType
    """
        ReviewQueueType

    The flavor of a review queue.

    # Members
    - `REVIEW_QUEUE_TYPE_UNSPECIFIED`: Unspecified.
    - `USER`: A single reviewer's personal worklist (name equals the user, all schemas).
    - `CUSTOM`: A curated, possibly collaborative task (arbitrary name, users, schema subset).
    """
    @enum ReviewQueueTypeEnum begin
        REVIEW_QUEUE_TYPE_UNSPECIFIED = 0
        USER = 1
        CUSTOM = 2
    end
    parse(queue_type::String) = Dict(value => key for (key, value) in ReviewQueueTypeEnum |> Base.Enums.namemap)[Symbol(queue_type)] |> ReviewQueueTypeEnum
end

module ReviewStatus
    """
        ReviewStatus

    Shared-pool workflow status of a single review queue item.

    # Members
    - `REVIEW_STATUS_UNSPECIFIED`: Unspecified.
    - `PENDING`: The item is awaiting review.
    - `COMPLETE`: The item has been reviewed.
    - `DECLINED`: The item has been declined.
    """
    @enum ReviewStatusEnum begin
        REVIEW_STATUS_UNSPECIFIED = 0
        PENDING = 1
        COMPLETE = 2
        DECLINED = 3
    end
    parse(status::String) = Dict(value => key for (key, value) in ReviewStatusEnum |> Base.Enums.namemap)[Symbol(status)] |> ReviewStatusEnum
end
