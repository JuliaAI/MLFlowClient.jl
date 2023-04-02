include("test_functional.jl")
include.(filter(contains(r"\.jl$"), readdir("./issues"; join=true)))
