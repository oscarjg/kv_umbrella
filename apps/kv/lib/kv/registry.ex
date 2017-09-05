defmodule KV.Registry do
    use GenServer

    ## Client API

    @doc "Starts the registry"
    def start_link(opts) do
        #serverName = Keyword.fetch!(opts, :name)
        #GenServer.start_link(__MODULE__, serverName, opts)
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    @doc """
        Looks up the bucket pid for `name` stored in `server`.
        Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
    """
    def lookup(server, name) do
        #case :ets.lookup(server, name) do
        #    [{^name, pid}] -> {:ok, pid}
        #    [] -> :error
        #end
        GenServer.call(server, {:lookup, name})
    end

    @doc """
        Ensures there is a bucket associated with the given `name` in `server`.
    """
    def create(server, name) do
        GenServer.cast(server, {:create, name})
        #GenServer.call(server, {:create, name})
    end

    @doc "Stop server"
    def stop(server) do
        GenServer.stop(server)
    end

    ## Server Callbacks

    def init(:ok) do
    #def init(table) do
        names = %{}
        #names = :ets.new(table, [:named_table, read_concurrency: true])
        refs  = %{}
        {:ok, {names, refs}}
    end
    
    def handle_call({:lookup, name}, _from, {names,_} = state) do
        {:reply, Map.fetch(names, name), state}
    end
    
    #def handle_call({:create, name}, _from, {names, refs}) do
    #    case lookup(names, name) do
    #        {:ok, _pid} ->
    #            {:noreply, {names, refs}}
    #        :error ->
    #            {:ok, pid} = KV.BucketSupervisor.start_bucket()
    #            ref = Process.monitor(pid)
    #            refs = Map.put(refs, ref, name)
    #            names = Map.put(names, name, pid)
    #            :ets.insert(names, {name, pid})
    #            {:noreply, {names, refs}}
    #    end
    #end

    def handle_cast({:create, name}, {names, refs}) do
        if Map.has_key?(names, name) do
            {:noreply, {names, refs}}
        else
            {:ok, pid} = KV.BucketSupervisor.start_bucket()
            ref = Process.monitor(pid)
            refs = Map.put(refs, ref, name)
            names = Map.put(names, name, pid)
            {:noreply, {names, refs}}
        end
    end

    def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
        {name, refs} = Map.pop(refs, ref)
        #:ets.delete(names, name )
        names = Map.delete(names, name)
        {:noreply, {names, refs}}
    end
    
    def handle_info(_msg, state) do
        {:noreply, state}
    end
end