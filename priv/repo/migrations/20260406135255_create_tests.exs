defmodule Aptitude.Repo.Migrations.CreateTests do
  use Ecto.Migration

  def change do
    create table(:tests) do
      add :candidate_email, :string, null: false
      add :sector, :string, null: false
      add :difficulty, :string, null: false
      add :time_limit, :integer, null: false
      add :question_count, :integer, null: false
      add :token, :string, null: false
      add :status, :string, default: "sent", null: false
      add :started_at, :utc_datetime
      add :submitted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tests, [:token])
    create index(:tests, [:candidate_email])
  end
end
