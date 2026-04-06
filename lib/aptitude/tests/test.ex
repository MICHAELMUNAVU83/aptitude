defmodule Aptitude.Tests.Test do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aptitude.Tests.{Question, Answer, Result}
  alias Aptitude.Accounts.User

  schema "tests" do
    field :candidate_email, :string
    field :sector, :string
    field :difficulty, :string
    field :time_limit, :integer
    field :question_count, :integer
    field :token, :string
    field :status, :string, default: "sent"
    field :started_at, :utc_datetime
    field :submitted_at, :utc_datetime

    belongs_to :user, User
    has_many :questions, Question
    has_many :answers, Answer
    has_one :result, Result

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(test, attrs) do
    test
    |> cast(attrs, [
      :candidate_email,
      :sector,
      :difficulty,
      :time_limit,
      :question_count,
      :token,
      :status,
      :started_at,
      :submitted_at,
      :user_id
    ])
    |> validate_required([:candidate_email, :sector, :difficulty, :time_limit, :question_count])
    |> validate_format(:candidate_email, ~r/@/)
    |> validate_inclusion(:difficulty, ["easy", "medium", "hard"])
    |> validate_number(:time_limit, greater_than: 0)
    |> validate_number(:question_count, greater_than: 0)
    |> unique_constraint(:token)
  end

  def creation_changeset(test, attrs) do
    token = :crypto.strong_rand_bytes(24) |> Base.url_encode64(padding: false)

    test
    |> changeset(attrs)
    |> put_change(:token, token)
    |> put_change(:status, "sent")
  end
end
