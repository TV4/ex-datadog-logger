defmodule ExDatadogLogger.DatadogLoggerManager do
  use GenServer

  alias ExDatadogLogger.DatadogLogger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    DatadogLogger.install()
    {:ok, nil}
  end
end
