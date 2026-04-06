defmodule AptitudeWeb.LandingLive do
  use AptitudeWeb, :live_view

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
    <div class="min-h-screen bg-white">
      <!-- Nav -->
      <header class="max-w-5xl mx-auto px-6 py-5 flex items-center justify-between">
        <.link navigate={~p"/"} class="inline-flex items-center gap-3 text-gray-900">
          <img
            src={~p"/images/logo.png"}
            alt="Aptitude Test logo"
            class="h-11 w-11 rounded-2xl object-contain"
          />
          <div>
            <p class="text-lg font-bold tracking-tight leading-none">Aptitude Test</p>
            <p class="text-xs text-gray-400 mt-1">AI-powered hiring tests</p>
          </div>
        </.link>
        <div class="flex items-center gap-3">
          <.link
            navigate={~p"/users/log_in"}
            class="text-sm font-medium text-gray-600 hover:text-gray-900 transition-colors"
          >
            Log in
          </.link>
          <.link
            navigate={~p"/users/register"}
            class="text-sm font-semibold bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-500 transition-colors"
          >
            Sign up free
          </.link>
        </div>
      </header>
      
    <!-- Hero -->
      <section class="max-w-3xl mx-auto px-6 pt-20 pb-24 text-center">
        <h1 class="text-5xl font-black text-gray-900 leading-tight tracking-tight mb-6">
          Hire smarter.<br />Test candidates in minutes.
        </h1>
        <p class="text-lg text-gray-500 max-w-xl mx-auto mb-10">
          Generate AI-powered aptitude tests for any role, send them with one click, and get instant detailed reports.
        </p>
        <div class="flex items-center justify-center gap-4">
          <.link
            navigate={~p"/users/register"}
            class="text-sm font-semibold bg-indigo-600 text-white px-6 py-3 rounded-xl hover:bg-indigo-500 transition-colors shadow-sm"
          >
            Get started for free
          </.link>
          <.link
            navigate={~p"/users/log_in"}
            class="text-sm font-semibold text-gray-600 border border-gray-200 px-6 py-3 rounded-xl hover:border-gray-300 hover:text-gray-900 transition-colors"
          >
            Log in
          </.link>
        </div>
      </section>
      
    <!-- Features placeholder -->
      <section class="max-w-5xl mx-auto px-6 pb-24">
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-6">
          <div class="bg-gray-50 rounded-2xl p-7">
            <div class="w-10 h-10 bg-indigo-100 rounded-xl flex items-center justify-center mb-4">
              <svg
                class="w-5 h-5 text-indigo-600"
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
            <h3 class="text-sm font-bold text-gray-900 mb-1">AI-generated questions</h3>
            <p class="text-sm text-gray-500">
              Questions tailored to the role, sector, and difficulty level you choose.
            </p>
          </div>
          <div class="bg-gray-50 rounded-2xl p-7">
            <div class="w-10 h-10 bg-indigo-100 rounded-xl flex items-center justify-center mb-4">
              <svg
                class="w-5 h-5 text-indigo-600"
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
            <h3 class="text-sm font-bold text-gray-900 mb-1">Instant email delivery</h3>
            <p class="text-sm text-gray-500">
              Candidates receive a unique test link in their inbox — no sign-up required.
            </p>
          </div>
          <div class="bg-gray-50 rounded-2xl p-7">
            <div class="w-10 h-10 bg-indigo-100 rounded-xl flex items-center justify-center mb-4">
              <svg
                class="w-5 h-5 text-indigo-600"
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
            <h3 class="text-sm font-bold text-gray-900 mb-1">Detailed reports</h3>
            <p class="text-sm text-gray-500">
              Get scores, strengths, weaknesses, and interviewer probe questions automatically.
            </p>
          </div>
        </div>
      </section>

      <section class="max-w-5xl mx-auto px-6 pb-20">
        <div class="bg-gradient-to-r from-indigo-50 via-white to-sky-50 rounded-3xl border border-indigo-100 px-6 py-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-5">
          <div class="flex items-center gap-4">
            <img
              src={~p"/images/logo.png"}
              alt="Aptitude Test logo"
              class="h-14 w-14 rounded-2xl object-contain shadow-sm bg-white p-2"
            />
            <div>
              <p class="text-sm font-semibold text-gray-900">Built for fast candidate screening</p>
              <p class="text-sm text-gray-500 mt-1">
                Share branded assessments from aptitudetest.info and review results from one dashboard.
              </p>
            </div>
          </div>
          <.link
            navigate={~p"/users/register"}
            class="inline-flex items-center justify-center text-sm font-semibold bg-gray-900 text-white px-5 py-3 rounded-xl hover:bg-gray-800 transition-colors"
          >
            Start creating tests
          </.link>
        </div>
      </section>
    </div>
    """
  end
end
