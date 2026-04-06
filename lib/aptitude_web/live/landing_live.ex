defmodule AptitudeWeb.LandingLive do
  use AptitudeWeb, :landing_live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Aptitude Test | AI-Powered Candidate Assessments",
       page_description:
         "Create aptitude tests for candidates, send secure test links instantly, and review AI-assisted hiring reports on Aptitude Test.",
       canonical_url: "https://aptitudetest.info"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative min-h-screen overflow-hidden bg-[radial-gradient(circle_at_top,_rgba(99,102,241,0.14),_transparent_32%),linear-gradient(180deg,#fffdf8_0%,#ffffff_58%,#f8fbff_100%)]">
      <div class="pointer-events-none absolute inset-x-0 top-0 h-64 bg-[radial-gradient(circle_at_20%_10%,rgba(251,191,36,0.18),transparent_32%),radial-gradient(circle_at_80%_0%,rgba(59,130,246,0.18),transparent_28%)]">
      </div>

      <header class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-4 sm:pt-6">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <.link navigate={~p"/"} class="inline-flex items-center gap-3 text-gray-900 self-start">
            <img
              src={~p"/images/logo.png"}
              alt="Aptitude Test logo"
              class="h-11 w-11 rounded-2xl object-contain bg-white/90 p-1.5 shadow-sm ring-1 ring-black/5"
            />
            <div>
              <p class="font-display text-lg font-bold leading-none">Aptitude Test</p>
              <p class="text-xs text-gray-500 mt-1">AI-powered hiring tests</p>
            </div>
          </.link>

          <div class="flex w-full items-center gap-3 sm:w-auto">
            <.link
              navigate={~p"/users/log_in"}
              class="flex-1 sm:flex-none inline-flex items-center justify-center text-sm font-semibold text-gray-700 border border-gray-200/80 bg-white/80 px-4 py-2.5 rounded-xl hover:border-gray-300 hover:text-gray-900 transition-colors"
            >
              Log in
            </.link>
            <.link
              navigate={~p"/users/register"}
              class="flex-1 sm:flex-none inline-flex items-center justify-center text-sm font-semibold bg-gray-900 text-white px-4 py-2.5 rounded-xl hover:bg-gray-800 transition-colors shadow-sm"
            >
              Sign up free
            </.link>
          </div>
        </div>
      </header>

      <section class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 sm:pt-14 pb-16 sm:pb-24">
        <div class="grid items-center gap-10 lg:grid-cols-[0.94fr_1.06fr] lg:gap-12 xl:gap-14">
          <div class="text-left">
            <div class="inline-flex items-center gap-2 rounded-full border border-indigo-200 bg-white/80 px-3 py-1.5 text-xs font-semibold text-indigo-700 shadow-sm">
              <span class="h-2 w-2 rounded-full bg-emerald-500"></span>
              Create, send, and score candidate assessments faster
            </div>

            <h1 class="font-display mt-5 text-4xl font-bold leading-[1.02] text-gray-950 sm:text-5xl lg:text-6xl">
              Hire with sharper signals, not longer interviews. FOR FREE !!
            </h1>

            <p class="mt-5 max-w-2xl text-base leading-7 text-gray-600 sm:text-lg">
              Generate role-specific aptitude tests, send branded links instantly, and review AI-assisted reports before the candidate ever enters the room.
            </p>

            <div class="mt-8 flex flex-col gap-3 sm:flex-row sm:items-center">
              <.link
                navigate={~p"/users/register"}
                class="inline-flex w-full sm:w-auto items-center justify-center rounded-2xl bg-indigo-600 px-6 py-3.5 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-indigo-500"
              >
                Get started for free
              </.link>
              <.link
                navigate={~p"/users/log_in"}
                class="inline-flex w-full sm:w-auto items-center justify-center rounded-2xl border border-gray-200 bg-white/85 px-6 py-3.5 text-sm font-semibold text-gray-700 transition-colors hover:border-gray-300 hover:text-gray-900"
              >
                See your dashboard
              </.link>
            </div>

            <div class="mt-8 grid grid-cols-1 gap-3 sm:grid-cols-3">
              <div class="rounded-2xl border border-gray-100 bg-white/90 p-4 shadow-sm">
                <p class="font-display text-2xl font-bold text-gray-950">3 steps</p>
                <p class="mt-1 text-sm text-gray-500">
                  Create the test, send the link, review the report.
                </p>
              </div>
              <div class="rounded-2xl border border-gray-100 bg-white/90 p-4 shadow-sm">
                <p class="font-display text-2xl font-bold text-gray-950">1 link</p>
                <p class="mt-1 text-sm text-gray-500">
                  Candidates start instantly without creating an account.
                </p>
              </div>
              <div class="rounded-2xl border border-gray-100 bg-white/90 p-4 shadow-sm">
                <p class="font-display text-2xl font-bold text-gray-950">AI report</p>
                <p class="mt-1 text-sm text-gray-500">
                  Scores, risks, strengths, and interviewer probes in one view.
                </p>
              </div>
            </div>
          </div>

          <div class="relative lg:pl-2 xl:pl-4">
            <div class="absolute -inset-4 rounded-[2rem] bg-gradient-to-br from-indigo-100/70 via-sky-100/60 to-amber-100/70 blur-2xl">
            </div>
            <div class="relative overflow-hidden rounded-[2rem] border border-gray-200/70 bg-white/95 p-4 shadow-[0_30px_80px_rgba(15,23,42,0.10)] sm:p-6">
              <div class="flex items-center justify-between border-b border-gray-100 pb-4">
                <div class="flex items-center gap-3">
                  <img
                    src={~p"/images/logo.png"}
                    alt="Aptitude Test logo"
                    class="h-10 w-10 rounded-2xl object-contain bg-indigo-50 p-1.5"
                  />
                  <div>
                    <p class="font-display text-sm font-bold text-gray-900">Candidate review</p>
                    <p class="text-xs text-gray-500">Software Engineering · Medium</p>
                  </div>
                </div>
                <span class="rounded-full bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-700">
                  82% score
                </span>
              </div>

              <div class="mt-5 grid gap-4 ">
                <div class="rounded-2xl bg-gray-50 p-4">
                  <p class="text-xs font-semibold uppercase tracking-[0.2em] text-gray-400">
                    Test flow
                  </p>
                  <div class="mt-4 space-y-3">
                    <div class="flex items-start gap-3">
                      <span class="mt-0.5 flex h-7 w-7 items-center justify-center rounded-xl bg-indigo-600 text-xs font-bold text-white">
                        1
                      </span>
                      <div>
                        <p class="text-sm font-semibold text-gray-900">AI generates the assessment</p>
                        <p class="mt-1 text-sm text-gray-500">
                          Set sector, difficulty, and time limit in under a minute.
                        </p>
                      </div>
                    </div>
                    <div class="flex items-start gap-3">
                      <span class="mt-0.5 flex h-7 w-7 items-center justify-center rounded-xl bg-gray-900 text-xs font-bold text-white">
                        2
                      </span>
                      <div>
                        <p class="text-sm font-semibold text-gray-900">
                          Candidate completes the timed test
                        </p>
                        <p class="mt-1 text-sm text-gray-500">
                          Answers save as they go, even if they refresh the page.
                        </p>
                      </div>
                    </div>
                    <div class="flex items-start gap-3">
                      <span class="mt-0.5 flex h-7 w-7 items-center justify-center rounded-xl bg-amber-500 text-xs font-bold text-white">
                        3
                      </span>
                      <div>
                        <p class="text-sm font-semibold text-gray-900">
                          You review the hiring report
                        </p>
                        <p class="mt-1 text-sm text-gray-500">
                          Use sub-topic breakdowns and probe questions in interviews.
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="rounded-2xl border border-indigo-100 bg-gradient-to-br from-indigo-50 via-white to-sky-50 p-4 xl:self-start">
                  <p class="text-xs font-semibold uppercase tracking-[0.2em] text-indigo-500">
                    Report snapshot
                  </p>
                  <div class="mt-4 rounded-2xl bg-white p-4 shadow-sm">
                    <div class="flex items-end justify-between">
                      <div>
                        <p class="text-xs text-gray-400">Hiring recommendation</p>
                        <p class="font-display text-xl font-bold text-gray-950">Strong pass</p>
                      </div>
                      <div class="rounded-xl bg-indigo-600 px-3 py-2 text-right text-white">
                        <p class="text-[11px] uppercase tracking-wide text-indigo-100">Score</p>
                        <p class="font-display text-lg font-bold">82%</p>
                      </div>
                    </div>
                    <div class="mt-4 space-y-3">
                      <div>
                        <p class="text-xs font-semibold text-gray-400">Strengths</p>
                        <p class="mt-1 text-sm text-gray-600">
                          Problem solving, logic, and fast pattern recognition.
                        </p>
                      </div>
                      <div>
                        <p class="text-xs font-semibold text-gray-400">Probe next</p>
                        <p class="mt-1 text-sm text-gray-600">
                          Ask for trade-offs in system design and debugging approach.
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pb-16 sm:pb-24">
        <div class="grid grid-cols-1 gap-4 md:grid-cols-3">
          <div class="rounded-3xl border border-gray-100 bg-white/90 p-6 shadow-sm">
            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-indigo-100 text-indigo-600">
              <svg
                class="w-5 h-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="2"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
                />
              </svg>
            </div>
            <h3 class="mt-5 font-display text-xl font-bold text-gray-900">AI-generated questions</h3>
            <p class="mt-2 text-sm leading-6 text-gray-500">
              Create assessments matched to the role, industry, and seniority level you need.
            </p>
          </div>

          <div class="rounded-3xl border border-gray-100 bg-white/90 p-6 shadow-sm">
            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-amber-100 text-amber-600">
              <svg
                class="w-5 h-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="2"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                />
              </svg>
            </div>
            <h3 class="mt-5 font-display text-xl font-bold text-gray-900">
              Instant candidate access
            </h3>
            <p class="mt-2 text-sm leading-6 text-gray-500">
              Send one secure link by email and let candidates start immediately without onboarding friction.
            </p>
          </div>

          <div class="rounded-3xl border border-gray-100 bg-white/90 p-6 shadow-sm">
            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-emerald-100 text-emerald-600">
              <svg
                class="w-5 h-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="2"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                />
              </svg>
            </div>
            <h3 class="mt-5 font-display text-xl font-bold text-gray-900">Interview-ready reports</h3>
            <p class="mt-2 text-sm leading-6 text-gray-500">
              Review scores, weak spots, and follow-up questions before you move the candidate forward.
            </p>
          </div>
        </div>
      </section>

      <section class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pb-20">
        <div class="rounded-[2rem] border border-indigo-100 bg-gradient-to-r from-indigo-50 via-white to-sky-50 px-5 py-6 sm:px-8 sm:py-8 flex flex-col gap-5 lg:flex-row lg:items-center lg:justify-between">
          <div class="flex items-start gap-4">
            <img
              src={~p"/images/logo.png"}
              alt="Aptitude Test logo"
              class="h-14 w-14 rounded-2xl object-contain bg-white p-2 shadow-sm"
            />
            <div>
              <p class="font-display text-2xl font-bold text-gray-900">
                Built for fast candidate screening
              </p>
              <p class="mt-2 max-w-2xl text-sm leading-6 text-gray-600 sm:text-base">
                Share branded assessments from aptitudetest.info, keep the candidate experience simple on mobile or desktop, and review every result from one dashboard.
              </p>
            </div>
          </div>
          <.link
            navigate={~p"/users/register"}
            class="inline-flex w-full sm:w-auto items-center justify-center rounded-2xl bg-gray-900 px-6 py-3.5 text-sm font-semibold text-white transition-colors hover:bg-gray-800"
          >
            Start creating tests
          </.link>
        </div>
      </section>
    </div>
    """
  end
end
