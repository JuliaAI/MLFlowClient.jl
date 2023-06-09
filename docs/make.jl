using MLFlowClient
using Documenter

DocMeta.setdocmeta!(MLFlowClient, :DocTestSetup, :(using MLFlowClient); recursive=true)

makedocs(;
    modules=[MLFlowClient],
    authors="@deyandyankov and contributors",
    repo="https://github.com/JuliaAI.jl/blob/{commit}{path}#{line}",
    sitename="MLFlowClient.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://juliaai.github.io/MLFlowClient.jl",
        assets=String[]
    ),
    pages=[
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "Reference" => "reference.md"
    ]
)

deploydocs(;
    repo="github.com/JuliaAI/MLFlowClient.jl",
    devbranch="main"
)
