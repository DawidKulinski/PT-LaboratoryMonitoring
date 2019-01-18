defmodule ControllstationWeb.PageController do
  use ControllstationWeb, :controller

  def get_student_info(x, result) do
    case result do
      nil -> ["Brak procesow"]
      _ -> result
    end
  end


  def init_connection do
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
    channel
  end


  def change_config(conn, %{"username" => username} = params) do
    channel = init_connection

    AMQP.Queue.declare(channel, username)

    AMQP.Basic.publish(channel, "", username, "true", [{:type, "compress"}])
    redirect(conn, to: "/")
  end


  def block_process(conn, %{"username" => username, "processname" => processname}) do
    channel = init_connection

    AMQP.Queue.declare(channel, username)
    AMQP.Basic.publish(channel, "", username, processname, [{:type, "block"}])

    redirect(conn, to: "/")
  end



  def get_file(conn, %{"username" => username} = params) do

    folder = "F:\\fajne rzeczy\\PT-LaboratoryMonitoring\\Management\\controllstation\\" <> username <> "\\"

    path = File.ls(folder) |> Kernel.elem(1) |> Enum.take(-1) |> Enum.at(0)

    IO.puts "#{folder <> path}"

    conn |> send_download({:file, folder <> path}, filename: "test.png")
  end

  def index(conn, _params) do
 
    {:ok, mongo} = Mongo.start_link(url: "mongodb://localhost:27017/test")
    cursor = Mongo.find(mongo, "ActiveUsers", %{}, [{"sort", "-1"}])
    [head|_] = cursor |> Enum.to_list

    data= head["active"] |> Enum.to_list |> Enum.filter(fn el -> !Enum.member?(["admin", "operator"], el) end)

    processes = Enum.reduce(data, %{}, fn x, acc ->
       Map.put(acc, x, get_student_info(x, Mongo.find_one(mongo, "Students",%{station: x})["processes"]))
		end)

    render(conn, "index.html", processes: processes)
  end
end
