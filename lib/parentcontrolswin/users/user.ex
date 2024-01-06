defmodule Parentcontrolswin.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema,
    extensions: [PowPersistentSession, PowResetPassword]
  require Logger

  schema "users" do
    pow_user_fields()
    field :content_filters, :string, default: "nsfw,lgbt,trans"
    field :terms_of_service, :boolean
    field :privacy_policy, :boolean

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    Logger.info(IO.inspect(attrs))
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
    |> Ecto.Changeset.cast(attrs, [:content_filters, :terms_of_service, :privacy_policy])
    |> validate_must_be_true(:terms_of_service, "You must agree to the Terms of Service.")
    |> validate_must_be_true(:privacy_policy, "You must agree to the Privacy Policy.")
  end

  defp validate_must_be_true(changeset, field, error_message) do
    current_value = Ecto.Changeset.get_field(changeset, field)
    change_value = Ecto.Changeset.get_change(changeset, field)

    case change_value || current_value do
      true -> changeset
      _ -> Ecto.Changeset.add_error(changeset, field, error_message)
    end
  end
end
