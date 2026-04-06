defmodule Aptitude.Tests.Question do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aptitude.Tests.Test

  schema "questions" do
    field :body, :string
    field :options, {:array, :string}
    field :correct_answer, :string
    field :position, :integer

    belongs_to :test, Test

    timestamps(type: :utc_datetime)
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:body, :options, :correct_answer, :position, :test_id])
    |> validate_required([:body, :options, :correct_answer, :position, :test_id])
  end
end
