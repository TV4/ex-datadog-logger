defmodule ExDatadogLogger do
  require Logger

  def put_counter(metric_name, tags \\ []) do
    Logger.info(
      "METRIC_DD #{servicename()}.#{metric_name}:1|c" <> tags(add_environmental_tags(tags))
    )
  end

  def put_counters(metric_name, counter, tags \\ []) do
    Logger.info("METRIC_DD #{servicename()}.#{metric_name}:#{counter}|c" <> tags(tags))
  end

  def put_timer(metric_name, ms, tags \\ []) do
    Logger.info(
      "METRIC_DD #{servicename()}.#{metric_name}:#{ms}|ms" <> tags(add_environmental_tags(tags))
    )
  end

  defp tags([]), do: ""

  defp tags(tags) do
    tags
    |> Enum.reduce("|#", fn
      {k, v}, acc ->
        acc <> "#{k}:#{v},"

      v, acc ->
        acc <> "#{v},"
    end)
    |> String.trim_trailing(",")
  end

  defp servicename() do
    Application.get_env(:ex_datadog_logger, :servicename)
  end

  defp add_environmental_tags(tags) do
    tags ++ platform_tag() ++ environment_name()
  end

  defp platform_tag() do
    case Application.get_env(:ex_datadog_logger, :platform_tag) do
      nil -> []
      platform -> [{"platform", platform}]
    end
  end

  defp environment_name() do
    case Application.get_env(:ex_datadog_logger, :environment) do
      nil -> []
      environment -> [{"environment", environment}]
    end
  end
end
