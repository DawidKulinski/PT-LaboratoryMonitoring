defmodule ControllstationWeb.PageView do
  use ControllstationWeb, :view

  def activeusers(conn) do
    case conn.assigns[:activeusers] do
      nil -> ""
      activeusers -> activeusers
    end
  end

  def processes(conn) do
    case conn.assigns[:processes] do
      nil -> ""
      processes -> processes
    end
  end


end
