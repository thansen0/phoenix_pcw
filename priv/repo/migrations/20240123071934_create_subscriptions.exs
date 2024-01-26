defmodule Parentcontrolswin.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :stripe_customer_id, :string
      add :plan_tier, :integer
      add :start_date, :date
      add :end_date, :date
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:subscriptions, [:user_id])
  end
end
