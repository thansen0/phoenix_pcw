import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :parentcontrolswin, ParentcontrolswinWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: [
      "http://parentcontrols.win", 
      "https://parentcontrols.win",
      "http://www.parentcontrols.win", 
      "https://www.parentcontrols.win",
      "https://parentcontrolswin.gigalixirapp.com/",
      "parentcontrols.win.gigalixirdns.com",
      "www.parentcontrols.win.gigalixirdns.com" # all of check_origin may be unnecessary 
  ]
  
config :parentcontrolswin, base_url: "https://www.parentcontrols.win"

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Parentcontrolswin.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

# Stripe API keys 
stripe_api_key = case System.fetch_env("STRIPE_API_SECRET") do
  {:ok, api_key} -> api_key
  :error -> raise "STRIPE_API_SECRET is not set"
end

stripe_webhook_key = case System.fetch_env("STRIPE_WEBHOOK_SIGNING_SECRET") do
  {:ok, api_key} -> api_key
  :error -> raise "STRIPE_WEBHOOK_SIGNING_SECRET is not set"
end

config :stripity_stripe,
  api_key: stripe_api_key,
  signing_secret: stripe_webhook_key,
  stripe_price_id: "price_1PV4BxDrVDu5S9fV3E9ud3mz",
  stripe_coupon_id: "PphOHwQP"

# Google Recaptcha API keys, indentical for dev and prod
recaptcha_public_key = case System.fetch_env("RECAPTCHA_PUBLIC_KEY") do
  {:ok, api_key} -> api_key
  :error -> raise "RECAPTCHA_PUBLIC_KEY is not set"
end

recaptcha_private_key = case System.fetch_env("RECAPTCHA_PRIVATE_KEY") do
  {:ok, api_key} -> api_key
  :error -> raise "RECAPTCHA_PRIVATE_KEY is not set"
end

config :recaptcha,
  public_key: recaptcha_public_key,
  secret: recaptcha_private_key