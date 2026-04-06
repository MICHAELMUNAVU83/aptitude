defmodule Aptitude.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :test_id, references(:tests, on_delete: :delete_all), null: false
      add :body, :text, null: false
      add :options, {:array, :string}, null: false
      add :correct_answer, :string, null: false
      add :position, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:questions, [:test_id])
  end
end
