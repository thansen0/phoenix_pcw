import Config

# Configure your database
config :parentcontrolswin, Parentcontrolswin.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "parentcontrolswin_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :parentcontrolswin, base_url: "http://localhost:4000"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :parentcontrolswin, ParentcontrolswinWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "MTI5Y/GnnF/UHTV1uyAb+NftfGrAqG71R1vyBOkFjPyZICV1Ok9yJ3gBGpcg0B/E",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :parentcontrolswin, ParentcontrolswinWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/parentcontrolswin_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :parentcontrolswin, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Stripe API keys 
stripe_api_key = System.get_env("STRIPE_API_SECRET") ||
    raise """
    environment variable STRIPE_API_KEY is missing.
    You can obtain it from the stripe dashboard: https://dashboard.stripe.com/test/apikeys
    """

stripe_webhook_key = System.get_env("STRIPE_WEBHOOK_SIGNING_SECRET") ||
    raise """
    environment variable STRIPE_WEBHOOK_SIGNING_SECRET is missing.
    You can obtain it from the stripe dashboard: https://dashboard.stripe.com/account/webhooks
    """

config :stripity_stripe,
  api_key: stripe_api_key,
  signing_secret: stripe_webhook_key,
  stripe_price_id: "price_1PV5i5DrVDu5S9fVbkx8aMgi",
  stripe_coupon_id: "VMkip7Cd"
