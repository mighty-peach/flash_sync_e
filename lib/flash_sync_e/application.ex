defmodule FlashSyncE.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    Logger.info("Start the server...")

    children = [
      FlashSyncE.Repo,
      {
        Plug.Cowboy,
        scheme: :http,
        plug: FlashSyncE.Router,
        options: [
          port: 4000,
          dispatch: dispatch()
        ]
      }
    ]

    opts = [strategy: :one_for_one, name: FlashSyncE.Supervisor]
    Logger.info("Server listening http://localhost:4000")
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", FlashSyncE.WebSocket.Handler, []},
         {:_, Plug.Cowboy.Handler, {FlashSyncE.Router, []}}
       ]}
    ]
  end
end
