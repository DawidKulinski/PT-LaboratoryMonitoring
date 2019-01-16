#{:ok, conn} = Mongo.start_link(name: :mongo, database: "test")

#cursor = Mongo.find(:mongo, "Students", %{})

#cursor |> Enum.to_list() |> IO.inspect


    {:ok, mongo} = Mongo.start_link(url: "mongodb://localhost:27017/test")
    cursor = Mongo.find(mongo, "ActiveUsers", %{}, [{"sort", "-1"}])
    [head|_] = cursor |> Enum.to_list

    data= head["active"] |> Enum.to_list

    processes = Enum.reduce(data, %{}, fn x, acc -> Map.put(acc, x, Mongo.find_one(mongo, "Students",%{station: x})["processes"])
		end)
		
		
IO.puts "#{processes}"