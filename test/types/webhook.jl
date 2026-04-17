@testset verbose = true "webhook types" begin
    @testset "WebhookEvent from dict with string values" begin
        data = Dict{String,Any}("entity" => "REGISTERED_MODEL", "action" => "CREATED")
        event = WebhookEvent(data)
        @test event.entity == WebhookEntity.REGISTERED_MODEL
        @test event.action == WebhookAction.CREATED
    end

    @testset "WebhookEvent from dict with integer values" begin
        data = Dict{String,Any}("entity" => 1, "action" => 2)
        event = WebhookEvent(data)
        @test event.entity == WebhookEntity.REGISTERED_MODEL
        @test event.action == WebhookAction.UPDATED
    end

    @testset "WebhookEvent from dict with ENTITY_ prefix" begin
        data = Dict{String,Any}("entity" => "ENTITY_MODEL_VERSION", "action" => "ACTION_DELETED")
        event = WebhookEvent(data)
        @test event.entity == WebhookEntity.MODEL_VERSION
        @test event.action == WebhookAction.DELETED
    end

    @testset "WebhookEvent direct constructor" begin
        event = WebhookEvent(WebhookEntity.PROMPT, WebhookAction.SET)
        @test event.entity == WebhookEntity.PROMPT
        @test event.action == WebhookAction.SET
    end

    @testset "WebhookEvent show" begin
        event = WebhookEvent(WebhookEntity.REGISTERED_MODEL, WebhookAction.CREATED)
        io = IOBuffer()
        show(io, event)
        output = String(take!(io))
        @test !isempty(output)
    end

    @testset "WebhookTestResult from dict" begin
        data = Dict{String,Any}(
            "success" => true,
            "response_status" => 200,
            "response_body" => "OK"
        )
        result = WebhookTestResult(data)
        @test result.success == true
        @test result.response_status == 200
        @test result.response_body == "OK"
    end

    @testset "WebhookTestResult defaults" begin
        result = WebhookTestResult(Dict{String,Any}())
        @test result.success == false
        @test result.response_status == 0
        @test result.response_body == ""
    end

    @testset "WebhookTestResult show" begin
        result = WebhookTestResult(Dict{String,Any}("success" => true, "response_status" => 200, "response_body" => "OK"))
        io = IOBuffer()
        show(io, result)
        output = String(take!(io))
        @test !isempty(output)
    end

    @testset "Webhook from dict" begin
        data = fixture_webhook()
        webhook = Webhook(data)
        @test webhook.webhook_id == "wh-abc"
        @test webhook.name == "test-webhook"
        @test webhook.description == "A test webhook"
        @test webhook.url == "https://example.com/hook"
        @test length(webhook.events) == 1
        @test webhook.events[1].entity == WebhookEntity.REGISTERED_MODEL
        @test webhook.events[1].action == WebhookAction.CREATED
        @test webhook.status == WebhookStatus.ACTIVE
        @test webhook.creation_timestamp == 1700000000000
        @test webhook.last_updated_timestamp == 1700000000000
    end

    @testset "Webhook from dict with no status" begin
        data = fixture_webhook()
        delete!(data, "status")
        webhook = Webhook(data)
        @test webhook.status == WebhookStatus.ACTIVE  # default
    end

    @testset "Webhook from dict with no description" begin
        data = fixture_webhook()
        delete!(data, "description")
        webhook = Webhook(data)
        @test isnothing(webhook.description)
    end

    @testset "Webhook from dict with empty events" begin
        data = fixture_webhook(events=[])
        webhook = Webhook(data)
        @test isempty(webhook.events)
    end

    @testset "Webhook show" begin
        data = fixture_webhook()
        webhook = Webhook(data)
        io = IOBuffer()
        show(io, webhook)
        output = String(take!(io))
        @test !isempty(output)
    end
end
