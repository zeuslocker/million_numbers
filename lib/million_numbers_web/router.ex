defmodule MillionNumbersWeb.Router do
  use MillionNumbersWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MillionNumbersWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/foo/tables/source", NumbersController, :source)
    get("/bar/tables/dest", NumbersController, :dest)
  end

  # Other scopes may use custom stacks.
  # scope "/api", MillionNumbersWeb do
  #   pipe_through :api
  # end
end
