@testset verbose = true "prompt optimization types" begin
    @testset "PromptOptimizationJobTag from dict" begin
        data = Dict{String,Any}("key" => "env", "value" => "prod")
        tag = PromptOptimizationJobTag(data)
        @test tag.key == "env"
        @test tag.value == "prod"
    end

    @testset "PromptOptimizationJobTag defaults" begin
        tag = PromptOptimizationJobTag(Dict{String,Any}())
        @test tag.key == ""
        @test tag.value == ""
    end

    @testset "PromptOptimizationJobTag direct constructor" begin
        tag = PromptOptimizationJobTag("key1", "value1")
        @test tag.key == "key1"
        @test tag.value == "value1"
    end

    @testset "PromptOptimizationJobConfig from dict" begin
        data = Dict{String,Any}(
            "optimizer_type" => "GEPA",
            "dataset_id" => "ds-123",
            "scorers" => ["Correctness", "Safety"],
            "optimizer_config_json" => """{"max_metric_calls": 100}"""
        )
        config = PromptOptimizationJobConfig(data)
        @test config.optimizer_type == "GEPA"
        @test config.dataset_id == "ds-123"
        @test config.scorers == ["Correctness", "Safety"]
        @test config.optimizer_config_json == """{"max_metric_calls": 100}"""
    end

    @testset "PromptOptimizationJobConfig defaults" begin
        config = PromptOptimizationJobConfig(Dict{String,Any}())
        @test config.optimizer_type == ""
        @test config.dataset_id == ""
        @test config.scorers == String[]
        @test config.optimizer_config_json == ""
    end

    @testset "InitialEvalScoresEntry from dict" begin
        data = Dict{String,Any}("scorer_name" => "Correctness", "score" => 0.85)
        entry = InitialEvalScoresEntry(data)
        @test entry.scorer_name == "Correctness"
        @test entry.score == 0.85
    end

    @testset "InitialEvalScoresEntry defaults" begin
        entry = InitialEvalScoresEntry(Dict{String,Any}())
        @test entry.scorer_name == ""
        @test entry.score == 0.0
    end

    @testset "FinalEvalScoresEntry from dict" begin
        data = Dict{String,Any}("scorer_name" => "Safety", "score" => 0.95)
        entry = FinalEvalScoresEntry(data)
        @test entry.scorer_name == "Safety"
        @test entry.score == 0.95
    end

    @testset "FinalEvalScoresEntry defaults" begin
        entry = FinalEvalScoresEntry(Dict{String,Any}())
        @test entry.scorer_name == ""
        @test entry.score == 0.0
    end

    @testset "JobStateInfo from dict" begin
        data = Dict{String,Any}("state" => "RUNNING", "message" => "In progress")
        state = JobStateInfo(data)
        @test state.state == "RUNNING"
        @test state.message == "In progress"
    end

    @testset "JobStateInfo defaults" begin
        state = JobStateInfo(Dict{String,Any}())
        @test state.state == ""
        @test state.message == ""
    end

    @testset "PromptOptimizationJob from dict" begin
        data = fixture_prompt_optimization_job(
            tags=[Dict{String,Any}("key" => "env", "value" => "test")],
            initial_eval_scores=[Dict{String,Any}("scorer_name" => "Correctness", "score" => 0.65)],
            final_eval_scores=[Dict{String,Any}("scorer_name" => "Correctness", "score" => 0.89)]
        )
        job = PromptOptimizationJob(data)
        @test job.job_id == "job-abc"
        @test job.run_id == "run-abc"
        @test job.state isa JobStateInfo
        @test job.state.state == "PENDING"
        @test job.experiment_id == "1"
        @test job.source_prompt_uri == "prompts:/test/1"
        @test job.optimized_prompt_uri == ""
        @test job.config isa PromptOptimizationJobConfig
        @test job.config.optimizer_type == "GEPA"
        @test job.config.dataset_id == "ds-1"
        @test job.creation_timestamp_ms == 1700000000000
        @test job.completion_timestamp_ms == 0
        @test length(job.tags) == 1
        @test job.tags[1].key == "env"
        @test length(job.initial_eval_scores) == 1
        @test job.initial_eval_scores[1].scorer_name == "Correctness"
        @test job.initial_eval_scores[1].score == 0.65
        @test length(job.final_eval_scores) == 1
        @test job.final_eval_scores[1].scorer_name == "Correctness"
        @test job.final_eval_scores[1].score == 0.89
    end

    @testset "PromptOptimizationJob defaults" begin
        job = PromptOptimizationJob(Dict{String,Any}())
        @test job.job_id == ""
        @test job.run_id == ""
        @test job.state isa JobStateInfo
        @test job.experiment_id == ""
        @test job.source_prompt_uri == ""
        @test job.optimized_prompt_uri == ""
        @test job.config isa PromptOptimizationJobConfig
        @test isempty(job.tags)
        @test isempty(job.initial_eval_scores)
        @test isempty(job.final_eval_scores)
    end
end
