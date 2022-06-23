defmodule ExDatadogLoggerTest do
  use ExUnit.Case
  doctest ExDatadogLogger

  test "greets the world" do
    assert ExDatadogLogger.hello() == :world
  end
end
