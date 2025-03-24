defmodule FlashSyncE.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {FlashSyncE.Repo}
      # Starts a worker by calling: FlashSyncE.Worker.start_link(arg)
      # {FlashSyncE.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlashSyncE.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
