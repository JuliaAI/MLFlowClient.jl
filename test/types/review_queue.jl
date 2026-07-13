@testset verbose = true "review queue types" begin
    @testset "ReviewQueue from dict" begin
        queue = ReviewQueue(fixture_review_queue())
        @test queue.queue_id == "rq-abc"
        @test queue.experiment_id == "1"
        @test queue.name == "reviewer1"
        @test queue.queue_type == "USER"
        @test queue.created_by == "user1"
        @test queue.creation_time_ms == 1700000000000
        @test queue.last_update_time_ms == 1700000000000
        @test queue.users == ["reviewer1"]
        @test isempty(queue.schema_ids)
    end

    @testset "ReviewQueue defaults" begin
        queue = ReviewQueue(Dict{String,Any}())
        @test queue.queue_id == ""
        @test queue.experiment_id == ""
        @test queue.name == ""
        @test queue.queue_type == ""
        @test queue.created_by == ""
        @test queue.creation_time_ms == 0
        @test queue.last_update_time_ms == 0
        @test isempty(queue.users)
        @test isempty(queue.schema_ids)
    end

    @testset "ReviewQueue custom with schemas" begin
        queue = ReviewQueue(fixture_review_queue(queue_type="CUSTOM", name="triage",
            users=["a", "b"], schema_ids=["ls-1", "ls-2"]))
        @test queue.queue_type == "CUSTOM"
        @test queue.users == ["a", "b"]
        @test queue.schema_ids == ["ls-1", "ls-2"]
    end

    @testset "ReviewQueue with integer experiment_id" begin
        queue = ReviewQueue(fixture_review_queue(experiment_id=7))
        @test queue.experiment_id == "7"
    end

    @testset "ReviewQueueItem from dict" begin
        item = ReviewQueueItem(fixture_review_queue_item(status="COMPLETE",
            completed_by="user1", completed_time_ms=1700000001000))
        @test item.queue_id == "rq-abc"
        @test item.item_type == "TRACE"
        @test item.item_id == "tr-1"
        @test item.status == "COMPLETE"
        @test item.completed_by == "user1"
        @test item.completed_time_ms == 1700000001000
        @test item.creation_time_ms == 1700000000000
        @test item.last_update_time_ms == 1700000000000
    end

    @testset "ReviewQueueItem defaults" begin
        item = ReviewQueueItem(Dict{String,Any}())
        @test item.queue_id == ""
        @test item.item_type == ""
        @test item.item_id == ""
        @test item.status == ""
        @test item.completed_by == ""
        @test item.completed_time_ms == 0
        @test item.creation_time_ms == 0
        @test item.last_update_time_ms == 0
    end
end
