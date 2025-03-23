defmodule FlashSyncE.ConflictResolverTest do
  use ExUnit.Case

  alias FlashSyncE.ConflictResolver

  describe "resolve_conflict/2" do
    test "when client version is less than server version, returns server record with :conflict" do
      client_record = %{
        "id" => "card-123",
        "createdAt" => "2023-01-01T08:00:00Z",
        "updatedAt" => "2023-01-01T09:00:00Z",
        "lastSyncedAt" => "2023-01-01T08:30:00Z",
        "version" => 1
      }

      server_record = %{
        "id" => "card-123",
        "createdAt" => "2023-01-01T08:00:00Z",
        "updatedAt" => "2023-01-01T10:00:00Z",
        "lastSyncedAt" => "2023-01-01T10:00:00Z",
        "version" => 2
      }

      {status, result} = ConflictResolver.resolve_conflict(server_record, client_record)

      assert status == :conflict
      assert result == server_record
    end

    test "when client version is greater than server version, returns client record with :ok" do
      client_record = %{
        "id" => "card-123",
        "createdAt" => "2023-01-01T08:00:00Z",
        "updatedAt" => "2023-01-01T11:00:00Z",
        "lastSyncedAt" => "2023-01-01T08:30:00Z",
        "version" => 3
      }

      server_record = %{
        "id" => "card-123",
        "createdAt" => "2023-01-01T08:00:00Z",
        "updatedAt" => "2023-01-01T10:00:00Z",
        "lastSyncedAt" => "2023-01-01T10:00:00Z",
        "version" => 2
      }

      {status, result} = ConflictResolver.resolve_conflict(server_record, client_record)

      assert status == :ok
      assert result == client_record
    end

    test "when client version equals server version, returns server record with :conflict" do
      client_record = %{
        "id" => "card-123",
        "createdAt" => "2023-01-01T08:00:00Z",
        "updatedAt" => "2023-01-01T10:30:00Z",
        "lastSyncedAt" => "2023-01-01T08:30:00Z",
        "version" => 2
      }

      server_record = %{
        "id" => "card-123",
        "createdAt" => "2023-01-01T08:00:00Z",
        "updatedAt" => "2023-01-01T10:00:00Z",
        "lastSyncedAt" => "2023-01-01T10:00:00Z",
        "version" => 2
      }

      {status, result} = ConflictResolver.resolve_conflict(server_record, client_record)

      assert status == :conflict
      assert result == server_record
    end
  end
end
