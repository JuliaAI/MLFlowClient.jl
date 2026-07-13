"""
    Manages a local MLflow server with the basic-auth app for the integration tests.

    The server runs in a temporary working directory, so its SQLite backend store and
    `basic_auth.db` are isolated per run and removed on teardown. MLflow itself is provided
    by the CondaPkg environment declared in the repository's `CondaPkg.toml`.
"""

using CondaPkg
using PythonCall
using Sockets
using HTTP

struct ManagedMLflowServer
    process::Base.Process
    workdir::String
    port::Int
    uri::String
end

function free_port()::Int
    port, server = Sockets.listenany(Sockets.localhost, 0)
    close(server)
    return Int(port)
end

"""
    start_mlflow_server(; port, timeout, enable_workspaces)

Launch `mlflow server --app-name basic-auth` and wait until it answers on `/health`.
The default admin credentials baked into MLflow's `basic_auth.ini` are `admin:password1234`,
which is what the integration tests authenticate with. Pass `enable_workspaces=true` to add
`--enable-workspaces` (needed only by the workspace tests; it changes experiment artifact
semantics, so the main server runs without it).
"""
function start_mlflow_server(; port::Int=free_port(), timeout::Real=180,
    enable_workspaces::Bool=false)
    mlflow_version = pyconvert(String, pyimport("mlflow").__version__)
    workdir = mktempdir()
    ENV["MLFLOW_FLASK_SERVER_SECRET_KEY"] = "mlflowclient.jl"

    args = ["mlflow", "server", "--app-name", "basic-auth",
        "--backend-store-uri", "sqlite:///mlflow.db",
        "--host", "127.0.0.1", "--port", string(port)]
    enable_workspaces && push!(args, "--enable-workspaces")

    process = CondaPkg.withenv() do
        run(pipeline(setenv(Cmd(args); dir=workdir);
            stdout=joinpath(workdir, "server.out"),
            stderr=joinpath(workdir, "server.err")); wait=false)
    end

    uri = "http://127.0.0.1:$(port)"
    @info "Starting managed MLflow server" mlflow_version port workdir
    wait_until_ready(process, uri, workdir, timeout)
    return ManagedMLflowServer(process, workdir, port, uri)
end

function wait_until_ready(process::Base.Process, uri::String, workdir::String, timeout::Real)
    deadline = time() + timeout
    while time() < deadline
        if !process_running(process)
            logfile = joinpath(workdir, "server.err")
            details = isfile(logfile) ? read(logfile, String) : ""
            error("MLflow server exited before becoming ready:\n$(details)")
        end
        try
            response = HTTP.get("$(uri)/health"; status_exception=false, retry=false,
                connect_timeout=2, readtimeout=2)
            response.status == 200 && return nothing
        catch
            # Server still starting up; keep polling until the deadline.
        end
        sleep(1)
    end
    error("MLflow server did not become ready within $(timeout)s")
end

function stop_mlflow_server(server::ManagedMLflowServer)
    process_running(server.process) && kill(server.process)
    try
        wait(server.process)
    catch
        # Process already terminated.
    end
    rm(server.workdir; recursive=true, force=true)
    delete!(ENV, "MLFLOW_FLASK_SERVER_SECRET_KEY")
    return nothing
end
