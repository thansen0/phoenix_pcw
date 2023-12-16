defmodule Parentcontrolswin.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :user_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
