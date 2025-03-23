defmodule FlashSyncE.ConflictResolver do
  def resolve_conflict(
        %{"version" => server_version} = server_record,
        %{"version" => client_version} = client_record
      )
      when is_integer(server_version) and is_integer(client_version) do
    if server_version >= client_version do
      {:conflict, server_record}
    else
      {:ok, client_record}
    end
  end
end
