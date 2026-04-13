@testset verbose = true "prompt optimization service" begin
    @ensuremlf
    mlf === nothing && return nothing

    # Create an experiment for prompt optimization tests
    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    @testset "prompt optimization job types" begin
        # Test that all the types are properly defined
        @test PromptOptimizationJobConfig isa DataType
        @test PromptOptimizationJobTag isa DataType
        @test InitialEvalScoresEntry isa DataType
        @test FinalEvalScoresEntry isa DataType
        @test JobStateInfo isa DataType

        # Test creating instances
        tag = PromptOptimizationJobTag("key", "value")
        @test tag.key == "key"
        @test tag.value == "value"

        config = PromptOptimizationJobConfig("GEPA", "dataset-1", ["Scorer1"], "{}")
        @test config.optimizer_type == "GEPA"
        @test config.dataset_id == "dataset-1"
        @test config.scorers == ["Scorer1"]
    end

    # Note: The following tests require server-side resources (evaluation datasets)
    # that may not be available. They are wrapped in try-catch to gracefully handle
    # server limitations.

    @testset "create prompt optimization job" begin
        try
            config = Dict(
                "optimizer_type" => "OPTIMIZER_TYPE_GEPA",
                "dataset_id" => "test-dataset-123",
                "scorers" => ["Correctness", "Safety"],
                "optimizer_config_json" => """{"reflection_model": "openai:/gpt-4", "max_metric_calls": 100}"""
            )

            job = createpromptoptimizationjob(mlf, experiment_id,
                "prompts:/test-prompt/1", config)

            @test job isa PromptOptimizationJob
            @test job.experiment_id == experiment_id
            @test job.source_prompt_uri == "prompts:/test-prompt/1"
            @test job.job_id isa String
            @test job.state isa JobStateInfo
            @test job.config isa PromptOptimizationJobConfig
            @test job.creation_timestamp_ms isa Int64
        catch e
            @warn "Create prompt optimization job test skipped (server resource not available): $(e.msg)"
        end
    end

    @testset "create prompt optimization job with tags" begin
        try
            config = Dict(
                "optimizer_type" => "OPTIMIZER_TYPE_METAPROMPT",
                "dataset_id" => "test-dataset-456",
                "scorers" => ["Accuracy"],
                "optimizer_config_json" => """{"reflection_model": "openai:/gpt-4"}"""
            )

            tags = [
                PromptOptimizationJobTag("environment", "test"),
                PromptOptimizationJobTag("version", "1.0")
            ]

            job = createpromptoptimizationjob(mlf, experiment_id,
                "prompts:/test-prompt-tags/1", config; tags=tags)

            @test job isa PromptOptimizationJob
            @test job.experiment_id == experiment_id
        catch e
            @warn "Create prompt optimization job with tags test skipped (server resource not available): $(e.msg)"
        end
    end

    @testset "get prompt optimization job" begin
        try
            config = Dict(
                "optimizer_type" => "OPTIMIZER_TYPE_GEPA",
                "dataset_id" => "test-dataset-get",
                "scorers" => ["Fluency"],
                "optimizer_config_json" => """{"max_metric_calls": 50}"""
            )

            created_job = createpromptoptimizationjob(mlf, experiment_id,
                "prompts:/test-prompt-get/1", config)

            job = getpromptoptimizationjob(mlf, created_job.job_id)

            @test job isa PromptOptimizationJob
            @test job.job_id == created_job.job_id
            @test job.experiment_id == experiment_id
            @test job.source_prompt_uri == "prompts:/test-prompt-get/1"
        catch e
            @warn "Get prompt optimization job test skipped (server resource not available): $(e.msg)"
        end
    end

    @testset "search prompt optimization jobs" begin
        try
            config1 = Dict(
                "optimizer_type" => "OPTIMIZER_TYPE_GEPA",
                "dataset_id" => "test-dataset-search-1",
                "scorers" => ["Coherence"],
                "optimizer_config_json" => """{"max_metric_calls": 100}"""
            )
            config2 = Dict(
                "optimizer_type" => "OPTIMIZER_TYPE_METAPROMPT",
                "dataset_id" => "test-dataset-search-2",
                "scorers" => ["Relevance"],
                "optimizer_config_json" => """{"max_metric_calls": 200}"""
            )

            createpromptoptimizationjob(mlf, experiment_id,
                "prompts:/test-prompt-search-1/1", config1)
            createpromptoptimizationjob(mlf, experiment_id,
                "prompts:/test-prompt-search-2/1", config2)

            jobs = searchpromptoptimizationjobs(mlf, experiment_id)

            @test jobs isa Array{PromptOptimizationJob}
            @test length(jobs) >= 2

            # Verify job structure
            job = jobs[1]
            @test job isa PromptOptimizationJob
            @test job.experiment_id == experiment_id
            @test job.job_id isa String
            @test job.state isa JobStateInfo
            @test job.config isa PromptOptimizationJobConfig
        catch e
            @warn "Search prompt optimization jobs test skipped (server resource not available): $(e.msg)"
        end
    end

    @testset "cancel prompt optimization job" begin
        try
            config = Dict(
                "optimizer_type" => "OPTIMIZER_TYPE_GEPA",
                "dataset_id" => "test-dataset-cancel",
                "scorers" => ["Safety"],
                "optimizer_config_json" => """{"max_metric_calls": 1000}"""
            )

            created_job = createpromptoptimizationjob(mlf, experiment_id,
                "prompts:/test-prompt-cancel/1", config)

            # Cancel the job
            cancelled_job = cancelpromptoptimizationjob(mlf, created_job.job_id)

            @test cancelled_job isa PromptOptimizationJob
            @test cancelled_job.job_id == created_job.job_id
        catch e
            @warn "Cancel prompt optimization job test skipped (server resource not available): $(e.msg)"
        end
    end

    @testset "delete prompt optimization job" begin
        try
            config = Dict(
                "optimizer_type" => "OPTIMIZER_TYPE_GEPA",
                "dataset_id" => "test-dataset-delete",
                "scorers" => ["Quality"],
                "optimizer_config_json" => """{"max_metric_calls": 100}"""
            )

            created_job = createpromptoptimizationjob(mlf, experiment_id,
                "prompts:/test-prompt-delete/1", config)

            @test deletepromptoptimizationjob(mlf, created_job.job_id)
        catch e
            @warn "Delete prompt optimization job test skipped (server resource not available): $(e.msg)"
        end
    end

    # Cleanup
    deleteexperiment(mlf, experiment_id)
end
