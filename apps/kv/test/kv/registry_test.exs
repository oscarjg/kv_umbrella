defmodule KV.RegistryTest do
    use ExUnit.Case, async: true
    doctest KV.Registry

    setup do
    #setup context do
        #{:ok, _} = start_supervised({KV.Registry, name: context.test})
        #%{registry: context.test}
        {:ok, registry} = start_supervised(KV.Registry)
        %{registry: registry}
    end

    test "Spanws buckets", %{registry: registry} do
        assert KV.Registry.lookup(registry, "fooBucket") == :error
        KV.Registry.create(registry, "fooBucket")
        assert {:ok, bucketFoo} = KV.Registry.lookup(registry, "fooBucket")
        
        KV.Bucket.put(bucketFoo, "bar", 1)
        assert KV.Bucket.get(bucketFoo, "bar") == 1
    end

    test "Stop server", %{registry: registry} do
        KV.Registry.create(registry, "foo")
        {:ok, bucket} = KV.Registry.lookup(registry, "foo")
        Agent.stop(bucket)
        assert KV.Registry.lookup(registry, "foo") == :error
    end

    test "Remove bucket wihout chrash registry", %{registry: registry} do
        KV.Registry.create(registry, "foo")
        {:ok, bucket} = KV.Registry.lookup(registry, "foo")
        Agent.stop(bucket, :shutdown)
        assert KV.Registry.lookup(registry, "foo") == :error
    end
end