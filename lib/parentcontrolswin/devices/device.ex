defmodule Parentcontrolswin.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "devices" do
    field :name, :string
    field :is_allowed_schedule, :map, default: %{}
    field :timezone, :string, default: ""
    belongs_to :user, Parentcontrolswin.Users.User, type: :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:name, :user_id, :is_allowed_schedule, :timezone])
    |> validate_required([:name, :user_id]) # , :is_allowed_schedule, :timezone
    |> validate_timezone()
  end

  @doc false
  defp validate_timezone(changeset) do
    validate_change(changeset, :timezone, fn :timezone, value ->
      cond do
        String.trim(value) == "" -> []
        String.trim(value) == nil -> []
        not Timex.Timezone.exists?(value) -> [timezone: "zone doesn't exist"]
        true -> []
      end
    end)
  end
end
