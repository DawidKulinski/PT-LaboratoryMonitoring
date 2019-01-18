defmodule ControllstationWeb.Router do
  use ControllstationWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ControllstationWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/get_file", PageController, :get_file
    get "/block_process", PageController, :block_process
  end

  # Other scopes may use custom stacks.
  # scope "/api", ControllstationWeb do
  #   pipe_through :api
  # end
end
