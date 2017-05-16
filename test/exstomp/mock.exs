defmodule Exstomp.MockServer do
  @use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def wait_new(pid) do
    GenServer.cast(pid, :wait_new)
  end

  # callbacks

  def init(_config) do
    case :gen_tcp.listen(61613, [:binary]) do
      {:ok, socket} ->
        Process.send_after(self(), :wait_new, 500)
        {:ok, listen_socket: socket}
      {:error, reason} ->
        {:stop, reason}
    end
  end

  def handle_info(:wait_new, [listen_socket: listen_socket] = state) do
    IO.puts "enter inside wait_new"
    case :gen_tcp.accept(listen_socket) do
      {:ok, socket} ->
        {:noreply, Keyword.put(state, :socket, socket)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def handle_info({:tcp, _socket, message}, state) do
    IO.puts "received unhandled message"
    IO.puts message
    {:noreply, message}
  end
end
