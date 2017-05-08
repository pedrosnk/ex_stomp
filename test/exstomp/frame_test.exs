defmodule Exstomp.FrameTest do
  use ExUnit.Case
  alias Exstomp.Frame

  test "build a connect frame" do
    expected = "CONNECT\naccept-version:1.0,1.1\nlogin:\npasscode:\n" <>
      "heart-beat:10000,7500\nhost:/\n\n\0"
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
end
