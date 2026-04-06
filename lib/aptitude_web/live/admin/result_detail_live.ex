defmodule AptitudeWeb.Admin.ResultDetailLive do
  use AptitudeWeb, :live_view

  alias Aptitude.Tests

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {test, result} = Tests.get_test_with_result!(String.to_integer(id))

    {:ok,
     assign(socket,
       test: test,
       result: result,
       page_title: "Report — #{test.candidate_email}"
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

      <div class="space-y-4">
        <!-- Hero gradient card -->
        <div class="bg-indigo-600 rounded-2xl p-6 text-white shadow-sm">
          <p class="text-indigo-200 text-xs font-medium uppercase tracking-widest mb-2">
            Candidate Report
          </p>
          <h1 class="text-xl font-bold mb-1 truncate">{@test.candidate_email}</h1>
          <div class="flex flex-wrap items-center gap-2 text-indigo-200 text-sm">
            <span class="bg-white/10 px-2 py-0.5 rounded-lg">{String.capitalize(@test.sector)}</span>
            <span class="bg-white/10 px-2 py-0.5 rounded-lg">
              {String.capitalize(@test.difficulty)}
            </span>
            <span class="bg-white/10 px-2 py-0.5 rounded-lg">{@test.question_count} questions</span>
          </div>

          <div :if={@result} class="mt-6 flex items-end justify-between">
            <div>
              <p class="text-indigo-300 text-xs mb-1">Overall score</p>
              <p class="text-6xl font-black tabular-nums leading-none">
                {round(@result.score_percentage)}<span class="text-3xl text-indigo-300">%</span>
              </p>
            </div>
            <div class="text-right">
              <p class={[
                "text-2xl font-bold",
                hero_grade_color(@result.grade)
              ]}>
                {@result.grade}
              </p>
              <p class="text-indigo-200 text-sm mt-0.5">
                {@result.correct_count}/{@result.total_questions} correct
              </p>
            </div>
          </div>
        </div>

        <%= if @result do %>
          <!-- Score bar + stats -->
          <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
            <p class="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-4">
              Score breakdown
            </p>
            <div class="w-full bg-gray-100 rounded-full h-3 mb-1.5">
              <div
                class={["h-3 rounded-full transition-all", score_bar_color(@result.score_percentage)]}
                style={"width: #{@result.score_percentage}%"}
              >
              </div>
            </div>
            <div class="flex justify-between text-xs text-gray-300 mb-6">
              <span>0%</span>
              <span>100%</span>
            </div>
            <div class="grid grid-cols-3 gap-3">
              <div class="bg-emerald-50 rounded-xl p-4 text-center">
                <p class="text-2xl font-black text-emerald-600">{@result.correct_count}</p>
                <p class="text-xs text-emerald-500 font-medium mt-1">Correct</p>
              </div>
              <div class="bg-rose-50 rounded-xl p-4 text-center">
                <p class="text-2xl font-black text-rose-500">{@result.wrong_count || 0}</p>
                <p class="text-xs text-rose-400 font-medium mt-1">Wrong</p>
              </div>
              <div class="bg-gray-50 rounded-xl p-4 text-center">
                <p class="text-2xl font-black text-gray-400">{@result.skipped_count || 0}</p>
                <p class="text-xs text-gray-400 font-medium mt-1">Skipped</p>
              </div>
            </div>
          </div>
          
    <!-- Hiring recommendation -->
          <div
            :if={@result.hiring_recommendation}
            class={["rounded-2xl border p-5 shadow-sm", recommendation_bg(@result.grade)]}
          >
            <p class="text-xs font-semibold uppercase tracking-widest mb-2 opacity-60">
              Hiring Recommendation
            </p>
            <p class="text-sm font-semibold leading-relaxed">{@result.hiring_recommendation}</p>
          </div>
          
    <!-- Summary -->
          <div :if={@result.summary} class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
            <p class="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-3">
              Overall Assessment
            </p>
            <p class="text-sm text-gray-600 leading-relaxed">{@result.summary}</p>
          </div>
          
    <!-- Strengths & Weaknesses -->
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div
              :if={@result.strengths != []}
              class="bg-emerald-50 rounded-2xl border border-emerald-100 shadow-sm p-5"
            >
              <p class="text-xs font-semibold text-emerald-600 uppercase tracking-widest mb-3">
                Strengths
              </p>
              <ul class="space-y-2.5">
                <%= for s <- @result.strengths do %>
                  <li class="flex items-start gap-2.5 text-sm text-emerald-800">
                    <span class="w-5 h-5 bg-emerald-200 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                      <svg
                        class="w-3 h-3 text-emerald-700"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        stroke-width="3"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                    </span>
                    {s}
                  </li>
                <% end %>
              </ul>
            </div>

            <div
              :if={@result.weaknesses != []}
              class="bg-rose-50 rounded-2xl border border-rose-100 shadow-sm p-5"
            >
              <p class="text-xs font-semibold text-rose-600 uppercase tracking-widest mb-3">
                Weaknesses
              </p>
              <ul class="space-y-2.5">
                <%= for w <- @result.weaknesses do %>
                  <li class="flex items-start gap-2.5 text-sm text-rose-800">
                    <span class="w-5 h-5 bg-rose-200 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                      <svg
                        class="w-3 h-3 text-rose-600"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        stroke-width="3"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </span>
                    {w}
                  </li>
                <% end %>
              </ul>
            </div>
          </div>
          
    <!-- Red flags -->
          <div
            :if={
              @result.red_flags && @result.red_flags != [] &&
                @result.red_flags != ["None identified."]
            }
            class="bg-amber-50 rounded-2xl border border-amber-200 shadow-sm p-5"
          >
            <p class="text-xs font-semibold text-amber-700 uppercase tracking-widest mb-3">
              Red Flags
            </p>
            <ul class="space-y-2.5">
              <%= for flag <- @result.red_flags do %>
                <li class="flex items-start gap-2.5 text-sm text-amber-800">
                  <span class="w-5 h-5 bg-amber-200 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                    <svg
                      class="w-3 h-3 text-amber-700"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                      stroke-width="3"
                    >
                      <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01" />
                    </svg>
                  </span>
                  {flag}
                </li>
              <% end %>
            </ul>
          </div>
          
    <!-- Sub-topic breakdown -->
          <div
            :if={@result.sub_topic_breakdown && @result.sub_topic_breakdown != []}
            class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6"
          >
            <p class="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-5">
              Sub-topic Breakdown
            </p>
            <div class="space-y-4">
              <%= for topic <- @result.sub_topic_breakdown do %>
                <% pct = topic["score_pct"] || 0 %>
                <div>
                  <div class="flex items-center justify-between mb-1.5">
                    <div class="flex items-center gap-2">
                      <span class="text-sm font-medium text-gray-700">{topic["sub_topic"]}</span>
                      <span class={[
                        "text-xs font-semibold px-2 py-0.5 rounded-lg",
                        performance_badge(topic["performance"])
                      ]}>
                        {topic["performance"]}
                      </span>
                    </div>
                    <span class="text-xs text-gray-400 tabular-nums">
                      {topic["correct"]}/{topic["total"]} · {pct}%
                    </span>
                  </div>
                  <div class="w-full bg-gray-100 rounded-full h-2">
                    <div
                      class={["h-2 rounded-full transition-all", score_bar_color(pct)]}
                      style={"width: #{pct}%"}
                    >
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
          
    <!-- Question-type breakdown -->
          <div
            :if={@result.question_type_breakdown && @result.question_type_breakdown != []}
            class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6"
          >
            <p class="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-4">
              Question Type Breakdown
            </p>
            <div class="divide-y divide-gray-50">
              <%= for qt <- @result.question_type_breakdown do %>
                <div class="flex items-center justify-between py-3">
                  <span class="text-sm text-gray-700">{qt["question_type"]}</span>
                  <div class="flex items-center gap-3">
                    <span class="text-xs text-gray-400 tabular-nums">
                      {qt["correct"]}/{qt["total"]}
                    </span>
                    <span class={[
                      "text-xs font-bold tabular-nums",
                      score_text_color(qt["score_pct"] || 0)
                    ]}>
                      {qt["score_pct"]}%
                    </span>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
          
    <!-- Interviewer probe questions -->
          <div
            :if={@result.interviewer_probe_questions && @result.interviewer_probe_questions != []}
            class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6"
          >
            <p class="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-5">
              Interviewer Probe Questions
            </p>
            <div class="space-y-4">
              <%= for {probe, i} <- Enum.with_index(@result.interviewer_probe_questions, 1) do %>
                <div class="bg-indigo-50/60 rounded-xl border border-indigo-100/60 p-4">
                  <div class="flex items-start gap-3">
                    <span class="inline-flex items-center justify-center w-6 h-6 rounded-lg bg-indigo-500 text-white text-xs font-bold flex-shrink-0 mt-0.5">
                      {i}
                    </span>
                    <div class="space-y-1.5">
                      <p class="text-xs font-semibold text-indigo-600">{probe["area"]}</p>
                      <p class="text-xs text-gray-400 italic">{probe["context"]}</p>
                      <p class="text-sm text-gray-800 font-medium">"{probe["probe_question"]}"</p>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
          
    <!-- Wrong answers detail -->
          <div
            :if={@result.wrong_answers_detail && @result.wrong_answers_detail != []}
            class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6"
          >
            <p class="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-5">
              Wrong & Skipped Answers
            </p>
            <div class="space-y-3">
              <%= for item <- @result.wrong_answers_detail do %>
                <div class="border border-gray-100 rounded-xl p-4 space-y-2.5">
                  <div class="flex items-center gap-2">
                    <span class="text-xs font-medium text-gray-400 uppercase tracking-wide">
                      {item["sub_topic"]}
                    </span>
                    <%= if item["was_skipped"] do %>
                      <span class="text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded-lg font-medium">
                        Skipped
                      </span>
                    <% else %>
                      <span class="text-xs bg-rose-100 text-rose-600 px-2 py-0.5 rounded-lg font-medium">
                        Wrong
                      </span>
                    <% end %>
                  </div>
                  <p class="text-sm text-gray-800 font-medium">{item["question"]}</p>
                  <div class="space-y-1.5 mt-1">
                    <div class="flex items-start gap-2.5 text-xs">
                      <span class="inline-flex items-center justify-center w-5 h-5 rounded-lg bg-emerald-100 text-emerald-700 font-bold flex-shrink-0 mt-0.5">
                        {item["correct_answer"]}
                      </span>
                      <span class="text-emerald-700 font-medium">
                        {item["correct_answer_text"] || item["correct_answer"]}
                      </span>
                    </div>
                    <%= if !item["was_skipped"] do %>
                      <div class="flex items-start gap-2.5 text-xs">
                        <span class="inline-flex items-center justify-center w-5 h-5 rounded-lg bg-rose-100 text-rose-600 font-bold flex-shrink-0 mt-0.5">
                          {item["candidate_answer"]}
                        </span>
                        <span class="text-rose-500 line-through">
                          {item["candidate_answer_text"] || item["candidate_answer"]}
                        </span>
                      </div>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        <% else %>
          <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-16 text-center">
            <div class="w-12 h-12 bg-gray-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <svg
                class="w-6 h-6 text-gray-300"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="1.5"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <p class="text-sm text-gray-400">
              The report is not available yet. The test may still be in progress.
            </p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp score_bar_color(pct) when pct >= 70, do: "bg-emerald-500"
  defp score_bar_color(pct) when pct >= 40, do: "bg-amber-400"
  defp score_bar_color(_), do: "bg-rose-400"

  defp score_text_color(pct) when pct >= 70, do: "text-emerald-600"
  defp score_text_color(pct) when pct >= 40, do: "text-amber-500"
  defp score_text_color(_), do: "text-rose-500"

  defp hero_grade_color("Distinction"), do: "text-emerald-300"
  defp hero_grade_color("Pass"), do: "text-sky-300"
  defp hero_grade_color("Borderline"), do: "text-amber-300"
  defp hero_grade_color(_), do: "text-rose-300"

  defp recommendation_bg("Distinction"), do: "bg-emerald-50 border-emerald-200 text-emerald-900"
  defp recommendation_bg("Pass"), do: "bg-sky-50 border-sky-200 text-sky-900"
  defp recommendation_bg("Borderline"), do: "bg-amber-50 border-amber-200 text-amber-900"
  defp recommendation_bg(_), do: "bg-rose-50 border-rose-200 text-rose-900"

  defp performance_badge("Strong"), do: "bg-emerald-100 text-emerald-700"
  defp performance_badge("Moderate"), do: "bg-amber-100 text-amber-700"
  defp performance_badge(_), do: "bg-rose-100 text-rose-600"
end
