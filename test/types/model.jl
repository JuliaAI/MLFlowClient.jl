@testset verbose = true "model types" begin
    @testset "ModelInput from dict" begin
        data = Dict{String,Any}("model_id" => "model-abc")
        mi = ModelInput(data)
        @test mi.model_id == "model-abc"
    end

    @testset "ModelInput show" begin
        mi = ModelInput("m1")
        io = IOBuffer()
        show(io, mi)
        @test !isempty(String(take!(io)))
    end

    @testset "ModelMetric from dict" begin
        data = Dict{String,Any}("key" => "rmse", "value" => 0.15, "timestamp" => 123, "step" => 5)
        mm = ModelMetric(data)
        @test mm.key == "rmse"
        @test mm.value == 0.15
        @test mm.timestamp == 123
        @test mm.step == 5
    end

    @testset "ModelMetric without step" begin
        data = Dict{String,Any}("key" => "rmse", "value" => 0.15, "timestamp" => 123)
        mm = ModelMetric(data)
        @test isnothing(mm.step)
    end

    @testset "ModelMetric show" begin
        mm = ModelMetric("acc", 0.9, 123, 1)
        io = IOBuffer()
        show(io, mm)
        @test !isempty(String(take!(io)))
    end

    @testset "ModelOutput from dict" begin
        data = Dict{String,Any}("model_id" => "model-abc", "step" => 10)
        mo = ModelOutput(data)
        @test mo.model_id == "model-abc"
        @test mo.step == 10
    end

    @testset "ModelOutput show" begin
        mo = ModelOutput("m1", 1)
        io = IOBuffer()
        show(io, mo)
        @test !isempty(String(take!(io)))
    end

    @testset "ModelParam from dict" begin
        data = Dict{String,Any}("name" => "learning_rate", "value" => "0.001")
        mp = ModelParam(data)
        @test mp.name == "learning_rate"
        @test mp.value == "0.001"
    end

    @testset "ModelParam show" begin
        mp = ModelParam("lr", "0.01")
        io = IOBuffer()
        show(io, mp)
        @test !isempty(String(take!(io)))
    end

    @testset "ModelVersionDeploymentJobState from dict" begin
        data = Dict{String,Any}(
            "job_id" => "job-1",
            "run_id" => "run-1",
            "job_state" => "CONNECTED",
            "run_state" => "RUNNING",
            "current_task_name" => "deploy"
        )
        state = ModelVersionDeploymentJobState(data)
        @test state.job_id == "job-1"
        @test state.run_id == "run-1"
        @test state.job_state == State.CONNECTED
        @test state.run_state == DeploymentJobRunState.RUNNING
        @test state.current_task_name == "deploy"
    end

    @testset "ModelVersionDeploymentJobState defaults" begin
        state = ModelVersionDeploymentJobState(Dict{String,Any}())
        @test state.job_id == ""
        @test state.run_id == ""
        @test state.job_state == State.NOT_SET_UP
        @test state.run_state == DeploymentJobRunState.DEPLOYMENT_JOB_RUN_STATE_UNSPECIFIED
        @test state.current_task_name == ""
    end

    @testset "ModelVersionDeploymentJobState show" begin
        state = ModelVersionDeploymentJobState(Dict{String,Any}())
        io = IOBuffer()
        show(io, state)
        @test !isempty(String(take!(io)))
    end

    @testset "ModelVersion from dict" begin
        data = fixture_model_version(
            tags=[Dict{String,Any}("key" => "env", "value" => "prod")],
            model_id="logged-model-1"
        )
        mv = ModelVersion(data)
        @test mv.name == "test-model"
        @test mv.version == "1"
        @test mv.creation_timestamp == 1700000000000
        @test mv.last_updated_timestamp == 1700000000000
        @test isnothing(mv.user_id)
        @test mv.current_stage == "None"
        @test mv.description == ""
        @test mv.source == "s3://bucket/path"
        @test mv.run_id == "abc123"
        @test mv.status == ModelVersionStatus.READY
        @test isnothing(mv.status_message)
        @test length(mv.tags) == 1
        @test mv.tags[1].key == "env"
        @test isnothing(mv.run_link)
        @test isempty(mv.aliases)
        @test mv.model_id == "logged-model-1"
        @test isempty(mv.model_params)
        @test isempty(mv.model_metrics)
        @test isnothing(mv.deployment_job_state)
    end

    @testset "ModelVersion with deployment_job_state" begin
        data = fixture_model_version()
        data["deployment_job_state"] = Dict{String,Any}(
            "job_id" => "j1", "run_id" => "r1",
            "job_state" => "CONNECTED", "run_state" => "SUCCEEDED",
            "current_task_name" => "done"
        )
        mv = ModelVersion(data)
        @test mv.deployment_job_state isa ModelVersionDeploymentJobState
        @test mv.deployment_job_state.job_id == "j1"
    end

    @testset "ModelVersion with model_params and model_metrics" begin
        data = fixture_model_version()
        data["model_params"] = [Dict{String,Any}("name" => "lr", "value" => "0.01")]
        data["model_metrics"] = [Dict{String,Any}("key" => "acc", "value" => 0.95, "timestamp" => 123)]
        mv = ModelVersion(data)
        @test length(mv.model_params) == 1
        @test mv.model_params[1].name == "lr"
        @test length(mv.model_metrics) == 1
        @test mv.model_metrics[1].key == "acc"
    end

    @testset "ModelVersion show" begin
        data = fixture_model_version()
        mv = ModelVersion(data)
        io = IOBuffer()
        show(io, mv)
        @test !isempty(String(take!(io)))
    end
end
