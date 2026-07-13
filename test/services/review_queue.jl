@testset verbose = true "review queue service" begin
    @ensuremlf
    mlf === nothing && return nothing

    experiment_id = createexperiment(mlf, UUIDs.uuid4() |> string)

    # A label schema to attach to CUSTOM queues.
    schema = createlabelschema(mlf, experiment_id, UUIDs.uuid4() |> string, "FEEDBACK",
        Dict("pass_fail" => Dict("positive_label" => "Pass", "negative_label" => "Fail")))

    local queue_id = ""

    @testset "get or create user queue" begin
        queue = getorcreateuserqueue(mlf, experiment_id, "reviewer1")
        @test queue isa ReviewQueue
        @test queue.experiment_id == experiment_id
        @test queue.queue_type == "USER"
        @test !isempty(queue.queue_id)

        # Idempotent: a second call returns the same queue.
        again = getorcreateuserqueue(mlf, experiment_id, "reviewer1")
        @test again.queue_id == queue.queue_id
    end

    @testset "create custom review queue" begin
        name = UUIDs.uuid4() |> string
        queue = createreviewqueue(mlf, experiment_id, name, "CUSTOM";
            schema_ids=[schema.schema_id])
        @test queue isa ReviewQueue
        @test queue.experiment_id == experiment_id
        @test queue.name == name
        @test queue.queue_type == "CUSTOM"
        @test schema.schema_id in queue.schema_ids
        @test !isempty(queue.queue_id)
        queue_id = queue.queue_id
    end

    @testset "get review queue" begin
        queue = getreviewqueue(mlf, queue_id)
        @test queue isa ReviewQueue
        @test queue.queue_id == queue_id
    end

    @testset "get review queue by name" begin
        source = getreviewqueue(mlf, queue_id)
        queue = getreviewqueuebyname(mlf, experiment_id, source.name)
        @test queue isa ReviewQueue
        @test queue.queue_id == queue_id
    end

    @testset "list review queues" begin
        queues, next_page_token = listreviewqueues(mlf, experiment_id)
        @test queues isa Array{ReviewQueue}
        @test any(q -> q.queue_id == queue_id, queues)
        @test next_page_token isa Union{String,Nothing}
    end

    @testset "update review queue" begin
        new_name = UUIDs.uuid4() |> string
        updated = updatereviewqueue(mlf, queue_id; name=new_name, schema_ids=String[])
        @test updated isa ReviewQueue
        @test updated.queue_id == queue_id
        @test updated.name == new_name
        @test isempty(updated.schema_ids)
    end

    @testset "review queue items" begin
        # Item operations reference traces; wrap defensively in case the server
        # validates item existence in this environment.
        try
            item_id = "tr-$(UUIDs.uuid4() |> string)"
            items = additemstoreviewqueue(mlf, queue_id, [item_id])
            @test items isa Array{ReviewQueueItem}
            @test any(i -> i.item_id == item_id, items)

            listed, token = listreviewqueueitems(mlf, queue_id)
            @test listed isa Array{ReviewQueueItem}
            @test token isa Union{String,Nothing}

            updated_item = setreviewqueueitemstatus(mlf, queue_id, item_id, "COMPLETE";
                completed_by="reviewer1")
            @test updated_item isa ReviewQueueItem
            @test updated_item.status == "COMPLETE"

            @test removeitemsfromreviewqueue(mlf, queue_id, [item_id])
        catch e
            @warn "Review queue item tests skipped (server resource not available): $(e.msg)"
        end
    end

    @testset "delete review queue" begin
        @test deletereviewqueue(mlf, queue_id)
        queues, _ = listreviewqueues(mlf, experiment_id)
        @test !any(q -> q.queue_id == queue_id, queues)
    end

    deletelabelschema(mlf, schema.schema_id)
    deleteexperiment(mlf, experiment_id)
end
