@testset verbose = true "mlflow bindings" begin
    @testset verbose = true "get or set tracking URI" begin
        original_uri = get_tracking_uri()

        @test original_uri isa String

        @testset "HTTP/HTTPS URIs" begin
            http_uri = "https://my-tracking-server:5000"

            @test set_tracking_uri(http_uri) === nothing
            @test get_tracking_uri() == http_uri
        end

        @testset "Local File URIs" begin
            file_uri = "file:///tmp/custom_mlruns"

            set_tracking_uri(file_uri)
            @test get_tracking_uri() == file_uri
        end

        @testset "Databricks URIs" begin
            db_uri_simple = "databricks"
            set_tracking_uri(db_uri_simple)
            @test get_tracking_uri() == db_uri_simple

            db_uri_profile = "databricks://my-dev-profile"
            set_tracking_uri(db_uri_profile)
            @test get_tracking_uri() == db_uri_profile
        end

        @testset "Empty String (Local fallback)" begin
            empty_uri = ""
            set_tracking_uri(empty_uri)
            @test get_tracking_uri() == empty_uri
        end

        set_tracking_uri(original_uri)
        @test get_tracking_uri() == original_uri
    end

    @testset verbose = true "set experiment" begin
        mktempdir() do tmpdir
            original_uri = get_tracking_uri()
            set_tracking_uri("file://$tmpdir")

            try
                created_exp_id = ""

                @testset "Set by Name (Creates new experiment)" begin
                    exp_name = "test_experiment_alpha"

                    julia_exp = set_experiment(experiment_name=exp_name)

                    @test julia_exp isa MLFlowClient.Experiment

                    @test julia_exp.name == exp_name
                    @test julia_exp.lifecycle_stage == "active"

                    created_exp_id = julia_exp.experiment_id
                    @test !isempty(created_exp_id)
                end

                @testset "Set by ID" begin
                    julia_exp = set_experiment(experiment_id=created_exp_id)

                    @test julia_exp isa MLFlowClient.Experiment
                    @test julia_exp.experiment_id == created_exp_id
                    @test julia_exp.name == "test_experiment_alpha"
                end

                @testset "Python Validation Exceptions" begin
                    @test_throws PythonCall.PyException set_experiment(
                        experiment_name="conflict_name",
                        experiment_id="conflict_id"
                    )

                    @test_throws PythonCall.PyException set_experiment()

                    @test_throws PythonCall.PyException set_experiment(
                        experiment_id="non_existent_id_999"
                    )
                end

            finally
                set_tracking_uri(original_uri)
            end
        end
    end

    @testset "start_run, active_run & end_run" begin
        set_experiment(experiment_name="run_management_test_env")

        if !(active_run() |> isnothing)
            end_run()
        end

        @testset "No active run" begin
            @test active_run() === nothing
        end

        @testset "start_run execution and mapping" begin
            test_tags = Dict{String,Any}("test_type" => "unit", "module" => "runs")
            test_desc = "Testing the start_run wrapper"

            run = start_run(
                run_name="julia_start_run_test",
                tags=test_tags,
                description=test_desc,
            )

            @test run isa MLFlowClient.ActiveRun

            @test run.run_info.run_name == "julia_start_run_test"
            @test run.run_info.status == MLFlowClient.RUNNING
            @test run.run_info.lifecycle_stage == MLFlowClient.ACTIVE
            @test run.run_info.run_id isa String
            @test (run.run_info.run_id |> length) > 0
        end

        @testset "active_run retrieval" begin
            current_run = active_run()

            @test !(current_run |> isnothing)
            @test current_run isa MLFlowClient.ActiveRun

            @test current_run.run_info.run_name == "julia_start_run_test"
            @test current_run.run_info.status == MLFlowClient.RUNNING

            end_run()
        end

        @testset "end_run standard termination" begin
            @test active_run() === nothing

            start_run(run_name="termination_test")
            @test !(active_run() |> isnothing)

            end_run()

            @test active_run() === nothing
        end

        @testset "end_run with custom status" begin
            @test active_run() === nothing

            start_run(run_name="failed_run_test")
            @test !(active_run() |> isnothing)

            end_run(status="FAILED")

            @test active_run() === nothing
        end
    end
end
