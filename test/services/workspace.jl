# Workspace management changes experiment artifact semantics, so it runs against a
# dedicated server started with `--enable-workspaces` rather than the shared one.
@testset verbose = true "workspace service" begin
    ws_server = start_mlflow_server(enable_workspaces=true)
    previous_uri = get(ENV, "MLFLOW_TRACKING_URI", nothing)
    ENV["MLFLOW_TRACKING_URI"] = ws_server.uri
    try
        encoded_credentials = Base64.base64encode("admin:password1234")
        mlf = MLFlow(headers=Dict("Authorization" => "Basic $(encoded_credentials)"))

        @testset "list workspaces" begin
            workspaces = listworkspaces(mlf)
            @test workspaces isa Array{Workspace}
            @test any(w -> w.name == "default", workspaces)
        end

        @testset "create, get, update, delete workspace" begin
            name = "ws-$(UUIDs.uuid4() |> string)"
            ws = createworkspace(mlf, name; description="created",
                trace_archival_config=Dict("retention" => "30d"))
            @test ws isa Workspace
            @test ws.name == name
            @test ws.description == "created"
            @test !isnothing(ws.trace_archival_config)
            @test ws.trace_archival_config.retention == "30d"

            fetched = getworkspace(mlf, name)
            @test fetched isa Workspace
            @test fetched.name == name

            updated = updateworkspace(mlf, name; description="updated")
            @test updated isa Workspace
            @test updated.description == "updated"

            @test deleteworkspace(mlf, name)
        end
    finally
        isnothing(previous_uri) ? delete!(ENV, "MLFLOW_TRACKING_URI") :
            (ENV["MLFLOW_TRACKING_URI"] = previous_uri)
        stop_mlflow_server(ws_server)
    end
end
