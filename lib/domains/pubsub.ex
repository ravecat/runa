defmodule Runa.PubSub do
  @moduledoc """
  This module is responsible for broadcasting messages to the pubsub system.
  """
  require Logger

  def broadcast(topic, payload) do
    Phoenix.PubSub.broadcast(Runa.PubSub, topic, payload)
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Runa.PubSub, topic)
  end

  def unsubscribe(topic) do
    Phoenix.PubSub.unsubscribe(Runa.PubSub, topic)
  end
end
