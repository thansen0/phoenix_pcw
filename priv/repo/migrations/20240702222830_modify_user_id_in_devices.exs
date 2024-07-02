defmodule Parentcontrolswin.Repo.Migrations.ModifyUserIdInDevices do
  use Ecto.Migration

  def change do

    # create temporary table column
    execute "ALTER TABLE devices RENAME COLUMN user_id TO old_user_id"

    alter table(:devices) do
      # Add the new column with references
      # note: I added null: false and removed type: :integer
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    # Step 3: Copy the data from old_user_id to user_id
    execute "UPDATE devices SET user_id = old_user_id"

    alter table(:devices) do
      # Step 4: Drop the old column
      remove :old_user_id
    end
  end
end
