defmodule Exstomp.MockServer do
  @use GenServer

  @timeout_freq 100

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def wait_new(pid) do
    GenServer.cast(pid, :wait_new)
  end

  def fetch_state(pid) do
    GenServer.call(pid, :fetch_state)
  end

  # callbacks

  def init(_config) do
    case :gen_tcp.listen(61613, [:binary]) do
      {:ok, socket} ->
        {:ok, %{listen_socket: socket, state: :not_connected}, @timeout_freq}
      {:error, reason} ->
        {:stop, reason}
    end
  end

  def handle_info(:timeout, %{state: :not_connected} = state) do
    case :gen_tcp.accept(state.listen_socket, @timeout_freq) do
      {:ok, socket} ->
        state = Map.update(state, :sockets, socket, fn(_) -> socket end)
        state = %{state | state: :connected}
        {:noreply, state}
      {:error, :timeout} ->
        {:noreply, state, @timeout_freq}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def handle_info({:tcp, socket, "CONNECT" <> _rest = message}, state) do
    IO.puts "connected message"
    {:noreply, state, @timeout_freq}
  end

  def handle_info({:tcp, _socket, message}, state) do
    IO.puts "received unhandled message"
    IO.puts message
    {:noreply, state, @timeout_freq}
  end

  def handle_call(:fetch_state, _from, state) do
    {:reply, state, state, @timeout_freq}
  end

  def terminate(reason, state) do
    IO.puts("Terminating the Mock Stomp Server reason: #{inspect reason}")
  end
end
