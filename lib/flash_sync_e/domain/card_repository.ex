defmodule FlashSyncE.Domain.CardRepository do
  import Ecto.Query
  alias FlashSyncE.Repo
  alias FlashSyncE.Domain.CardModel

  def get(id) when is_binary(id) and byte_size(id) > 0 do
    Repo.get(CardModel, id)
  end

  def get(_invalid), do: raise(ArgumentError, message: "Invalid ID")

  def get_by_ids(ids) when is_list(ids) and length(ids) > 0 do
    valid_ids = Enum.filter(ids, &(is_binary(&1) and byte_size(&1) > 0))

    case valid_ids do
      [] ->
        raise ArgumentError, message: "Invalid IDs"

      ids ->
        from(c in CardModel, where: c.id in ^ids)
        |> Repo.all()
    end
  end

  def get_by_ids(_invalid), do: raise(ArgumentError, message: "Invalid ID")

  def create(attrs) when is_map(attrs) do
    attrs
    |> CardModel.create_changeset()
    |> Repo.insert()
  end

  def create(_invalid), do: raise(ArgumentError, message: "Invalid attributes")

  def update(%CardModel{} = card, attrs) when is_map(attrs) do
    card
    |> CardModel.update_changeset(attrs)
    |> Repo.update()
  end

  def update(_card, _invalid), do: raise(ArgumentError, message: "Invalid attributes")

  def delete(%CardModel{} = card) when is_map(card) do
    card
    |> CardModel.delete_changeset()
    |> Repo.delete()
  end

  def delete(_), do: raise(ArgumentError, message: "Invalid entity to delete")

  def get_changes_since(last_sync_time) do
    from(c in CardModel,
      where: c.updated_at > ^last_sync_time
    )
    |> Repo.all()
  end

  def mark_synced(id, sync_time) when is_binary(id) and byte_size(id) > 0 do
    get(id)
    |> CardModel.update_changeset(%{"last_synced_at" => sync_time})
    |> Repo.update()
  end

  def mark_synced(_invalid, _sync_time), do: raise(ArgumentError, message: "Invalid ID")
end
