defmodule Exstomp.Frame do

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