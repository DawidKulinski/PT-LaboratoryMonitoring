defmodule ControllstationWeb.PageController do
  use ControllstationWeb, :controller

  def get_student_info(x, result) do
    case result do
      nil -> ["Brak procesow"]
      _ -> result
    end
  end

  def index(conn, _params) do
 
    {:ok, mongo} = Mongo.start_link(url: "mongodb://localhost:27017/test")
    cursor = Mongo.find(mongo, "ActiveUsers", %{}, [{"sort", "-1"}])
    [head|_] = cursor |> Enum.to_list

    data= head["active"] |> Enum.to_list

    processes = Enum.reduce(data, %{}, fn x, acc ->
       Map.put(acc, x, get_student_info(x, Mongo.find_one(mongo, "Students",%{station: x})["processes"]))
		end)

    render(conn, "index.html", processes: processes)
  end
end
