# Addresses https://github.com/JuliaAI/MLFlowClient.jl/issues/20
include("../test_base.jl")

@testset "Issue20" begin
    @ensuremlf

    mlf_experiment = getorcreateexperiment(mlf, "issue20")
    mlf_run = createrun(
        mlf,
        mlf_experiment,
        tags=[
            Dict(
                "key" => "mlflow.runName",
                "value" => "run_name"
            )
        ]
    )
    @test isa(mlf_run, MLFlowRun)
end
