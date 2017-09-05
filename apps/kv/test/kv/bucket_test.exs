defmodule KV.BucketTest do
    use ExUnit.Case, async: true

    doctest KV.Bucket
    
    setup do
        {:ok, bucket} = start_supervised(KV.Bucket)
        %{bucketContext: bucket}
    end
    
    test "Stores values by key", %{bucketContext: bucket} do
        assert KV.Bucket.get(bucket, "milk") == nil
        put(bucket, "milk", 3)
        assert KV.Bucket.get(bucket, "milk") == 3
    end

    test "Retrieve all values from bucket", %{bucketContext: bucket} do
        put(bucket, "milk", 3)
        put(bucket, "beer", 3)
        put(bucket, "cheese", 1)
        assert KV.Bucket.get(bucket, :all) == %{
            "milk" => 3,
            "cheese" => 1,
            "beer" => 3
        }
    end

    test "Delete from bucket", %{bucketContext: bucket} do
        put(bucket, "milk", 3)
        put(bucket, "cheese", 1)
        put(bucket, "beer", 10)
        assert KV.Bucket.delete(bucket, "milk") == {3, %{"cheese" => 1, "beer" => 10}}
    end

    test "are temporary workers" do
        assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
    end

    defp put(bucket, key, value) do
        KV.Bucket.put(bucket, key, value)
    end
end