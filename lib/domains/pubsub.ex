defmodule Runa.PubSub do
  require Logger

  def broadcast(topic, payload) do
    Phoenix.PubSub.broadcast(Runa.PubSub, topic, payload)
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Runa.PubSub, topic)
  end
end
