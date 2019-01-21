defmodule MongoDB do

    def init do
        {:ok, _} = Mongo.start_link(url: "mongodb://localhost:27017/test", name: :mongo)
        :mongo |> Mongo.insert_one("ActiveUsers",
        %{datetime: "sampleInput", active: []})
    end



    def insert_object(stationName) do
        :mongo |> Mongo.replace_one("Students", %{station: stationName}, 
                %{station: stationName, processes: []})
    end



    def update_object(stationName, processName) do
    :mongo |> Mongo.update_one("Students",%{station: stationName},
                    %{ "$addToSet": %{processes: processName}})
    end



    def add_user(userName) do
        :mongo |> Mongo.update_one("ActiveUsers",%{datetime: "sampleInput"},
        %{ "$push": %{active: userName}})
    end
end





defmodule Receive do

import MongoDB

    def init_user(payload) do
        File.mkdir(payload)
        MongoDB.insert_object payload
        IO.puts "InsertUser"
    end

    def update_user(payload, user_name) do
        MongoDB.update_object user_name, payload
        IO.puts "#{payload}"
    end

    def save_screenshot(username, data) do
        datetime = Integer.to_string(:os.system_time(:millisecond))
        {:ok, file} = File.open username <> "\\" <> datetime <> ".png", [:write]
        IO.binwrite file, data
        File.close file
    end

    def get_username([head|_]) do
            head |> elem(2)
    end

    def default(meta) do
        case meta.routing_key do
            "connection.created" -> get_username(meta.headers) |> MongoDB.add_user           
        end
    end

    def wait_for_messages() do
        receive do
            {:basic_deliver, payload, meta} ->
                case meta.type do
                    "init" -> init_user payload
                    "update" -> update_user payload, meta.user_id
                    "screenshot" -> save_screenshot meta.user_id, payload
                    :undefined -> default meta
                end
            wait_for_messages()
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
AMQP.Queue.bind(channel, "dataqueue", "amq.rabbitmq.event", routing_key: "connection.created")
AMQP.Basic.consume(channel, "dataqueue", nil, no_ack: true)

IO.puts " [*] Waiting for messages."

MongoDB.init()
Receive.wait_for_messages()