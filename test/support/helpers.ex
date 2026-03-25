defmodule TelemetryMetricsStatsd.Test.Helpers do
  @moduledoc false

  alias TelemetryMetricsStatsd.Options

  def new_emitter(emitter_module, options) do
    {supervised?, options} = Keyword.pop(options, :supervised?, true)
    {link?, options} = Keyword.pop(options, :link?, false)
    {:ok, options} = Options.validate(options)

    try do
      result =
        cond do
          supervised? ->
            ExUnit.Callbacks.start_supervised({emitter_module, options})

          link? ->
            emitter_module.start_link(options)

          true ->
            emitter_module.start(options)
        end

      normalize_result(result)
    catch
      :exit, reason ->
        normalize_result(reason)
    end
  end

  def emit(emitter, data) do
    GenServer.call(emitter, {:emit, data})
  end

  def given_counter(event_name, opts \\ []) do
    Telemetry.Metrics.counter(event_name, opts)
  end

  def given_sum(event_name, opts \\ []) do
    Telemetry.Metrics.sum(event_name, opts)
  end

  def given_last_value(event_name, opts \\ []) do
    Telemetry.Metrics.last_value(event_name, opts)
  end

  def given_summary(event_name, opts \\ []) do
    Telemetry.Metrics.summary(event_name, opts)
  end

  def given_distribution(event_name, opts \\ []) do
    Telemetry.Metrics.distribution(event_name, opts)
  end

  defp normalize_result(result) do
    case result do
      {:ok, _} = success ->
        success

      {:error, _} = error ->
        error

      atom when is_atom(atom) ->
        {:error, atom}
    end
  end
end
