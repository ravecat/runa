defmodule Runa.PubSub do
  @moduledoc """
  This module is responsible for broadcasting messages to the pubsub system.
  """
  require Logger

  @spec broadcast(binary(), any()) :: :ok | {:error, any()}
  def broadcast(topic, payload) do
    case Phoenix.PubSub.broadcast(Runa.PubSub, topic, payload) do
      :ok ->
        Logger.debug("BROADCAST OK #{topic}: #{inspect(payload, pretty: true)}")

        :ok

      {:error, reason} = error ->
        Logger.error("BROADCAST FAILED #{topic}: #{inspect(reason)}")

        error
    end
  end

  @spec subscribe(binary(), keyword()) :: :ok | {:error, term()}
  def subscribe(topic, opts \\ []) do
    case Phoenix.PubSub.subscribe(Runa.PubSub, topic, opts) do
      :ok ->
        Logger.debug("SUBSCRIBE OK #{topic}")

        :ok

      {:error, reason} = error ->
        Logger.error("SUBSCRIBE FAILED #{topic}: #{inspect(reason)}")

        error
    end
  end

  @spec unsubscribe(binary()) :: :ok
  def unsubscribe(topic) do
    Phoenix.PubSub.unsubscribe(Runa.PubSub, topic)

    Logger.debug("UNSUBSCRIBE OK #{topic}")
    :ok
  end
end
