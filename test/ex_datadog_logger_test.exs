defmodule ExDatadogLoggerTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  setup do
    Application.put_env(:ex_datadog_logger, :servicename, :testservice)
    :ok
  end

  describe "put_counter" do
    test "with tags" do
      assert capture_log(fn ->
               ExDatadogLogger.put_counter("metric", [{"key", "value"}, :success])
             end) =~ "METRIC_DD testservice.metric:1|c|#key:value,success"
    end

    test "without tags" do
      assert capture_log(fn ->
               ExDatadogLogger.put_counter("metric")
             end) =~ "METRIC_DD testservice.metric:1|c"
    end
  end

  describe "put_timer" do
    test "without tags" do
      assert capture_log(fn ->
               ExDatadogLogger.put_timer("response-time", 5000)
             end) =~ "METRIC_DD testservice.response-time:5000|ms"
    end

    test "with tags" do
      assert capture_log(fn ->
               ExDatadogLogger.put_timer("response-time", 5000, [{"key", "value"}, :success])
             end) =~ "METRIC_DD testservice.response-time:5000|ms|#key:value,success"
    end
  end
end
