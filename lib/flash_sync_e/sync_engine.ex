defmodule FlashSyncE.SyncEngine do
  alias FlashSyncE.Repo
  alias FlashSyncE.Domain.CardRepository

  # TODO: start transaction -> process one change at a time -> return tuple with successes and errors
  def process_changes(changes, user_id)
      when is_list(changes) and length(changes) > 0 and is_binary(user_id) do
    Repo.transaction(fn ->
      nil
    end)
  end

  def process_changes(_, _), do: raise(ArgumentError, message: "Invalid arguments")

  def process_change(%{"action" => "create"} = data, _user_id) do
    card_params = %{
      text: data["text"],
      translation: data["translation"],
      examples: data["examples"]
    }

    case CardRepository.create(card_params) do
      {:ok, card} -> {:ok, card}
      {:error, _changeset} -> {:error, card_params}
    end
  end

  def process_change(%{"action" => "delete"} = data, _user_id) do
    card = CardRepository.get(data["id"])

    case CardRepository.delete(card) do
      {:ok, card} -> {:ok, card}
      {:error, _changeset} -> {:error, card}
    end
  end

  def process_change(data, _user_id),
    do: {:error, Map.merge(%{"message" => "Invalid action"}, data)}
end
