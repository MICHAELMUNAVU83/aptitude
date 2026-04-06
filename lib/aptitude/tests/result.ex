defmodule Aptitude.Tests.Result do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aptitude.Tests.Test

  schema "results" do
    field :score_percentage, :float
    field :correct_count, :integer
    field :wrong_count, :integer
    field :skipped_count, :integer
    field :total_questions, :integer
    field :grade, :string
    field :hiring_recommendation, :string
    field :strengths, {:array, :string}, default: []
    field :weaknesses, {:array, :string}, default: []
    field :red_flags, {:array, :string}, default: []
    field :summary, :string
    field :sub_topic_breakdown, {:array, :map}, default: []
    field :question_type_breakdown, {:array, :map}, default: []
    field :wrong_answers_detail, {:array, :map}, default: []
    field :interviewer_probe_questions, {:array, :map}, default: []

    belongs_to :test, Test

    timestamps(type: :utc_datetime)
  end

  def changeset(result, attrs) do
    result
    |> cast(attrs, [
      :score_percentage, :correct_count, :wrong_count, :skipped_count,
      :total_questions, :grade, :hiring_recommendation,
      :strengths, :weaknesses, :red_flags, :summary,
      :sub_topic_breakdown, :question_type_breakdown,
      :wrong_answers_detail, :interviewer_probe_questions,
      :test_id
    ])
    |> validate_required([:score_percentage, :correct_count, :total_questions, :test_id])
    |> unique_constraint(:test_id)
  end
end
