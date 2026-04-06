defmodule Aptitude.Repo.Migrations.AddUserIdToTests do
  use Ecto.Migration

  def change do
    alter table(:tests) do
      add :user_id, references(:users, on_delete: :delete_all), null: true
    end

    create index(:tests, [:user_id])
  end
end
