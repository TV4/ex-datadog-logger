defmodule ExDatadogLogger.DatadogLogger do
  require Logger

  @doc false
  def install do
    handlers = %{
      [:phoenix, :endpoint, :start] => &__MODULE__.phoenix_endpoint_start/4,
      [:phoenix, :endpoint, :stop] => &__MODULE__.phoenix_endpoint_stop/4
    }

    for {key, fun} <- handlers do
      :telemetry.attach({__MODULE__, key}, key, fun, :ok)
    end
  end

  def phoenix_endpoint_start(_, _, %{conn: _conn} = _metadata, _) do
  end

  def duration(duration) do
    duration = System.convert_time_unit(duration, :native, :microsecond)

    if duration > 1000 do
      duration |> div(1000) |> Integer.to_string()
    else
      (duration / 1000) |> Float.to_string()
    end
  end

  def phoenix_endpoint_stop(_, %{duration: duration}, %{conn: conn} = _metadata, _) do
    %{status: status} = conn
    servicename = servicename()
    Logger.info("METRIC_DD #{servicename}.status.#{status}:1|c")
    Logger.info("METRIC_DD #{servicename}.response-time:#{duration(duration)}|ms")
  end

  defp servicename() do
    Application.get_env(:ex_datadog_logger, :servicename)
  end
end
