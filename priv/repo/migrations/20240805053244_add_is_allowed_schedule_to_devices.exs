defmodule Parentcontrolswin.Repo.Migrations.AddIsAllowedScheduleToDevices do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :timezone, :string
      add :is_allowed_schedule, :map
    end
  end
end
