defmodule FlashSyncE.WebSocket.HandlerTest do
  use ExUnit.Case
  alias FlashSyncE.WebSocket.Handler

  describe "init/2" do
    test "upgrades connection to WebSocket for valid requests" do
      req = %{method: "GET", qs: "token=123&device_id=456"}

      result = Handler.init(req, [])

      assert {:cowboy_websocket, req_updated, state, _opts} = result
      assert req_updated == req
      assert state == %FlashSyncE.WebSocket.Handler.State{user_id: "123", device_id: "456"}
    end
  end

  describe "websocket_init/1" do
    test "initializes socket state" do
      state = %FlashSyncE.WebSocket.Handler.State{
        user_id: "123",
        device_id: "456"
      }

      {:ok, result} = Handler.websocket_init(state)

      assert is_map(result)
      assert Map.has_key?(result, :user_id)
      assert Map.has_key?(result, :device_id)
    end
  end

  describe "websocket_handle/2" do
    test "handles ping frame" do
      state = %{client_id: "test-client"}
      message = "{\"type\": \"ping\"}"

      {:reply, {:text, response}, state = response_state} =
        Handler.websocket_handle({:text, message}, state)

      response_data = Jason.decode!(response)
      assert response_data["type"] == "pong"
      assert state == response_state
    end

    test "handles client sync message with single piece of data" do
      state = %{client_id: "test-client"}

      message =
        Jason.encode!(%{
          "type" => "sync_changes",
          "data" => [
            %{
              "action" => "create",
              "id" => "card-123",
              "version" => 1,
              "createdAt" => "2023-01-01T10:00:00Z",
              "updatedAt" => nil,
              "lastSyncedAt" => nil
            }
          ]
        })

      {:reply, {:text, response}, state = response_state} =
        Handler.websocket_handle({:text, message}, state)

      response_data = Jason.decode!(response)
      assert response_data["type"] == "sync_response"
      assert state == response_state
    end

    # FIXME: add more complex tests
  end
end
