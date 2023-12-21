defmodule Parentcontrolswin.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema,
    extensions: [PowPersistentSession]

  schema "users" do
    pow_user_fields()
    field :content_filters, :string, default: "nsfw,lgbt,trans"

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
  end
end
