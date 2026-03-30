@enum RunStatus begin
    RUNNING
    SCHEDULED
    FINISHED
    FAILED
    KILLED
end

@enum LifecycleStage begin
    ACTIVE
    DELETED
end

"""
    Base.parse(::Type{T}, s::String) where {T<:Enum}

Parses a string into an instance of the specified enum type `T`. The parsing is case-insensitive. If the string does not match any instance of the enum, an `ArgumentError` is thrown.
"""
function Base.parse(::Type{T}, s::String) where {T<:Enum}
    s_upper = s |> uppercase
    for inst in (T |> instances)
        if (inst |> string) == s_upper
            return inst
        end
    end
    throw(ArgumentError("Cannot parse string '$s' as $(T)"))
end
