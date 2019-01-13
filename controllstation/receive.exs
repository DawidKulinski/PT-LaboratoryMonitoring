defmodule MongoDB do
    def init do
        {:ok, _} = Mongo.start_link(url: "mongodb://localhost:27017/test", name: :mongo)
    end

    def insert_object(stationName) do
    :mongo |> Mongo.insert_one("Students",
                    %{station: stationName, processes: []})
    end

    def update_object(stationName, processName) do
    :mongo |> Mongo.update_one("test-collection",%{station: stationName},
                    %{ "$push": %{processes: processName}})
    end

    def upload_file(payload) do
        # bucket = :mongo |> Mongo.GridFs.Bucket.new
        # upload_stream = Mongo.GridFs.Upload.open_upload_stream bucket, "test.txt", j: true
        
        IO.puts "#{:binary.bin_to_list(payload)}"

        # :binary.bin_to_list(payload) |> Mongo.GridFs.UploadStream.into(upload_stream) |> Stream.run()
    end
end


defmodule Receive do
import MongoDB
    def init_user(payload) do
        MongoDB.insert_object payload
        IO.puts "InsertUser"
    end

    def update_user(payload, user_name) do
        MongoDB.update_object user_name, payload
        IO.puts "UpdateUser"
    end
    def save_screenshot do
        IO.puts "Screenshot"
    end

    def wait_for_messages do
        receive do
            {:basic_deliver, payload, meta} ->
                IO.puts "#{meta.type}"
                case meta.type do
                    "init" -> init_user payload
                    "update" -> upload_file payload
                    "screenshot" -> save_screenshot
                end
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

MongoDB.init()
Receive.wait_for_messages()


