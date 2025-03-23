defmodule FlashSyncE.WebSocket.Handler do
  @behaviour :cowboy_websocket

  # FIXME: add broadcast message handling

  require Logger

  # State struct to track connection data
  defmodule State do
    defstruct [:user_id, :device_id]
  end

  # Called when WebSocket connection is initiated
  @impl true
  def init(req, _opts) do
    Logger.info("WebSocket connection initiated")

    Logger.debug("Does req contains qs: #{inspect(Map.has_key?(req, :qs))}")

    # Extract query params for authentication
    qs = :cowboy_req.parse_qs(req)

    token =
      qs
      |> Enum.find(fn {k, _} -> k == "token" end)
      |> case do
        {"token", value} -> value
        _ -> nil
      end

    device_id =
      qs
      |> Enum.find(fn {k, _} -> k == "device_id" end)
      |> case do
        {"device_id", value} -> value
        _ -> nil
      end

    opts = %{
      idle_timeout: 60000,
      max_frame_size: 1_048_576
    }

    Logger.info("User token received")

    {:cowboy_websocket, req, %State{user_id: token, device_id: device_id}, opts}
  end

  # Called on WebSocket connection established
  @impl true
  def websocket_init(state) do
    Logger.info(
      "WebSocket connection established for user #{state.user_id}, device #{state.device_id}"
    )

    {:ok, state}
  end

  # Handle incoming WebSocket text frames
  @impl true
  def websocket_handle({:text, message}, state) do
    case Jason.decode(message) do
      {:ok, decoded} ->
        Logger.info("Received message: #{inspect(decoded)}, state: #{inspect(state)}")
        handle_message(decoded, state)

      {:error, _reason} ->
        {:reply, {:text, Jason.encode!(%{error: "Invalid JSON"})}, state}
    end
  end

  # Handle incoming WebSocket text frames
  @impl true
  def websocket_handle(_, state) do
    Logger.error("Invalid message")
    {:error, state}
  end

  @impl true
  def websocket_info({log}, state) do
    Logger.info("Received log message: #{inspect(log)}")
    {:ok, state}
  end

  @impl true
  def websocket_info(_, state) do
    {:ok, state}
  end

  # FIXME: instead of hardcoded results call function which handles work with sync data
  defp handle_message(%{"type" => "sync_changes", "data" => data}, state) do
    {:reply,
     {:text,
      Jason.encode!(%{
        type: "sync_response",
        status: "success",
        results: %{
          successful: [Enum.at(data, 0)],
          conflicts: []
        }
      })}, state}
  end

  defp handle_message(%{"type" => "ping"}, state) do
    {:reply, {:text, Jason.encode!(%{type: "pong"})}, state}
  end

  defp handle_message(%{"type" => unknown_type}, state) do
    {:reply, {:text, Jason.encode!(%{error: "Unknown message type: #{unknown_type}"})}, state}
  end
end
