defmodule AptitudeWeb.Admin.TestDetailLive do
  use AptitudeWeb, :live_view

  alias Aptitude.Tests
  alias Aptitude.Emails.TestInvitation

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {test, questions, answer_map} =
      Tests.get_test_with_questions_and_answers!(String.to_integer(id))

    {:ok,
     assign(socket,
       test: test,
       questions: questions,
       answer_map: answer_map,
       resending: false,
       resent: false,
       page_title: "Test — #{test.candidate_email}"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto">
      <.link
        navigate={~p"/admin"}
        class="inline-flex items-center gap-1.5 text-sm text-gray-400 hover:text-gray-600 transition-colors mb-6"
      >
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
        Back to tests
      </.link>
      
    <!-- Header card -->
      <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 mb-5">
        <div class="flex items-start justify-between gap-4">
          <div>
            <p class="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-1">
              Test Overview
            </p>
            <h1 class="text-lg font-bold text-gray-900 truncate">{@test.candidate_email}</h1>
            <div class="flex flex-wrap items-center gap-2 mt-2">
              <span class="text-xs bg-gray-100 text-gray-600 font-medium px-2.5 py-1 rounded-lg">
                {String.capitalize(@test.sector)}
              </span>
              <span class={[
                "text-xs font-semibold px-2.5 py-1 rounded-lg",
                difficulty_color(@test.difficulty)
              ]}>
                {String.capitalize(@test.difficulty)}
              </span>
              <span class={[
                "inline-flex items-center gap-1.5 text-xs font-medium px-2.5 py-1 rounded-lg",
                status_bg(@test.status)
              ]}>
                <span class={["w-1.5 h-1.5 rounded-full", status_dot(@test.status)]}></span>
                {status_label(@test.status)}
              </span>
            </div>
          </div>
          <div class="text-right flex-shrink-0">
            <p class="text-xs text-gray-400">{@test.question_count} questions</p>
            <p class="text-xs text-gray-400 mt-0.5">{@test.time_limit} min</p>
          </div>
        </div>

        <div class="mt-4 pt-4 border-t border-gray-50 flex items-center gap-3 flex-wrap">
          <%= if @test.status == "completed" do %>
            <.link
              navigate={~p"/admin/tests/#{@test.id}/result"}
              class="inline-flex items-center gap-1.5 text-xs font-semibold text-indigo-600 bg-indigo-50 hover:bg-indigo-100 px-3 py-1.5 rounded-lg transition-colors"
            >
              View full report
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
          <% end %>

          <%= if @test.status in ["sent", "in_progress"] do %>
            <%= if @resent do %>
              <span class="inline-flex items-center gap-1.5 text-xs font-semibold text-emerald-600 bg-emerald-50 px-3 py-1.5 rounded-lg">
                <svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                </svg>
                Invitation resent
              </span>
            <% else %>
              <button
                phx-click="resend_invitation"
                disabled={@resending}
                class="inline-flex items-center gap-1.5 text-xs font-semibold text-gray-600 bg-gray-100 hover:bg-gray-200 px-3 py-1.5 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <%= if @resending do %>
                  <svg class="animate-spin w-3 h-3" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                  Sending…
                <% else %>
                  <svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                  Resend invitation
                <% end %>
              </button>
            <% end %>
          <% end %>
        </div>
      </div>
      
    <!-- Legend -->
      <div class="flex items-center gap-4 mb-4 px-1">
        <div class="flex items-center gap-1.5 text-xs text-gray-500">
          <span class="w-3 h-3 rounded-sm bg-emerald-100 border border-emerald-300 flex-shrink-0">
          </span>
          Correct answer
        </div>
        <%= if @test.status in ["in_progress", "completed"] do %>
          <div class="flex items-center gap-1.5 text-xs text-gray-500">
            <span class="w-3 h-3 rounded-sm bg-rose-100 border border-rose-300 flex-shrink-0"></span>
            Candidate's wrong answer
          </div>
          <div class="flex items-center gap-1.5 text-xs text-gray-500">
            <span class="w-3 h-3 rounded-sm bg-sky-100 border border-sky-300 flex-shrink-0"></span>
            Candidate's correct answer
          </div>
        <% end %>
      </div>
      
    <!-- Questions -->
      <%= if @questions == [] do %>
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-12 text-center">
          <p class="text-sm text-gray-400">Questions are still being generated…</p>
        </div>
      <% else %>
        <div class="space-y-4">
          <%= for {question, idx} <- Enum.with_index(@questions, 1) do %>
            <% candidate_answer = Map.get(@answer_map, question.id) %>
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
              <p class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">
                Question {idx}
              </p>
              <p class="text-sm font-semibold text-gray-900 mb-4">{question.body}</p>

              <div class="space-y-2">
                <%= for option <- question.options do %>
                  <% letter = String.first(option) %>
                  <% is_correct = letter == question.correct_answer %>
                  <% is_candidate = candidate_answer && letter == candidate_answer %>
                  <% is_candidate_correct = is_candidate && is_correct %>
                  <% is_candidate_wrong = is_candidate && !is_correct %>

                  <div class={[
                    "flex items-start gap-3 px-3.5 py-2.5 rounded-xl border text-sm transition-colors",
                    cond do
                      is_candidate_correct -> "bg-sky-50 border-sky-200 text-sky-900"
                      is_candidate_wrong -> "bg-rose-50 border-rose-200 text-rose-900"
                      is_correct -> "bg-emerald-50 border-emerald-200 text-emerald-900"
                      true -> "bg-gray-50 border-gray-100 text-gray-600"
                    end
                  ]}>
                    <span class={[
                      "inline-flex items-center justify-center w-6 h-6 rounded-lg text-xs font-bold flex-shrink-0 mt-0.5",
                      cond do
                        is_candidate_correct -> "bg-sky-200 text-sky-800"
                        is_candidate_wrong -> "bg-rose-200 text-rose-700"
                        is_correct -> "bg-emerald-200 text-emerald-700"
                        true -> "bg-gray-200 text-gray-500"
                      end
                    ]}>
                      {letter}
                    </span>
                    <span class="flex-1">{String.slice(option, 3, String.length(option))}</span>
                    <%= if is_correct do %>
                      <svg
                        class="w-4 h-4 text-emerald-500 flex-shrink-0 mt-0.5"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        stroke-width="2.5"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                    <% end %>
                    <%= if is_candidate_wrong do %>
                      <svg
                        class="w-4 h-4 text-rose-400 flex-shrink-0 mt-0.5"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        stroke-width="2.5"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    <% end %>
                  </div>
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
  def handle_event("resend_invitation", _params, socket) do
    test = socket.assigns.test
    socket = assign(socket, resending: true)
    send(self(), {:do_resend, test})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:do_resend, test}, socket) do
    TestInvitation.send_invitation(test)
    {:noreply, assign(socket, resending: false, resent: true)}
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
end
