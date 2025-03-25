defmodule FlashSyncE.Domain.CardModel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cards" do
    field(:text, :string)
    field(:translation, :string)
    field(:examples, {:array, :string})
    field(:version, :integer, default: 1)
    field(:is_deleted, :boolean, default: false)

    field(:created_at, :utc_datetime)
    field(:updated_at, :utc_datetime)
    field(:last_synced_at, :utc_datetime)
  end

  @required_fields [:text, :translation, :version, :created_at, :updated_at]
  @optional_fields [:examples, :is_deleted, :last_synced_at]

  def changeset(card, attrs) do
    now = DateTime.utc_now() |> DateTime.to_iso8601()

    card
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> Map.put(:last_synced_at, now)
    |> validate_required(@required_fields)
  end

  def create_changeset(attrs) do
    now = DateTime.utc_now() |> DateTime.to_iso8601()

    attrs =
      Map.merge(attrs, %{
        created_at: now,
        updated_at: now
      })

    %__MODULE__{}
    |> changeset(attrs)
  end

  def delete_changeset(card) do
    Map.put(card, :is_deleted, true)
  end

  def update_changeset(card, attrs) do
    attrs = Map.put(attrs, :updated_at, DateTime.utc_now() |> DateTime.to_iso8601())

    card
    |> changeset(attrs)
    |> validate_version_increment(card)
  end

  defp validate_version_increment(changeset, card) do
    case get_change(changeset, :version) do
      nil ->
        put_change(changeset, :version, card.version + 1)

      version when version <= card.version ->
        add_error(changeset, :version, "must be greater than current version")

      _ ->
        changeset
    end
  end
end
