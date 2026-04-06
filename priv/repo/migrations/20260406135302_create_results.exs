defmodule Aptitude.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :test_id, references(:tests, on_delete: :delete_all), null: false
      add :score_percentage, :float, null: false
      add :correct_count, :integer, null: false
      add :total_questions, :integer, null: false
      add :strengths, {:array, :string}, default: []
      add :weaknesses, {:array, :string}, default: []
      add :summary, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:results, [:test_id])
  end
end
