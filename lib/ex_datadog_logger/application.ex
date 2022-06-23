defmodule ExDatadogLogger.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: ExDatadogLogger.Worker.start_link(arg)
      # {ExDatadogLogger.Worker, arg}
      ExDatadogLogger.DatadogLoggerManager
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExDatadogLogger.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
