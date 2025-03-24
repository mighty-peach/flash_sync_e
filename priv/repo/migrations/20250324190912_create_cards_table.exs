defmodule FlashSyncE.Repo.Migrations.CreateCardsTable do
  use Ecto.Migration

  def change do
    create table(:cards, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :text, null: false
      add :translation, :text, null: false
      add :examples, {:array, :string}, null: true
      add :version, :integer, null: false, default: 1
      add :is_deleted, :boolean, null: false, default: false

      add :created_at, :utc_datetime, null: false
      add :updated_at, :utc_datetime, null: false
      add :last_synced_at, :utc_datetime, null: true
    end
  end
end
