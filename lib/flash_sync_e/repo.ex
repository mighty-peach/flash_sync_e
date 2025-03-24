defmodule FlashSyncE.Repo do
  use Ecto.Repo,
    otp_app: :flash_sync_e,
    adapter: Ecto.Adapters.Postgres
end
