defmodule MongoDB do
    def insert_object(stationName) do
    {:ok, conn} = Mongo.start_link(url: "mongodb://localhost:27017/test")
    Mongo.insert_one(conn,"Students", %{station: stationName, processes: []})
    end

    def update_object(stationName, processName) do
    {:ok, conn} = Mongo.start_link(url: "mongodb://localhost:27017/test")
    Mongo.update_one(conn,"test-collection",%{station: stationName}, %{ "$push": %{"processes": processName}})
    end
end


defmodule Receive do
import MongoDB
    def wait_for_messages do
        receive do
            {:basic_deliver, payload, _meta} ->
            MongoDB.update_object("User1", payload)
            IO.puts "#{payload}"
            wait_for_messages()
        end
    end
end


{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)
AMQP.Queue.declare(channel, "hello")
AMQP.Basic.consume(channel, "hello", nil, no_ack: true)
IO.puts " [*] Waiting for messages."

Receive.wait_for_messages()


