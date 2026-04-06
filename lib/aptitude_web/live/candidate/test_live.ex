defmodule AptitudeWeb.Candidate.TestLive do
  use AptitudeWeb, :live_view

  alias Aptitude.{Tests, OpenAI}
  alias Aptitude.Emails.TestInvitation

  @timer_interval 1_000
  @autosave_interval 30_000

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    test = Tests.get_test_with_questions!(token)

    if test.submitted_at do
      {:ok, push_navigate(socket, to: ~p"/test/#{token}/done")}
    else
      questions = test.questions

      test =
        case test.started_at do
          nil ->
            {:ok, updated} = Tests.mark_started(test)
            updated

          _ ->
            test
        end

      time_remaining = Tests.time_remaining(test)
      answers = load_answers(test)

      if connected?(socket) do
        Process.send_after(self(), :tick, @timer_interval)
        Process.send_after(self(), :autosave, @autosave_interval)
      end

      {:ok,
       assign(socket,
         test: test,
         token: token,
         questions: questions,
         answers: answers,
         current_index: 0,
         time_remaining: time_remaining,
         submitting: false,
         page_title: "Aptitude Test"
       ), layout: false}
    end
  end

  defp load_answers(test) do
    test.id
    |> Tests.list_answers()
    |> Enum.into(%{}, fn a -> {a.question_id, a.selected_answer} end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="min-h-screen bg-gradient-to-br from-slate-50 via-white to-violet-50/30 flex flex-col"
      phx-window-keydown="keydown"
      phx-key=""
    >
      <!-- Top bar with timer -->
      <div class="bg-white/80 backdrop-blur-md border-b border-gray-100 sticky top-0 z-10">
        <div class=" mx-auto px-6 py-3.5 flex items-center justify-between">
          <div class="flex items-center gap-2.5">
            <div class="w-7 h-7 bg-gradient-to-br from-violet-500 to-indigo-600 rounded-lg flex items-center justify-center shadow-sm">
              <svg
                class="w-3.5 h-3.5 text-white"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="2.5"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"
                />
              </svg>
            </div>
            <span class="text-sm font-semibold text-gray-600">
              <span class="text-gray-900">{@current_index + 1}</span>
              <span class="text-gray-300">/ {length(@questions)}</span>
            </span>
          </div>

          <div class={[
            "flex items-center gap-2 px-3.5 py-2 rounded-xl",
            timer_bg(@time_remaining)
          ]}>
            <svg
              class="w-4 h-4 flex-shrink-0"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            <div class="flex flex-col items-end leading-none">
              <span class="text-xs font-medium opacity-70">Time remaining</span>
              <span class="text-base font-bold tabular-nums tracking-tight">
                {format_time(@time_remaining)}
              </span>
            </div>
          </div>
        </div>

    <!-- Progress bar -->
        <div class="w-full bg-gray-100 h-1">
          <div
            class="h-1 bg-gradient-to-r from-violet-500 to-indigo-500 transition-all duration-500"
            style={"width: #{progress_percent(@answers, @questions)}%"}
          >
          </div>
        </div>
      </div>

    <!-- Question area -->
      <div class="flex-1  w-full mx-auto px-6 py-10">
        <%= if length(@questions) > 0 do %>
          <% q = Enum.at(@questions, @current_index) %>
          <div class="mb-8">
            <p class="text-xs font-bold text-violet-500 mb-3 uppercase tracking-widest">
              Question {@current_index + 1}
            </p>
            <p class="text-xl font-semibold text-gray-900 leading-relaxed">{q.body}</p>
          </div>

          <div class="space-y-3">
            <%= for option <- q.options do %>
              <% letter = String.at(option, 0) %>
              <% selected = Map.get(@answers, q.id) == letter %>
              <button
                phx-click="select_answer"
                phx-value-question_id={q.id}
                phx-value-answer={letter}
                class={[
                  "w-full text-left px-5 py-4 rounded-2xl border-2 text-sm transition-all duration-150",
                  if(selected,
                    do: "border-violet-400 bg-violet-50 text-violet-900 shadow-sm shadow-violet-100",
                    else:
                      "border-gray-100 bg-white text-gray-700 hover:border-gray-200 hover:shadow-sm"
                  )
                ]}
              >
                <span class={[
                  "inline-flex items-center justify-center w-7 h-7 rounded-xl text-xs font-bold mr-3",
                  if(selected,
                    do: "bg-gradient-to-br from-violet-500 to-indigo-600 text-white shadow-sm",
                    else: "bg-gray-100 text-gray-400"
                  )
                ]}>
                  {letter}
                </span>
                {String.slice(option, 3..-1//1)}
              </button>
            <% end %>
          </div>

    <!-- Navigation -->
          <div class="flex items-center justify-between mt-10">
            <button
              phx-click="prev"
              disabled={@current_index == 0}
              class="inline-flex items-center gap-2 text-sm font-medium text-gray-400 hover:text-gray-600 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
            >
              <svg
                class="w-4 h-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="2"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
              </svg>
              Previous
            </button>

            <%= if @current_index < length(@questions) - 1 do %>
              <button
                phx-click="next"
                class="inline-flex items-center gap-2 text-sm font-bold text-white bg-gradient-to-br from-violet-500 to-indigo-600 px-5 py-2.5 rounded-xl shadow-sm hover:opacity-90 transition-opacity"
              >
                Next
                <svg
                  class="w-4 h-4"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  stroke-width="2.5"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                </svg>
              </button>
            <% else %>
              <button
                phx-click="submit_test"
                disabled={@submitting}
                class="inline-flex items-center gap-2 bg-gradient-to-br from-emerald-500 to-teal-600 text-white text-sm font-bold px-6 py-2.5 rounded-xl shadow-sm hover:opacity-90 disabled:opacity-60 disabled:cursor-not-allowed transition-opacity"
              >
                <%= if @submitting do %>
                  <svg class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
                    <circle
                      class="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      stroke-width="4"
                    />
                    <path
                      class="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
                    />
                  </svg>
                  Submitting…
                <% else %>
                  Submit test
                <% end %>
              </button>
            <% end %>
          </div>

    <!-- Question dots -->
          <div class="flex items-center justify-center gap-1.5 mt-10 flex-wrap">
            <%= for {q, idx} <- Enum.with_index(@questions) do %>
              <button
                phx-click="jump_to"
                phx-value-index={idx}
                class={[
                  "w-8 h-8 rounded-xl text-xs font-bold transition-all duration-150",
                  cond do
                    idx == @current_index ->
                      "bg-gradient-to-br from-violet-500 to-indigo-600 text-white shadow-sm"

                    Map.has_key?(@answers, q.id) ->
                      "bg-violet-100 text-violet-700"

                    true ->
                      "bg-white border border-gray-100 text-gray-400 hover:border-gray-200"
                  end
                ]}
              >
                {idx + 1}
              </button>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("select_answer", %{"question_id" => qid_str, "answer" => answer}, socket) do
    question_id = String.to_integer(qid_str)
    test = socket.assigns.test

    Tests.upsert_answer(test.id, question_id, answer)

    answers = Map.put(socket.assigns.answers, question_id, answer)
    {:noreply, assign(socket, answers: answers)}
  end

  def handle_event("next", _params, socket) do
    max = length(socket.assigns.questions) - 1
    next = min(socket.assigns.current_index + 1, max)
    {:noreply, assign(socket, current_index: next)}
  end

  def handle_event("prev", _params, socket) do
    prev = max(socket.assigns.current_index - 1, 0)
    {:noreply, assign(socket, current_index: prev)}
  end

  def handle_event("jump_to", %{"index" => idx_str}, socket) do
    {:noreply, assign(socket, current_index: String.to_integer(idx_str))}
  end

  def handle_event("submit_test", _params, socket) do
    socket = assign(socket, submitting: true)
    do_submit(socket)
  end

  def handle_event("keydown", %{"key" => "ArrowRight"}, socket) do
    handle_event("next", %{}, socket)
  end

  def handle_event("keydown", %{"key" => "ArrowLeft"}, socket) do
    handle_event("prev", %{}, socket)
  end

  def handle_event("keydown", _, socket), do: {:noreply, socket}

  @impl true
  def handle_info(:tick, socket) do
    time_remaining = socket.assigns.time_remaining - 1

    if time_remaining <= 0 do
      do_submit(assign(socket, time_remaining: 0, submitting: true))
    else
      Process.send_after(self(), :tick, @timer_interval)
      {:noreply, assign(socket, time_remaining: time_remaining)}
    end
  end

  def handle_info(:autosave, socket) do
    # answers are already saved on every select — this is a belt-and-suspenders no-op
    Process.send_after(self(), :autosave, @autosave_interval)
    {:noreply, socket}
  end

  defp do_submit(socket) do
    test = socket.assigns.test
    token = socket.assigns.token

    case Tests.submit_test(test) do
      {:already_submitted, _} ->
        {:noreply, push_navigate(socket, to: ~p"/test/#{token}/done")}

      {:ok, submitted_test} ->
        questions = socket.assigns.questions
        answers_map = socket.assigns.answers
        owner_email = test.user && test.user.email

        Task.start(fn ->
          # Send completion emails immediately
          TestInvitation.send_completion_to_candidate(submitted_test)

          if owner_email do
            TestInvitation.send_completion_to_owner(submitted_test, owner_email)
          end

          case OpenAI.analyse_results(
                 submitted_test.sector,
                 submitted_test.difficulty,
                 questions,
                 answers_map
               ) do
            {:ok, report} ->
              Tests.create_result(%{
                test_id: submitted_test.id,
                score_percentage: report["score_percentage"] * 1.0,
                correct_count: report["correct_count"],
                wrong_count: report["wrong_count"],
                skipped_count: report["skipped_count"],
                total_questions: report["total_questions"],
                grade: report["grade"],
                hiring_recommendation: report["hiring_recommendation"],
                strengths: report["strengths"] || [],
                weaknesses: report["weaknesses"] || [],
                red_flags: report["red_flags"] || [],
                summary: report["summary"],
                sub_topic_breakdown: report["sub_topic_breakdown"] || [],
                question_type_breakdown: report["question_type_breakdown"] || [],
                wrong_answers_detail: report["wrong_answers_detail"] || [],
                interviewer_probe_questions: report["interviewer_probe_questions"] || []
              })

            _ ->
              :ok
          end
        end)

        {:noreply, push_navigate(socket, to: ~p"/test/#{token}/done")}

      {:error, _} ->
        {:noreply, assign(socket, submitting: false)}
    end
  end

  defp format_time(secs) do
    mins = div(secs, 60)
    s = rem(secs, 60)
    :io_lib.format("~2..0B:~2..0B", [mins, s]) |> IO.iodata_to_binary()
  end

  defp timer_color(secs) when secs <= 60, do: "text-red-600"
  defp timer_color(secs) when secs <= 300, do: "text-amber-600"
  defp timer_color(_), do: "text-gray-700"

  defp timer_bg(secs) when secs <= 60, do: "bg-rose-50 text-rose-600"
  defp timer_bg(secs) when secs <= 300, do: "bg-amber-50 text-amber-600"
  defp timer_bg(_), do: "bg-gray-50 text-gray-700"

  defp progress_percent(_answers, questions) when length(questions) == 0, do: 0

  defp progress_percent(answers, questions) do
    answered = Enum.count(questions, fn q -> Map.has_key?(answers, q.id) end)
    round(answered / length(questions) * 100)
  end
end
