defmodule Aptitude.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :test_id, references(:tests, on_delete: :delete_all), null: false
      add :question_id, references(:questions, on_delete: :delete_all), null: false
      add :selected_answer, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:answers, [:test_id, :question_id])
    create index(:answers, [:test_id])
  end
end
