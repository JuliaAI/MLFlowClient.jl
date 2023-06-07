"""
    listexperiments(mlf::MLFlow)

Returns a list of MLFlow experiments.

Deprecated (last MLFlow version: 1.30.1) in favor of [`searchexperiments`](@ref).
"""

function listexperiments(mlf::MLFlow)
endpoint = "experiments/list"
    mlfget(mlf, endpoint)
end
