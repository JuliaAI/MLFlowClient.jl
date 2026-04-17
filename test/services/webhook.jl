@testset verbose = true "webhook service" begin
    @ensuremlf
    mlf === nothing && return nothing

    # Helper: valid event for all webhook tests
    valid_event = WebhookEvent(WebhookEntity.REGISTERED_MODEL, WebhookAction.CREATED)

    @testset "create webhook with all options" begin
        webhook = createwebhook(mlf, "test_full_webhook", "https://httpbin.org/post";
            events=[valid_event],
            description="A full test webhook",
            status=WebhookStatus.ACTIVE,
            secret="my-secret-key")

        @test webhook isa Webhook
        @test webhook.name == "test_full_webhook"
        @test webhook.url == "https://httpbin.org/post"
        @test webhook.description == "A full test webhook"
        @test webhook.status == WebhookStatus.ACTIVE
        @test !isempty(webhook.events)

        deletewebhook(mlf, webhook.webhook_id)
    end

    @testset "create webhook minimal" begin
        webhook = createwebhook(mlf, "test_minimal_webhook", "https://httpbin.org/post";
            events=[valid_event])

        @test webhook isa Webhook
        @test webhook.name == "test_minimal_webhook"

        deletewebhook(mlf, webhook.webhook_id)
    end

    @testset "get webhook" begin
        webhook = createwebhook(mlf, "test_get_webhook", "https://httpbin.org/post";
            events=[valid_event], description="Get test")

        retrieved = getwebhook(mlf, webhook.webhook_id)
        @test retrieved isa Webhook
        @test retrieved.webhook_id == webhook.webhook_id
        @test retrieved.name == "test_get_webhook"
        @test retrieved.description == "Get test"

        deletewebhook(mlf, webhook.webhook_id)
    end

    @testset "get webhook not found" begin
        @test_throws ErrorException getwebhook(mlf, "nonexistent-webhook-id")
    end

    @testset "list webhooks" begin
        w1 = createwebhook(mlf, "list_webhook_1", "https://httpbin.org/post";
            events=[valid_event])
        w2 = createwebhook(mlf, "list_webhook_2", "https://httpbin.org/post";
            events=[valid_event])

        webhooks, next_page_token = listwebhooks(mlf)
        @test webhooks isa Array{Webhook}
        @test length(webhooks) >= 2

        deletewebhook(mlf, w1.webhook_id)
        deletewebhook(mlf, w2.webhook_id)
    end

    @testset "list webhooks with pagination" begin
        created_ids = String[]
        for i in 1:3
            w = createwebhook(mlf, "page_webhook_$i", "https://httpbin.org/post";
                events=[valid_event])
            push!(created_ids, w.webhook_id)
        end

        webhooks, next_page_token = listwebhooks(mlf; max_results=1)
        @test length(webhooks) == 1
        @test next_page_token |> !isnothing

        for id in created_ids
            deletewebhook(mlf, id)
        end
    end

    @testset "update webhook with all options" begin
        webhook = createwebhook(mlf, "update_webhook", "https://httpbin.org/post";
            events=[valid_event], description="Original")

        updated = updatewebhook(mlf, webhook.webhook_id;
            name="updated_webhook",
            description="Updated description",
            url="https://httpbin.org/anything",
            status=WebhookStatus.DISABLED,
            secret="new-secret")

        @test updated isa Webhook
        @test updated.name == "updated_webhook"
        @test updated.description == "Updated description"
        @test updated.url == "https://httpbin.org/anything"
        @test updated.status == WebhookStatus.DISABLED

        deletewebhook(mlf, webhook.webhook_id)
    end

    @testset "delete webhook" begin
        webhook = createwebhook(mlf, "delete_webhook", "https://httpbin.org/post";
            events=[valid_event])
        webhook_id = webhook.webhook_id

        @test deletewebhook(mlf, webhook_id)
        @test_throws ErrorException getwebhook(mlf, webhook_id)
    end

    @testset "test webhook" begin
        webhook = createwebhook(mlf, "testable_webhook", "https://httpbin.org/post";
            events=[valid_event])

        result = testwebhook(mlf, webhook.webhook_id)
        @test result isa WebhookTestResult
        @test result.success isa Bool
        @test result.response_status isa Int

        deletewebhook(mlf, webhook.webhook_id)
    end

    @testset "test webhook with event" begin
        webhook = createwebhook(mlf, "testable_event_webhook", "https://httpbin.org/post";
            events=[valid_event])

        result = testwebhook(mlf, webhook.webhook_id; event=valid_event)
        @test result isa WebhookTestResult

        deletewebhook(mlf, webhook.webhook_id)
    end
end
