defmodule Parentcontrolswin.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema,
    extensions: [PowPersistentSession, PowResetPassword]

  schema "users" do
    pow_user_fields()
    field :content_filters, :string, default: "nsfw,lgbt,trans,atheism,drug,weed,alcohol,tobacco,antiwork,antiparent,shortvideo"
    field :stripe_customer_id, :string, default: nil
    field :terms_of_service, :boolean
    field :privacy_policy, :boolean
    has_many :devices, Parentcontrolswin.Devices.Device, on_delete: :delete_all

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
    |> Ecto.Changeset.cast(attrs, [:content_filters, :stripe_customer_id, :terms_of_service, :privacy_policy])
    |> validate_must_be_true(:terms_of_service, "You must agree to the Terms of Service.")
    |> validate_must_be_true(:privacy_policy, "You must agree to the Privacy Policy.")
  end

  def update_stripe_customer_id_changeset(user, attrs) do
    user
    |> Ecto.Changeset.cast(attrs, [:stripe_customer_id])
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
