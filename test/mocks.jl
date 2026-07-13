"""
    Mock infrastructure for testing MLFlowClient without a running MLflow server.
    
    Provides mock HTTP responses for v2.0, v3.0, and mlflow-artifacts endpoints.
"""

# Store for mock responses keyed by (method, endpoint_pattern)
const MOCK_RESPONSES = Dict{Tuple{Symbol,String},Any}()

"""
    mock_response(method::Symbol, endpoint_pattern::String, response::Any)

Register a mock response for a given HTTP method and endpoint pattern.
"""
function mock_response(method::Symbol, endpoint_pattern::String, response::Any)
    MOCK_RESPONSES[(method, endpoint_pattern)] = response
end

"""
    clear_mocks()

Clear all registered mock responses.
"""
function clear_mocks()
    empty!(MOCK_RESPONSES)
end

"""
    find_mock(method::Symbol, uri_str::String)

Find a matching mock response for the given method and URI.
"""
function find_mock(method::Symbol, uri_str::String)
    for ((m, pattern), response) in MOCK_RESPONSES
        if m == method && occursin(pattern, uri_str)
            return response
        end
    end
    return nothing
end

# --- Mock MLFlow instance (no real server needed) ---

"""
    mock_mlf()

Create an MLFlow instance pointing to a fake server for unit testing.
"""
function mock_mlf()
    # Temporarily remove env var if set
    old_uri = get(ENV, "MLFLOW_TRACKING_URI", nothing)
    if haskey(ENV, "MLFLOW_TRACKING_URI")
        delete!(ENV, "MLFLOW_TRACKING_URI")
    end
    mlf = MLFlow("http://mock-server:5000/api")
    if !isnothing(old_uri)
        ENV["MLFLOW_TRACKING_URI"] = old_uri
    end
    return mlf
end

# --- Fixture data generators ---

function fixture_experiment(; experiment_id="1", name="test-experiment",
    artifact_location="mlflow-artifacts:/0", lifecycle_stage="active",
    last_update_time=1700000000000, creation_time=1700000000000, tags=[],
    workspace=nothing)
    d = Dict{String,Any}(
        "experiment_id" => experiment_id,
        "name" => name,
        "artifact_location" => artifact_location,
        "lifecycle_stage" => lifecycle_stage,
        "last_update_time" => last_update_time,
        "creation_time" => creation_time,
        "tags" => tags
    )
    !isnothing(workspace) && (d["workspace"] = workspace)
    return d
end

function fixture_run_info(; run_id="abc123", run_name="test-run", experiment_id="1",
    status="RUNNING", start_time=1700000000000, end_time=nothing,
    artifact_uri="mlflow-artifacts:/0/abc123/artifacts", lifecycle_stage="active")
    d = Dict{String,Any}(
        "run_id" => run_id,
        "run_name" => run_name,
        "experiment_id" => experiment_id,
        "status" => status,
        "start_time" => start_time,
        "artifact_uri" => artifact_uri,
        "lifecycle_stage" => lifecycle_stage
    )
    if !isnothing(end_time)
        d["end_time"] = end_time
    end
    return d
end

function fixture_run(; run_id="abc123", run_name="test-run", experiment_id="1",
    status="RUNNING", metrics=[], params=[], tags=[], dataset_inputs=[], model_inputs=[])
    Dict{String,Any}(
        "info" => fixture_run_info(run_id=run_id, run_name=run_name,
            experiment_id=experiment_id, status=status),
        "data" => Dict{String,Any}(
            "metrics" => metrics,
            "params" => params,
            "tags" => tags
        ),
        "inputs" => Dict{String,Any}(
            "dataset_inputs" => dataset_inputs,
            "model_inputs" => model_inputs
        )
    )
end

function fixture_registered_model(; name="test-model", creation_timestamp=1700000000000,
    last_updated_timestamp=1700000000000, user_id=nothing, description="A test model",
    latest_versions=[], tags=[], aliases=[])
    Dict{String,Any}(
        "name" => name,
        "creation_timestamp" => creation_timestamp,
        "last_updated_timestamp" => last_updated_timestamp,
        "user_id" => user_id,
        "description" => description,
        "latest_versions" => latest_versions,
        "tags" => tags,
        "aliases" => aliases
    )
end

function fixture_model_version(; name="test-model", version="1",
    creation_timestamp=1700000000000, last_updated_timestamp=1700000000000,
    user_id=nothing, current_stage="None", description="", source="s3://bucket/path",
    run_id="abc123", status="READY", status_message=nothing, tags=[], run_link=nothing,
    aliases=[], model_id=nothing)
    Dict{String,Any}(
        "name" => name,
        "version" => version,
        "creation_timestamp" => creation_timestamp,
        "last_updated_timestamp" => last_updated_timestamp,
        "user_id" => user_id,
        "current_stage" => current_stage,
        "description" => description,
        "source" => source,
        "run_id" => run_id,
        "status" => status,
        "status_message" => status_message,
        "tags" => tags,
        "run_link" => run_link,
        "aliases" => aliases,
        "model_id" => model_id
    )
end

function fixture_scorer(; experiment_id="1", name="test-scorer", version=1,
    scorer_id="scorer-abc", serialized_scorer="{}", creation_time=1700000000000)
    Dict{String,Any}(
        "experiment_id" => experiment_id,
        "name" => name,
        "version" => version,
        "scorer_id" => scorer_id,
        "serialized_scorer" => serialized_scorer,
        "creation_time" => creation_time
    )
end

function fixture_gateway_secret(; secret_id="secret-abc", secret_name="my-secret",
    provider="openai", created_by="user1", last_updated_by="user1",
    created_at=1700000000000, last_updated_at=1700000000000)
    Dict{String,Any}(
        "secret_id" => secret_id,
        "secret_name" => secret_name,
        "provider" => provider,
        "created_by" => created_by,
        "last_updated_by" => last_updated_by,
        "created_at" => created_at,
        "last_updated_at" => last_updated_at
    )
end

function fixture_gateway_model_definition(; model_definition_id="mdef-abc", name="gpt-4-def",
    secret_id="secret-abc", secret_name="probe-secret", provider="openai", model_name="gpt-4",
    created_by="user1", last_updated_by="user1",
    created_at=1700000000000, last_updated_at=1700000000000)
    Dict{String,Any}(
        "model_definition_id" => model_definition_id,
        "name" => name,
        "secret_id" => secret_id,
        "secret_name" => secret_name,
        "provider" => provider,
        "model_name" => model_name,
        "created_by" => created_by,
        "last_updated_by" => last_updated_by,
        "created_at" => created_at,
        "last_updated_at" => last_updated_at
    )
end

function fixture_gateway_endpoint(; endpoint_id="ep-abc", name="test-endpoint",
    model_mappings=[], routing_strategy="",
    created_by="user1", last_updated_by="user1",
    created_at=1700000000000, last_updated_at=1700000000000, tags=[],
    experiment_id="", usage_tracking=false)
    Dict{String,Any}(
        "endpoint_id" => endpoint_id,
        "name" => name,
        "model_mappings" => model_mappings,
        "routing_strategy" => routing_strategy,
        "created_by" => created_by,
        "last_updated_by" => last_updated_by,
        "created_at" => created_at,
        "last_updated_at" => last_updated_at,
        "tags" => tags,
        "experiment_id" => experiment_id,
        "usage_tracking" => usage_tracking
    )
end

function fixture_gateway_endpoint_binding(; endpoint_id="ep-abc", resource_type="scorer",
    resource_id="scorer-abc", created_by="user1", created_at=1700000000000)
    Dict{String,Any}(
        "endpoint_id" => endpoint_id,
        "resource_type" => resource_type,
        "resource_id" => resource_id,
        "created_by" => created_by,
        "created_at" => created_at
    )
end

function fixture_gateway_budget_policy(; budget_policy_id="bp-abc", budget_unit="USD",
    budget_amount=1000.0, duration=Dict("unit" => "HOURS", "value" => 1),
    target_scope="GLOBAL", budget_action="ALERT",
    created_by="user1", last_updated_by="user1",
    created_at=1700000000000, last_updated_at=1700000000000)
    Dict{String,Any}(
        "budget_policy_id" => budget_policy_id,
        "budget_unit" => budget_unit,
        "budget_amount" => budget_amount,
        "duration" => duration,
        "target_scope" => target_scope,
        "budget_action" => budget_action,
        "created_by" => created_by,
        "last_updated_by" => last_updated_by,
        "created_at" => created_at,
        "last_updated_at" => last_updated_at
    )
end

function fixture_gateway_budget_window(; budget_policy_id="bp-abc",
    window_start_ms=1700000000000, window_end_ms=1700003600000, current_spend=42.5)
    Dict{String,Any}(
        "budget_policy_id" => budget_policy_id,
        "window_start_ms" => window_start_ms,
        "window_end_ms" => window_end_ms,
        "current_spend" => current_spend
    )
end

function fixture_gateway_guardrail(; guardrail_id="guard-abc", name="test-guardrail",
    scorer=nothing, stage="BEFORE", action="VALIDATION", action_endpoint_id="",
    created_by="user1", created_at=1700000000000, last_updated_by="user1",
    last_updated_at=1700000000000)
    d = Dict{String,Any}(
        "guardrail_id" => guardrail_id,
        "name" => name,
        "stage" => stage,
        "action" => action,
        "action_endpoint_id" => action_endpoint_id,
        "created_by" => created_by,
        "created_at" => created_at,
        "last_updated_by" => last_updated_by,
        "last_updated_at" => last_updated_at
    )
    if !isnothing(scorer)
        d["scorer"] = scorer
    end
    return d
end

function fixture_gateway_guardrail_config(; endpoint_id="ep-abc", guardrail_id="guard-abc",
    execution_order=1, created_by="user1", created_at=1700000000000, guardrail=nothing)
    d = Dict{String,Any}(
        "endpoint_id" => endpoint_id,
        "guardrail_id" => guardrail_id,
        "execution_order" => execution_order,
        "created_by" => created_by,
        "created_at" => created_at
    )
    if !isnothing(guardrail)
        d["guardrail"] = guardrail
    end
    return d
end

function fixture_prompt_optimization_job(; job_id="job-abc", run_id="run-abc",
    state=Dict("state" => "PENDING", "message" => ""), experiment_id="1",
    source_prompt_uri="prompts:/test/1", optimized_prompt_uri="",
    config=Dict("optimizer_type" => "GEPA", "dataset_id" => "ds-1",
        "scorers" => ["Correctness"], "optimizer_config_json" => "{}"),
    creation_timestamp_ms=1700000000000, completion_timestamp_ms=0,
    tags=[], initial_eval_scores=[], final_eval_scores=[])
    Dict{String,Any}(
        "job_id" => job_id,
        "run_id" => run_id,
        "state" => state,
        "experiment_id" => experiment_id,
        "source_prompt_uri" => source_prompt_uri,
        "optimized_prompt_uri" => optimized_prompt_uri,
        "config" => config,
        "creation_timestamp_ms" => creation_timestamp_ms,
        "completion_timestamp_ms" => completion_timestamp_ms,
        "tags" => tags,
        "initial_eval_scores" => initial_eval_scores,
        "final_eval_scores" => final_eval_scores
    )
end

function fixture_webhook(; webhook_id="wh-abc", name="test-webhook",
    description="A test webhook", url="https://example.com/hook",
    events=[Dict("entity" => "REGISTERED_MODEL", "action" => "CREATED")],
    status="ACTIVE", creation_timestamp=1700000000000,
    last_updated_timestamp=1700000000000)
    Dict{String,Any}(
        "webhook_id" => webhook_id,
        "name" => name,
        "description" => description,
        "url" => url,
        "events" => events,
        "status" => status,
        "creation_timestamp" => creation_timestamp,
        "last_updated_timestamp" => last_updated_timestamp
    )
end

function fixture_user(; id="1", username="testuser", is_admin=false)
    Dict{String,Any}(
        "id" => id,
        "username" => username,
        "is_admin" => is_admin
    )
end

function fixture_role_permission(; id=1, role_id=1, resource_type="experiment",
    resource_pattern="1", permission="MANAGE")
    Dict{String,Any}(
        "id" => id,
        "role_id" => role_id,
        "resource_type" => resource_type,
        "resource_pattern" => resource_pattern,
        "permission" => permission
    )
end

function fixture_role(; id=1, name="test-role", workspace="default", description=nothing,
    permissions=[])
    Dict{String,Any}(
        "id" => id,
        "name" => name,
        "workspace" => workspace,
        "description" => description,
        "permissions" => permissions
    )
end

function fixture_user_role_assignment(; id=1, user_id="1", role_id=1)
    Dict{String,Any}(
        "id" => id,
        "user_id" => user_id,
        "role_id" => role_id
    )
end

function fixture_user_permission(; role_id=1, role_name="__user_1__", workspace="default",
    resource_type="experiment", resource_pattern="1", permission="MANAGE")
    Dict{String,Any}(
        "role_id" => role_id,
        "role_name" => role_name,
        "workspace" => workspace,
        "resource_type" => resource_type,
        "resource_pattern" => resource_pattern,
        "permission" => permission
    )
end

function fixture_trace_archival_config(; location=nothing, retention="30d")
    d = Dict{String,Any}()
    !isnothing(location) && (d["location"] = location)
    !isnothing(retention) && (d["retention"] = retention)
    return d
end

function fixture_workspace(; name="test-workspace", description="a test workspace",
    default_artifact_root=nothing, trace_archival_config=nothing)
    d = Dict{String,Any}("name" => name, "description" => description)
    !isnothing(default_artifact_root) && (d["default_artifact_root"] = default_artifact_root)
    !isnothing(trace_archival_config) && (d["trace_archival_config"] = trace_archival_config)
    return d
end

function fixture_label_schema(; schema_id="ls-abc", experiment_id="1", name="quality",
    type="FEEDBACK", instruction="Rate the response", enable_comment=true,
    input=Dict("categorical" => Dict("options" => ["good", "bad"], "multi_select" => false)),
    created_by="user1", created_at=1700000000000, last_updated_at=1700000000000,
    is_default=false)
    d = Dict{String,Any}(
        "schema_id" => schema_id,
        "experiment_id" => experiment_id,
        "name" => name,
        "type" => type,
        "instruction" => instruction,
        "enable_comment" => enable_comment,
        "created_by" => created_by,
        "created_at" => created_at,
        "last_updated_at" => last_updated_at,
        "is_default" => is_default
    )
    !isnothing(input) && (d["input"] = input)
    return d
end

function fixture_review_queue(; queue_id="rq-abc", experiment_id="1", name="reviewer1",
    queue_type="USER", created_by="user1", creation_time_ms=1700000000000,
    last_update_time_ms=1700000000000, users=["reviewer1"], schema_ids=[])
    Dict{String,Any}(
        "queue_id" => queue_id,
        "experiment_id" => experiment_id,
        "name" => name,
        "queue_type" => queue_type,
        "created_by" => created_by,
        "creation_time_ms" => creation_time_ms,
        "last_update_time_ms" => last_update_time_ms,
        "users" => users,
        "schema_ids" => schema_ids
    )
end

function fixture_review_queue_item(; queue_id="rq-abc", item_type="TRACE", item_id="tr-1",
    status="PENDING", completed_by="", completed_time_ms=0,
    creation_time_ms=1700000000000, last_update_time_ms=1700000000000)
    Dict{String,Any}(
        "queue_id" => queue_id,
        "item_type" => item_type,
        "item_id" => item_id,
        "status" => status,
        "completed_by" => completed_by,
        "completed_time_ms" => completed_time_ms,
        "creation_time_ms" => creation_time_ms,
        "last_update_time_ms" => last_update_time_ms
    )
end
