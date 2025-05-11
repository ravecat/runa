defmodule Mix.Tasks.Cleanup.Chromedrivers do
  @moduledoc """
  Mix task to kill abandoned chromedriver processes.
  """

  @shortdoc "Cleans up abandoned chromedriver processes"

  use Mix.Task

  def run(_) do
    os_cmd =
      case :os.type() do
        {:unix, :darwin} -> {"killall", ["chromedriver"]}
        {:unix, _} -> {"pkill", ["chromedriver"]}
        {:win32, _} -> {"taskkill", ["/IM", "chromedriver.exe", "/F"]}
      end

    case os_cmd do
      {cmd, args} -> System.cmd(cmd, args)
      _ -> IO.puts("Unsupported OS for automatic cleanup.")
    end
  end
end
