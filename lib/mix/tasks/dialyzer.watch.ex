defmodule Mix.Tasks.Dialyzer.Watch do
  @moduledoc """
  Watches file changes and runs Dialyzer
  """
  @shortdoc "Watches file changes and runs Dialyzer"

  use Mix.Task

  def run(_) do
    {:ok, pid} = FileSystem.start_link(dirs: ["lib", "test"])

    FileSystem.subscribe(pid)

    run_dialyzer()

    watch()
  end

  defp watch(task \\ nil) do
    receive do
      {:file_event, _worker_pid, {_file_path, _events}} ->
        new_task = run_dialyzer(task)
        watch(new_task)
    end
  end

  defp run_dialyzer(task \\ nil) do
    if task && Process.alive?(task.pid) do
      Task.shutdown(task, :brutal_kill)
    end

    clear_console()

    Task.async(fn ->
      IO.puts("\n\nRunning Dialyzer...")

      {output, _exit_code} =
        System.cmd("mix", ["dialyzer"], stderr_to_stdout: true)

      IO.puts(output)

      IO.puts("Watching for file changes...")
    end)
  end

  defp clear_console do
    case :os.type() do
      {:win32, _} ->
        System.cmd("cls", [], stderr_to_stdout: true)

      {:unix, _} ->
        IO.write([IO.ANSI.clear(), IO.ANSI.home()])

        if System.get_env("TERM") == nil do
          System.cmd("clear", [], stderr_to_stdout: true)
        end
    end
  end
end
