defmodule SolrCli.Counter do
  use GenServer

  defmodule State do
    defstruct [:total, count: 0]
  end

  def start_link(total) do
    GenServer.start_link(__MODULE__, total)
  end

  def inc(pid, count) do
    GenServer.cast(pid, {:inc, count})
  end

  def info(pid) do
    GenServer.call(pid, :info)
  end

  def init(total) do
    {:ok, %State{total: total}}
  end

  def handle_cast({:inc, value}, %State{count: count} = state) do
    {:noreply, %{state | count: count + value}}
  end

  def handle_call(:info, _from, %State{count: count, total: total} = state) do
    {:reply, {count, total}, state}
  end
end
