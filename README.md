# Parentcontrolswin

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Commands

These are all the commands I've run which build things (gen.phx.html, live, etc). Consider `--binary-id` in the future if I retry building it

```
mix phx.new parentcontrolswin # add no tailwind in future?
mix pow.install Users.User users content_filters:string
mix pow.phoenix.gen.templates
mix phx.gen.html Devices Device devices name:string user_id:integer --binary-id
```