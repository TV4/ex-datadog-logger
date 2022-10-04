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
    {"user-agent", user_agent_arg} =
      Enum.find(conn.req_headers, fn {key, _val} -> key == "user-agent" end)

    blacklisted? = conn.request_path in ["/health"]

    with false <- String.contains?(user_agent_arg, "Detectify"), false <- blacklisted? do
      tags = [
        {:request_endpoint, conn.request_path},
        {:response_status_code, conn.status}
      ]

      tags =
        case Enum.filter(conn.req_headers, fn {header, _value} -> header == "client" end) do
          [{"client", client_name}] -> tags ++ [{:client, client_name}]
          [] -> tags
        end

      ExDatadogLogger.put_counter("http", tags)
      ExDatadogLogger.put_timer("response-time", duration(duration))
    else
      true ->
        ExDatadogLogger.put_timer("response-time", duration(duration))
    end
  end
end
