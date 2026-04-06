defmodule Aptitude.Tests.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aptitude.Tests.{Test, Question}

  schema "answers" do
    field :selected_answer, :string

    belongs_to :test, Test
    belongs_to :question, Question

    timestamps(type: :utc_datetime)
  end

  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:selected_answer, :test_id, :question_id])
    |> validate_required([:test_id, :question_id])
    |> unique_constraint([:test_id, :question_id])
  end
end
