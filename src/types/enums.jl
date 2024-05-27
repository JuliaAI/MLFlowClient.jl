"""
    ModelVersionStatus

# Members
- `PENDING_REGISTRATION`: Request to register a new model version is pending as
server performs background tasks.
- `FAILED_REGISTRATION`: Request to register a new model version has failed.
- `READY`: Model version is ready for use.
"""
@enum ModelVersionStatus begin
    PENDING_REGISTRATION
    FAILED_REGISTRATION
    READY
end

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
@enum RunStatus begin
    RUNNING
    SCHEDULED
    FINISHED
    FAILED
    KILLED
end

"""
    ViewType

View type for ListExperiments query.

# Members
- `ACTIVE_ONLY`: Default. Return only active experiments.
- `DELETED_ONLY`: Return only deleted experiments.
- `ALL`: Get all experiments.
"""
@enum ViewType begin
    ACTIVE_ONLY
    DELETED_ONLY
    ALL
end
