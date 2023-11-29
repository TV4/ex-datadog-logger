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
             end) =~ "METRIC_DD testservice.metric:1|c|#key:value,success\n"
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

      refute capture_log(fn ->
               ExDatadogLogger.put_timer("response-time", 5000)
             end) =~ "platform"
    end

    test "with tags" do
      assert capture_log(fn ->
               ExDatadogLogger.put_timer("response-time", 5000, [{"key", "value"}, :success])
             end) =~ "METRIC_DD testservice.response-time:5000|ms|#key:value,success\n"

      refute capture_log(fn ->
               ExDatadogLogger.put_timer("response-time", 5000, [{"key", "value"}, :success])
             end) =~ "platform"
    end
  end

  describe "with extra tags" do
    setup do
      old_platform_tag = Application.get_env(:ex_datadog_logger, :platform_tag)
      Application.put_env(:ex_datadog_logger, :platform_tag, :test)

      old_environment_tag = Application.get_env(:ex_datadog_logger, :environment)
      Application.put_env(:ex_datadog_logger, :environment, :test)

      on_exit(fn ->
        Application.put_env(:ex_datadog_logger, :environment, old_environment_tag)

        Application.put_env(:ex_datadog_logger, :platform_tag, old_platform_tag)
      end)

      :ok
    end

    test "put_counter" do
      assert capture_log(fn ->
               ExDatadogLogger.put_counter("metric", [{"key", "value"}, :success])
             end) =~
               "METRIC_DD testservice.metric:1|c|#key:value,success,platform:test,environment:test\n"
    end

    test "put_timer" do
      assert capture_log(fn ->
               ExDatadogLogger.put_timer("response-time", 5000, [{"key", "value"}, :success])
             end) =~
               "METRIC_DD testservice.response-time:5000|ms|#key:value,success,platform:test,environment:test\n"
    end
  end
end
