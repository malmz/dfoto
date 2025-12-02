defmodule DfotoWeb.Router do
  use DfotoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DfotoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :media do
    plug :fetch_session
  end

  scope "/auth", DfotoWeb do
    pipe_through :browser

    get "/authorize", AuthController, :authorize
    get "/callback", AuthController, :callback
    post "/callback", AuthController, :callback
  end

  scope "/admin", DfotoWeb.AlbumLive do
    pipe_through :browser

    live "/albums", Index, :index
    live "/albums/new", Form, :new
    live "/albums/:id/edit", Form, :edit

    live "/albums/:id", Show, :show
    live "/albums/:id/show/edit", Show, :edit
  end

  scope "/", DfotoWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/:album_id", PageController, :show
    get "/:album_id/:image_id", PageController, :image
  end

  # Other scopes may use custom stacks.
  # scope "/api", DfotoWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:dfoto, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DfotoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
