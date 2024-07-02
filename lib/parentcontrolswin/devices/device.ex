defmodule Parentcontrolswin.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "devices" do
    field :name, :string
    belongs_to :user, Parentcontrolswin.Users.User, type: :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
