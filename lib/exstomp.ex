defmodule Exstomp do
  @moduledoc """
  Documentation for Exstomp.
  """

  use GenServer

  def start_link(config \\ %{}) do
    GenServer.start_link(__MODULE__, config)
  end

  def send_to(pid, dest, message) do
    GenServer.call(pid, {:send, %{dest: dest, message: message}})
  end

  # callbacks

  def init(_config) do
    IO.puts "Initializing connection"
    case :gen_tcp.connect('localhost', 61613, [:binary]) do
      {:ok, socket} ->
        case :gen_tcp.send(socket, build_connect_frame()) do
          :ok ->
            Process.send_after(self(), :heartbeat, 10_000)
            {:ok, %{socket: socket}}
          {:err, _reason} ->
            IO.puts "error sending the connection package"
            {:stop, "error sending the connection package"}
        end
      _ ->
        IO.puts "Error connecting to port 61613"
        {:stop, "error connectiong"}
    end
  end

  def handle_call({:send, %{message: message, dest: dest}}, _from, status) do
    IO.puts "sending message #{message}"
    case :gen_tcp.send(status.socket, build_send_frame(dest, message)) do
      :ok ->
        {:reply, :ok, status}
      {:err, _reason} ->
        IO.puts "Error sending send fframe"
    end
  end

  def handle_info({:tcp, _socket, "CONNECTED" <> _ = data}, state) do
    IO.puts "connected confirmation"
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, "\n"}, state) do
    IO.puts "received heartbeat from broker"
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, "ERROR" <> _ = data}, state)  do
    IO.puts "Error frame received"
    IO.puts data
    {:stop, "error frame", state}
  end

  def handle_info(:heartbeat, state) do
    IO.puts "sending heartbea to #{inspect state.socket}"
    case :gen_tcp.send(state.socket, "\n") do
      :ok ->
        Process.send_after(self(), :heartbeat, 10_000)
        {:noreply, state}
      {:err, _reason} ->
        IO.puts "error sending heartbeat"
    end
  end

  defp build_connect_frame(_options \\ []) do
    """
    CONNECT
    accept-version:1.0,1.1
    login:
    passcode:
    heart-beat:10000,7500
    host:/

    """ <> "\0"
  end

  defp build_send_frame(dest, message) do
    msg = """
    SEND
    destination:#{dest}
    content-type:text/plain
    content-length:#{String.length(message) + 1}

    #{message}
    """ <> "\0"
  end

end
