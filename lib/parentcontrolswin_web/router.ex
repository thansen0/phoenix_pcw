defmodule ParentcontrolswinWeb.Router do
  use ParentcontrolswinWeb, :router
  use Pow.Phoenix.Router
  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowPersistentSession]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ParentcontrolswinWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :require_auth do
    plug Pow.Plug.RequireAuthenticated, [error_handler: ParentcontrolswinWeb.AuthErrorHandler]
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ParentcontrolswinWeb.APIAuthPlug, otp_app: :parentcontrolswin
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: ParentcontrolswinWeb.APIAuthErrorHandler
  end

  scope "/" do
    pipe_through :browser

    post "/registration", ParentcontrolswinWeb.RegistrationController, :create

    pow_routes()
    pow_extension_routes()
  end

  scope "/", ParentcontrolswinWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/contact", PageController, :contact
    get "/learn", PageController, :learn # for political
    get "/intake", PageController, :learn
    get "/ad_intake", PageController, :learn
    get "/learnmore", PageController, :learnmore # for non political
    get "/install_pcw", PageController, :install_pcw
    get "/open_source", PageController, :open_source
    get "/privacy_policy", PageController, :privacy_policy
    get "/nsfw_ad_intake", PageController, :nsfw_ad_intake
    get "/time_limit_reached", PageController, :time_limit_reached
    get "/content_filter_faq", PageController, :content_filter_faq
    get "/downloads/terms_of_service", PageController, :terms_of_service
  end

  scope "/", ParentcontrolswinWeb do
    pipe_through [:browser, :require_auth]

    get "/downloads", PageController, :downloads
    get "/downloads/installer_download", PageController, :installer_download
    resources "/devices", DeviceController, except: [:create]
    post "/device_form_action", DeviceController, :checkbox_form_submission
    post "/update_allowed_hours", DeviceController, :updateallowedhours

    get "/subscriptions", SubscriptionController, :index

    post "/subscriptions/new", SubscriptionController, :new
    get "/subscriptions/new/success", SubscriptionController, :success
    get "/subscriptions/new/cancel", SubscriptionController, :cancel
    post "/subscriptions/manage", SubscriptionController, :edit
  end

  scope "/api/v1", ParentcontrolswinWeb do
    pipe_through [:api, :api_protected]

    resources "/devices", DeviceController
  end

  scope "/api/v1", ParentcontrolswinWeb.API.V1, as: :api_v1 do
    pipe_through :api

#    resources "/registration", RegistrationController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
  end

  scope "/api/v1", ParentcontrolswinWeb.API.V1, as: :api_v1 do
    pipe_through [:api, :api_protected]

    # Your protected API endpoints here
    get "/getContentFilters", SessionController, :getContentFilters
  end

  scope "/api/v1", ParentcontrolswinWeb.API.V1, as: :api_v1 do
    pipe_through [:api]

    # Your protected API endpoints here
    get "/getURDeviceInfo", SessionController, :getURDeviceInfo
  end

  # Other scopes may use custom stacks.
  # scope "/api", ParentcontrolswinWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:parentcontrolswin, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ParentcontrolswinWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
