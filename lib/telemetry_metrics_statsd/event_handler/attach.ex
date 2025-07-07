defmodule TelemetryMetricsStatsd.EventHandler.Attach do
  @moduledoc false

  alias TelemetryMetricsStatsd.EventHandler
  alias TelemetryMetricsStatsd.Options
  use GenServer

  def start_link([options, emitter_module]) do
    GenServer.start_link(__MODULE__, [options, emitter_module])
  end

  @impl true
  def init([%Options{} = options, emitter_module]) do
    Process.flag(:trap_exit, true)

    emitter_function =
      case Options.emit_kind(options) do
        :sync ->
          :emit

        :async ->
          :emit_async
      end

    handler_ids = EventHandler.attach(options, emitter_module, emitter_function)

    {:ok, handler_ids}
  end

  @impl true
  def handle_info({:EXIT, _pid, reason}, handler_ids) do
    {:stop, reason, handler_ids}
  end

  @impl true
  def terminate(_reason, handler_ids) do
    EventHandler.detach(handler_ids)
  end
end
