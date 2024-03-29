defmodule Exstomp.Frame do
  @moduledoc """
  Doc for the frame module. This module is used to create the frame
  that will be passed as a message to the broker.
  """

  defstruct [:type, :headers, :message]

  def build_frame(message, headers) do
    "#{message}\n" <>
      (Enum.map(headers, fn(h) -> "#{elem(h, 0)}:#{elem(h, 1)}" end) |> Enum.join("\n")) <>
      "\n\n\0"
  end

  def build_connect_frame(_options \\ []) do
    build_frame("CONNECT",
      %{"accept-version": "1.0,1.1",
        login: "",
        passcode: "",
        "heart-beat": "10000,7500",
        host: "/"
      }
    )
  end

  def build_send_frame(dest, message) do
    """
    SEND
    destination:#{dest}
    content-type:text/plain
    content-length:#{String.length(message) + 1}

    #{message}
    """ <> "\0"
  end

  def parse("\n") do
    %Exstomp.Frame{type: :heartbeat}
  end

end
