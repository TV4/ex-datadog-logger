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

  def phoenix_endpoint_stop(_events, %{duration: duration}, %{conn: conn} = _metadata, _) do
    {"user-agent", user_agent} =
      case Enum.find(conn.req_headers, fn {key, _val} -> key == "user-agent" end) do
        {"user-agent", user_agent} -> {"user-agent", user_agent}
        nil -> {"user-agent", nil}
      end

    with true <- conn.request_path not in ignored_endpoints(),
         false <- String.contains?(user_agent, "Detectify") do
      tags = [
        {:request_endpoint, conn.request_path},
        {:response_status_code, conn.status},
        {:user_agent, user_agent}
      ]

      tags =
        case Enum.filter(conn.req_headers, fn {header, _value} -> header == "client" end) do
          [{"client", client_name}] -> tags ++ [{:client, client_name}]
          [] -> tags
        end

      ExDatadogLogger.put_counter("http", tags)
      ExDatadogLogger.put_timer("response-time", duration(duration))
    else
      _ ->
        ExDatadogLogger.put_timer("response-time", duration(duration))
    end
  end

  defp ignored_endpoints(), do: Application.get_env(:ex_datadog_logger, :ignore_endpoints, [])
end
