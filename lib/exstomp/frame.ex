defmodule Exstomp.Frame do
  @docmodule """
  Doc for the frame module. This module is used to create the frame
  that will be passed as a message to the broker.
  """

  def build_frame(message, headers) do
    "#{message}\n" <>
      (Enum.map(headers, fn(h) -> "#{elem(h, 0)}:#{elem(h, 1)}" end) |> Enum.join("\n")) <>
      "\n\n\0"
  end

  def build_connect_frame(_options \\ []) do
    """
    CONNECT
    accept-version:1.0,1.1
    login:
    passcode:
    heart-beat:10000,7500
    host:/

    """ <> "\0"
  end

  def build_send_frame(dest, message) do
    msg = """
    SEND
    destination:#{dest}
    content-type:text/plain
    content-length:#{String.length(message) + 1}

    #{message}
    """ <> "\0"
  end

end
