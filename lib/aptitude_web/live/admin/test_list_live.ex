defmodule AptitudeWeb.Admin.TestListLive do
  use AptitudeWeb, :live_view

  alias Aptitude.{Tests, OpenAI}

  @impl true
  def mount(_params, _session, socket) do
    tests = Tests.list_tests_for_user(socket.assigns.current_user.id)
    {:ok, assign(socket, tests: tests, generating_for: nil, page_title: "Tests")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Tests</h1>
          <p class="text-sm text-gray-400 mt-1">Manage and monitor all aptitude tests</p>
        </div>
        <div class="flex items-center gap-3">
          <.link
            href={~p"/users/log_out"}
            method="delete"
            class="text-sm text-gray-400 hover:text-gray-600 transition-colors"
          >
            Log out
          </.link>
          <.link
            navigate={~p"/admin/tests/new"}
            class="inline-flex items-center gap-2 bg-indigo-600 text-white text-sm font-semibold px-4 py-2.5 rounded-xl shadow-sm hover:bg-indigo-500 transition-colors"
          >
            <svg
              class="w-4 h-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2.5"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
            </svg>
            New test
          </.link>
        </div>
      </div>

      <%= if @tests == [] do %>
        <div class="text-center py-24 bg-white rounded-2xl border border-gray-100 shadow-sm">
          <div class="w-14 h-14 bg-indigo-50 rounded-2xl flex items-center justify-center mx-auto mb-5">
            <svg
              class="w-7 h-7 text-indigo-400"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="1.5"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
          </div>
          <h3 class="text-sm font-semibold text-gray-900 mb-1">No tests yet</h3>
          <p class="text-sm text-gray-400 mb-7">Create your first test to get started.</p>
          <.link
            navigate={~p"/admin/tests/new"}
            class="inline-flex items-center gap-2 bg-indigo-600 text-white text-sm font-semibold px-5 py-2.5 rounded-xl shadow-sm hover:bg-indigo-500 transition-colors"
          >
            Create a test
          </.link>
        </div>
      <% else %>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for test <- @tests do %>
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition-all duration-200 p-5 flex flex-col">
              <!-- Candidate avatar + info -->
              <div class="flex items-start gap-3 mb-4">
                <div class={[
                  "w-10 h-10 rounded-xl flex items-center justify-center text-sm font-bold text-white flex-shrink-0 shadow-sm",
                  avatar_gradient(test.candidate_email)
                ]}>
                  {String.upcase(String.slice(test.candidate_email, 0, 1))}
                </div>
                <div class="min-w-0 flex-1">
                  <p class="text-sm font-semibold text-gray-900 truncate">{test.candidate_email}</p>
                  <p class="text-xs text-gray-400 mt-0.5">{String.capitalize(test.sector)}</p>
                </div>
              </div>
              
    <!-- Badges -->
              <div class="flex flex-wrap items-center gap-2 mb-5">
                <span class={[
                  "text-xs font-semibold px-2.5 py-1 rounded-lg",
                  difficulty_color(test.difficulty)
                ]}>
                  {String.capitalize(test.difficulty)}
                </span>
                <span class={[
                  "inline-flex items-center gap-1.5 text-xs font-medium px-2.5 py-1 rounded-lg",
                  status_bg(test.status)
                ]}>
                  <span class={["w-1.5 h-1.5 rounded-full", status_dot(test.status)]}></span>
                  {status_label(test.status)}
                </span>
                <span class="text-xs text-gray-300 ml-auto">{test.question_count} Qs</span>
              </div>
              
    <!-- Footer -->
              <div class="mt-auto pt-4 border-t border-gray-50 flex items-center justify-between">
                <p class="text-xs text-gray-400">
                  {Calendar.strftime(to_eat(test.inserted_at), "%d %b %Y, %H:%M")} EAT
                </p>

                <%= cond do %>
                  <% @generating_for == test.id -> %>
                    <span class="inline-flex items-center gap-1.5 text-xs text-gray-400">
                      <svg class="animate-spin w-3.5 h-3.5" fill="none" viewBox="0 0 24 24">
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
                      Generating…
                    </span>
                  <% test.status == "completed" && test.result != nil -> %>
                    <.link
                      navigate={~p"/admin/tests/#{test.id}/result"}
                      class="inline-flex items-center gap-1 text-xs font-semibold text-indigo-600 bg-indigo-50 hover:bg-indigo-100 px-3 py-1.5 rounded-lg transition-colors"
                    >
                      View report
                      <svg
                        class="w-3 h-3"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        stroke-width="2.5"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
                      </svg>
                    </.link>
                  <% test.status == "completed" && test.result == nil -> %>
                    <button
                      phx-click="generate_report"
                      phx-value-id={test.id}
                      disabled={@generating_for != nil}
                      class="inline-flex items-center gap-1 text-xs font-semibold text-amber-600 bg-amber-50 hover:bg-amber-100 px-3 py-1.5 rounded-lg disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                    >
                      Generate report
                    </button>
                  <% true -> %>
                    <.link
                      navigate={~p"/admin/tests/#{test.id}"}
                      class="inline-flex items-center gap-1 text-xs font-semibold text-gray-500 bg-gray-100 hover:bg-gray-200 px-3 py-1.5 rounded-lg transition-colors"
                    >
                      View test
                    </.link>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("generate_report", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)
    send(self(), {:do_generate_report, id})
    {:noreply, assign(socket, generating_for: id)}
  end

  @impl true
  def handle_info({:do_generate_report, test_id}, socket) do
    test = Tests.get_test!(test_id)
    questions = Tests.list_questions(test_id)

    answers_map =
      test_id
      |> Tests.list_answers()
      |> Enum.into(%{}, fn a -> {a.question_id, a.selected_answer} end)

    case OpenAI.analyse_results(test.sector, test.difficulty, questions, answers_map) do
      {:ok, report} ->
        Tests.create_result(%{
          test_id: test_id,
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

        tests = Tests.list_tests_for_user(socket.assigns.current_user.id)

        {:noreply,
         socket
         |> assign(generating_for: nil, tests: tests)
         |> push_navigate(to: ~p"/admin/tests/#{test_id}/result")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> assign(generating_for: nil)
         |> put_flash(:error, "Failed to generate report. Please try again.")}
    end
  end

  defp avatar_gradient(email) do
    colors = [
      "bg-indigo-500",
      "bg-rose-500",
      "bg-emerald-500",
      "bg-amber-500",
      "bg-sky-500",
      "bg-purple-500"
    ]

    idx = :erlang.phash2(email, length(colors))
    Enum.at(colors, idx)
  end

  defp difficulty_color("easy"), do: "bg-emerald-50 text-emerald-700"
  defp difficulty_color("medium"), do: "bg-amber-50 text-amber-700"
  defp difficulty_color("hard"), do: "bg-rose-50 text-rose-700"
  defp difficulty_color(_), do: "bg-gray-50 text-gray-600"

  defp status_bg("sent"), do: "bg-blue-50 text-blue-600"
  defp status_bg("in_progress"), do: "bg-amber-50 text-amber-600"
  defp status_bg("completed"), do: "bg-emerald-50 text-emerald-600"
  defp status_bg(_), do: "bg-gray-50 text-gray-500"

  defp status_dot("sent"), do: "bg-blue-500"
  defp status_dot("in_progress"), do: "bg-amber-500"
  defp status_dot("completed"), do: "bg-emerald-500"
  defp status_dot(_), do: "bg-gray-400"

  defp status_label("sent"), do: "Sent"
  defp status_label("in_progress"), do: "In Progress"
  defp status_label("completed"), do: "Completed"
  defp status_label(s), do: String.capitalize(s)

  defp to_eat(naive_dt), do: NaiveDateTime.add(naive_dt, 3 * 3600, :second)
end
