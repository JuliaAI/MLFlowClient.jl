@testset verbose = true "API error paths" begin
    @ensuremlf

    @testset "mlfget error path" begin
        # Trigger an error by requesting a nonexistent experiment
        @test_throws ErrorException MLFlowClient.mlfget(mlf, "experiments/get";
            experiment_id="99999999")
    end

    @testset "mlfpost error path" begin
        # Trigger an error by creating a run with invalid experiment
        @test_throws ErrorException MLFlowClient.mlfpost(mlf, "runs/create";
            experiment_id="99999999")
    end

    @testset "mlfpatch error path" begin
        # Trigger an error by updating a nonexistent registered model
        @test_throws ErrorException MLFlowClient.mlfpatch(mlf,
            "registered-models/update"; name="nonexistent-model-99999")
    end

    @testset "mlfdelete error path" begin
        # Trigger an error by deleting a nonexistent registered model
        @test_throws ErrorException MLFlowClient.mlfdelete(mlf,
            "registered-models/delete"; name="nonexistent-model-99999")
    end

    @testset "mlfget_v3 error path" begin
        # Trigger an error by getting a nonexistent scorer
        @test_throws ErrorException MLFlowClient.mlfget_v3(mlf, "scorers/get";
            experiment_id="0", name="nonexistent-scorer-99999")
    end

    @testset "mlfpost_v3 error path" begin
        # Trigger an error by registering a scorer with missing required fields
        @test_throws ErrorException MLFlowClient.mlfpost_v3(mlf, "scorers/register";
            experiment_id="99999999", name="test", serialized_scorer="{}")
    end

    @testset "mlfdelete_v3 error path" begin
        # Trigger an error by deleting a nonexistent scorer
        @test_throws ErrorException MLFlowClient.mlfdelete_v3(mlf, "scorers/delete";
            experiment_id="0", name="nonexistent-scorer-99999")
    end
end
