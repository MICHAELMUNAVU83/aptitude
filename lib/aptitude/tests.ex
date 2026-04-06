defmodule Aptitude.Tests do
  @moduledoc """
  The Tests context.
  """

  import Ecto.Query
  alias Aptitude.Repo
  alias Aptitude.Tests.{Test, Question, Answer, Result}

  # ---- Tests ----

  def list_tests do
    Repo.all(from t in Test, order_by: [desc: t.inserted_at], preload: [:result])
  end

  def list_tests_for_user(user_id) do
    Repo.all(
      from t in Test,
        where: t.user_id == ^user_id,
        order_by: [desc: t.inserted_at],
        preload: [:result]
    )
  end

  def get_test!(id), do: Repo.get!(Test, id)

  def get_test_by_token!(token) do
    Repo.get_by!(Test, token: token)
  end

  def get_test_with_questions!(token) do
    test = Repo.get_by!(Test, token: token) |> Repo.preload(:user)
    questions = Repo.all(from q in Question, where: q.test_id == ^test.id, order_by: q.position)
    %{test | questions: questions}
  end

  def create_test(attrs \\ %{}) do
    %Test{}
    |> Test.creation_changeset(attrs)
    |> Repo.insert()
  end

  def mark_started(test) do
    test
    |> Ecto.Changeset.change(
      started_at: DateTime.utc_now() |> DateTime.truncate(:second),
      status: "in_progress"
    )
    |> Repo.update()
  end

  def submit_test(test) do
    if test.submitted_at do
      {:already_submitted, test}
    else
      test
      |> Ecto.Changeset.change(
        submitted_at: DateTime.utc_now() |> DateTime.truncate(:second),
        status: "completed"
      )
      |> Repo.update()
    end
  end

  def time_remaining(test) do
    case test.started_at do
      nil ->
        test.time_limit * 60

      started_at ->
        elapsed = DateTime.diff(DateTime.utc_now(), started_at, :second)
        max(test.time_limit * 60 - elapsed, 0)
    end
  end

  # ---- Questions ----

  def create_questions(test, questions_data) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    entries =
      questions_data
      |> Enum.with_index(1)
      |> Enum.map(fn {q, idx} ->
        %{
          test_id: test.id,
          body: q["question"],
          options: q["options"],
          correct_answer: q["correct_answer"],
          position: idx,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(Question, entries, returning: true)
  end

  def list_questions(test_id) do
    Repo.all(from q in Question, where: q.test_id == ^test_id, order_by: q.position)
  end

  # ---- Answers ----

  def upsert_answer(test_id, question_id, selected_answer) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Repo.insert(
      %Answer{
        test_id: test_id,
        question_id: question_id,
        selected_answer: selected_answer
      },
      on_conflict: [set: [selected_answer: selected_answer, updated_at: now]],
      conflict_target: [:test_id, :question_id]
    )
  end

  def list_answers(test_id) do
    Repo.all(from a in Answer, where: a.test_id == ^test_id)
  end

  def get_test_with_questions_and_answers!(id) do
    test = Repo.get!(Test, id)
    questions = Repo.all(from q in Question, where: q.test_id == ^id, order_by: q.position)
    answers = Repo.all(from a in Answer, where: a.test_id == ^id)
    answer_map = Map.new(answers, fn a -> {a.question_id, a.selected_answer} end)
    {test, questions, answer_map}
  end

  # ---- Results ----

  def create_result(attrs) do
    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert()
  end

  def get_result_for_test(test_id) do
    Repo.get_by(Result, test_id: test_id)
  end

  def get_test_with_result!(id) do
    test = Repo.get!(Test, id)
    result = get_result_for_test(test.id)
    {test, result}
  end
end
