"""
    get_py_attr(py_obj::Py, attr::Symbol, ::Type{T})

Safely extracts an attribute from a Python object, returning `nothing` if the attribute is missing, is Python `None`, or is an empty dictionary. Otherwise, converts it to the specified Julia type `T`.
"""
function get_py_attr(py_obj::Py, attr::Symbol, ::Type{T}) where {T}
    if !pyhasattr(py_obj, string(attr))
        return nothing
    end

    val = pygetattr(py_obj, string(attr))
    if PythonCall.Core.pyisnone(val)
        return nothing
    end

    if T <: Dict && PythonCall.pylen(val) == 0
        return nothing
    end

    return pyconvert(T, val)
end
