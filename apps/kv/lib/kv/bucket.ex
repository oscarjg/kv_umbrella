defmodule KV.Bucket do
    use Agent, restart: :temporary
    
    @moduledoc "Bucket module has responsabilty to store and retrieve data stored"

    @doc "Initialize a new bucket with empty list"
    def start_link(_opts) do
        Agent.start_link(fn -> %{} end)
    end

    @doc "Get all data store"
    def get(bucket, :all) do
        Agent.get(bucket, fn (list) -> list end)
    end

    @doc "Get value from key"
    def get(bucket, key) do
        Agent.get(bucket, &Map.get(&1, key))
    end

    @doc "Put some value on key specified"
    def put(bucket, key, value) do
        Agent.update(bucket, fn list -> Map.put(list, key, value) end)
    end

    @doc "Delete keys from bucket"
    def delete(bucket, key) do
        Agent.get_and_update(bucket, fn list -> {Map.pop(list, key), list} end)
    end
end