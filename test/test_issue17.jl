# Addresses https://github.com/JuliaAI/MLFlowClient.jl/issues/17
include("test_base.jl")

@testset "Issue17" begin
    @ensuremlf

    mlf_experiment = getorcreateexperiment(mlf, "issue17")
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