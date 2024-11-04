"""
    ModelVersionStatus

# Members
- `PENDING_REGISTRATION`: Request to register a new model version is pending as server
    performs background tasks.
- `FAILED_REGISTRATION`: Request to register a new model version has failed.
- `READY`: Model version is ready for use.
"""
@enum ModelVersionStatus begin
    PENDING_REGISTRATION=1
    FAILED_REGISTRATION=2
    READY=3
end
ModelVersionStatus(status::String) = Dict(value => key for (key, value) in ModelVersionStatus |> Base.Enums.namemap)[status |> Symbol] |> ModelVersionStatus

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
    RUNNING=1
    SCHEDULED=2
    FINISHED=3
    FAILED=4
    KILLED=5
end
RunStatus(status::String) = Dict(value => key for (key, value) in RunStatus |> Base.Enums.namemap)[status |> Symbol] |> RunStatus

"""
    ViewType

View type for ListExperiments query.

# Members
- `ACTIVE_ONLY`: Default. Return only active experiments.
- `DELETED_ONLY`: Return only deleted experiments.
- `ALL`: Get all experiments.
"""
@enum ViewType begin
    ACTIVE_ONLY=1
    DELETED_ONLY=2
    ALL=3
end
