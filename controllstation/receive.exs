defmodule MongoDB do
    def insert_object(stationName) do
    {:ok, conn} = Mongo.start_link(url: "mongodb://localhost:27017/test")
    Mongo.insert_one(conn,"Students", %{station: stationName, processes: []})
    end

    def update_object(stationName, processName) do
    {:ok, conn} = Mongo.start_link(url: "mongodb://localhost:27017/test")
    Mongo.update_one(conn,"test-collection",%{station: stationName}, %{ "$push": %{processes: processName}})
    end
end


defmodule Receive do
import MongoDB
    def init_user(payload) do
        #MongoDB.insert_object payload
        IO.puts "InsertUser"
    end

    def update_user(payload, user_name) do
        #MongoDB.update_object user_name, payload
        IO.puts "UpdateUser"
    end
    def wait_for_messages do
        receive do
            {:basic_deliver, payload, meta} ->
                IO.puts "#{meta.type}"
                case meta.type do
                    "init" -> init_user payload
                    "update" -> update_user payload,meta.user_id
                end
            # MongoDB.update_object("#{meta.user_id}", payload)
            IO.puts "#{meta.user_id}"
            IO.puts "#{meta.type}"
            IO.puts "#{payload}"
            wait_for_messages
        end
    end
end


{:ok, connection} = AMQP.Connection.open port: 5671,
            ssl_options: [cacertfile: 'D:\\rabbitcerts\\ca_certificate_bundle.pem',
                        certfile: 'D:\\rabbitcerts\\operator\\operator_certificate.pem',
                        keyfile: 'D:\\rabbitcerts\\operator\\private_key.pem',
                        verify: :verify_peer,
                        fail_if_no_peer_cert: true,
                        server_name_indication: 'admin'],
            auth_mechanisms: [&:amqp_auth_mechanisms.external/3],
            username: 'operator'
            

{:ok, channel} = AMQP.Channel.open(connection)
AMQP.Queue.declare(channel, "dataqueue")
AMQP.Basic.consume(channel, "dataqueue", nil, no_ack: true)
IO.puts " [*] Waiting for messages."

Receive.wait_for_messages()


