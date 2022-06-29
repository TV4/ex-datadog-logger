defmodule ExDatadogLogger do
  require Logger

  def put_counter(metric_name, tags \\ []) do
    Logger.info("METRIC_DD #{servicename()}.#{metric_name}:1|c" <> tags(tags))
  end

  def put_timer(metric_name, ms, tags \\ []) do
    Logger.info("METRIC_DD #{servicename()}.#{metric_name}:#{ms}|ms" <> tags(tags))
  end

  defp tags([]), do: ""

  defp tags(tags) do
    Enum.reduce(tags, "|#", fn
      {k, v}, acc ->
        acc <> "#{k}:#{v},"

      v, acc ->
        acc <> "#{v},"
    end)
  end

  defp servicename() do
    Application.get_env(:ex_datadog_logger, :servicename)
  end
end
