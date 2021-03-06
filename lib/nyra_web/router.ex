defmodule NyraWeb.Router do
  use NyraWeb, :router

  alias NyraWeb.Live

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {NyraWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NyraWeb do
    pipe_through :browser

    # TODO get rid of this stuff as it won't be needed anymore.
    get "/a/:token", AuthController, :verify, as: :auth
    post "/a/destroy", AuthController, :destroy, as: :auth

    # # Development stuff.
    if Mix.env() == :dev do
      get "/s/d", AuthController, :destroy, as: :session
    end

    # Application pages.
    live "/app", AppLive, :index

    # Actual content pages.
    live "/", HomeLive, :index
    live "/about", AboutLive, :about
    live "/support", SupportLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", NyraWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: NyraWeb.Telemetry
    end

    forward "/mailbox", Bamboo.SentEmailViewerPlug
  end
end
