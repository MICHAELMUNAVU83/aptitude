defmodule Aptitude.Repo.Migrations.AddReportFieldsToResults do
  use Ecto.Migration

  def change do
    alter table(:results) do
      add :wrong_count, :integer
      add :skipped_count, :integer
      add :grade, :string
      add :hiring_recommendation, :text
      add :sub_topic_breakdown, {:array, :map}, default: []
      add :question_type_breakdown, {:array, :map}, default: []
      add :wrong_answers_detail, {:array, :map}, default: []
      add :interviewer_probe_questions, {:array, :map}, default: []
      add :red_flags, {:array, :string}, default: []
    end
  end
end
