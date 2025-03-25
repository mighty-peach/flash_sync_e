defmodule FlashSyncE.SyncEngine do
  require Logger
  alias FlashSyncE.Domain.CardRepository

  def process_changes(changes, user_id)
      when is_list(changes) and length(changes) > 0 and is_binary(user_id) do
    changes |> Enum.map(fn change -> process_change(change, user_id) end)
  end

  def process_changes(changes, user_id) do
    Logger.debug("process_changes, changes: #{inspect(changes)}")
    Logger.debug("process_changes, user_id: #{inspect(user_id)}")
    raise(ArgumentError, message: "Invalid arguments")
  end

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

  def process_change(%{"action" => "update"} = data, _user_id) do
    card_params = %{
      text: data["text"],
      translation: data["translation"],
      examples: data["examples"],
      version: data["version"],
      updated_at: data["updated_at"]
    }

    card = CardRepository.get(data["id"])

    case CardRepository.update(card, card_params) do
      {:ok, card} -> {:ok, card}
      {:error, _changeset} -> {:error, "error updating card, #{data["id"]}"}
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
