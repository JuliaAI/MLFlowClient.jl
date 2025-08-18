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
