@testset verbose = true "webhook service" begin
    @ensuremlf
    mlf === nothing && return nothing

    @testset "create webhook" begin
        # Note: Webhook creation requires HTTPS URLs and the server immediately
        # attempts delivery. Tests may fail if SSL verification issues occur.
        # Using httpbin.org which has valid SSL certs.
        webhook = createwebhook(mlf, "test_webhook", "https://httpbin.org/post";
            events=[WebhookEvent(WebhookEntity.REGISTERED_MODEL, WebhookAction.CREATED)],
            description="A test webhook",
            status=WebhookStatus.ACTIVE)

        @test webhook isa Webhook
        @test webhook.name == "test_webhook"
        @test webhook.url == "https://httpbin.org/post"

        deletewebhook(mlf, webhook.webhook_id)
    end

    @testset "get webhook" begin
        webhook = createwebhook(mlf, "test_get_webhook", "https://httpbin.org/post";
            events=[WebhookEvent(WebhookEntity.REGISTERED_MODEL, WebhookAction.CREATED)],
            description="Get test")

        retrieved_webhook = getwebhook(mlf, webhook.webhook_id)
        @test retrieved_webhook isa Webhook
        @test retrieved_webhook.webhook_id == webhook.webhook_id
        @test retrieved_webhook.name == "test_get_webhook"

        deletewebhook(mlf, webhook.webhook_id)
    end

    @testset "list webhooks" begin
        createwebhook(mlf, "list_webhook_1", "https://httpbin.org/post";
            events=[WebhookEvent(WebhookEntity.REGISTERED_MODEL, WebhookAction.CREATED)])
        createwebhook(mlf, "list_webhook_2", "https://httpbin.org/post";
            events=[WebhookEvent(WebhookEntity.REGISTERED_MODEL, WebhookAction.CREATED)])

        webhooks, next_page_token = listwebhooks(mlf)

        @test webhooks isa Array{Webhook}
        @test length(webhooks) >= 2

        # Clean up
        for webhook in webhooks
            if startswith(webhook.name, "list_webhook_")
                deletewebhook(mlf, webhook.webhook_id)
            end
        end
    end

    @testset "update webhook" begin
        webhook = createwebhook(mlf, "update_webhook", "https://httpbin.org/post";
            events=[WebhookEvent(WebhookEntity.REGISTERED_MODEL, WebhookAction.CREATED)],
            description="Original description")

        updated_webhook = updatewebhook(mlf, webhook.webhook_id;
            description="Updated description")

        @test updated_webhook isa Webhook
        @test updated_webhook.description == "Updated description"

        deletewebhook(mlf, webhook.webhook_id)
    end

    @testset "delete webhook" begin
        webhook = createwebhook(mlf, "delete_webhook", "https://httpbin.org/post";
            events=[WebhookEvent(WebhookEntity.REGISTERED_MODEL, WebhookAction.CREATED)])
        webhook_id = webhook.webhook_id

        @test deletewebhook(mlf, webhook_id)
        @test_throws ErrorException getwebhook(mlf, webhook_id)
    end
end
