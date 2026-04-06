defmodule AptitudeWeb.Candidate.CompletionLive do
  use AptitudeWeb, :live_view

  @impl true
  def mount(%{"token" => _token}, _session, socket) do
    {:ok, assign(socket, page_title: "Test Completed"), layout: false}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-50 via-white to-violet-50/30 flex items-center justify-center px-6">
      <div class="text-center max-w-sm">
        <div class="w-20 h-20 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-3xl flex items-center justify-center mx-auto mb-7 shadow-lg shadow-emerald-200">
          <svg
            class="w-10 h-10 text-white"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            stroke-width="2.5"
          >
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h1 class="text-2xl font-bold text-gray-900 mb-3">Test completed!</h1>
        <p class="text-gray-400 text-sm leading-relaxed">
          Thank you for completing the test. Your answers have been submitted and a report will be generated shortly.
        </p>
        <div class="mt-8 inline-flex items-center gap-2 bg-white px-4 py-2.5 rounded-xl border border-gray-100 shadow-sm text-xs text-gray-400">
          <svg class="w-3.5 h-3.5 text-emerald-400" fill="currentColor" viewBox="0 0 8 8">
            <circle cx="4" cy="4" r="3" />
          </svg>
          You may now close this window
        </div>
      </div>
    </div>
    """
  end
end
