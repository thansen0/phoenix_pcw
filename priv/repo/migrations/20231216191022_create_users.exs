defmodule Parentcontrolswin.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string
      add :content_filters, :string
      add :stripe_customer_id, :string
      add :terms_of_service, :boolean
      add :privacy_policy, :boolean

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
