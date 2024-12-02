defmodule RunaWeb.Components.Spinner do
  use Phoenix.Component

  attr :class, :string, default: nil
  attr :rest, :global

  def spinner(assigns) do
    ~H"""
    <span
      class={[
        "loader inline-block w-[1rem] h-[1rem] align-middle p-[0.15rem] rounded-full bg-current",
        @class
      ]}
      {@rest}
    >
    </span>
    """
  end
end
