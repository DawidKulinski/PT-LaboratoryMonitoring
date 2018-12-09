{:ok, conn} = Mongo.start_link(url: "mongodb://localhost:27017/test")

cursor = Mongo.find(conn, "test-collection", %{})

cursor |> Enum.to_list() |> IO.inspect