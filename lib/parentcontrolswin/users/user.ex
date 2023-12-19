defmodule Parentcontrolswin.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  schema "users" do
    pow_user_fields()
    field :content_filters, :string

    timestamps()
  end
end
