defmodule Exstomp.FrameTest do
  use ExUnit.Case
  alias Exstomp.Frame

  test "build a connect frame" do
    expected = "CONNECT\naccept-version:1.0,1.1\nheart-beat:10000,7500\nhost:/\n" <>
      "login:\npasscode:\n\n\0"
    assert Frame.build_connect_frame == expected
  end

  describe "send frame" do
    test "render text message" do
      expected = "SEND\ndestination:/queue/foo\ncontent-type:text/plain\n" <>
        "content-length:7\n\nfoobar\n\0"
      assert Frame.build_send_frame("/queue/foo", "foobar") == expected
    end
  end

  describe "build frame" do
    test "build connect frame" do
      headers = %{"accept-version": "1.1", host: "customstomphost.org"}
      expected = "CONNECT\naccept-version:1.1\nhost:customstomphost.org\n\n\0"
      assert Frame.build_frame("CONNECT", headers) == expected
    end
  end

  describe "parse a message into frame" do
    test "parse a heartbeat frame" do
      assert %Frame{type: :heartbeat} == Frame.parse("\n")
    end
  end
end
