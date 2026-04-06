defmodule AptitudeWeb.Admin.CreateTestLive do
  use AptitudeWeb, :live_view

  alias Aptitude.{Tests, OpenAI}
  alias Aptitude.Emails.TestInvitation

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       form: to_form(%{}, as: :test),
       generating: false,
       done: nil,
       page_title: "New Test"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mt-8 mx-auto">
      <.link
        navigate={~p"/admin"}
        class="inline-flex items-center gap-1.5 text-sm text-gray-400 hover:text-gray-600 transition-colors mb-6"
      >
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
        Back
      </.link>

      <div class="mb-7">
        <h1 class="text-2xl font-bold text-gray-900">Create a new test</h1>
        <p class="text-sm text-gray-400 mt-1">
          Fill in the details below — questions are generated automatically.
        </p>
      </div>

      <%= if @generating do %>
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-14 flex flex-col items-center text-center gap-6">
          <div class="relative w-16 h-16">
            <div class="w-16 h-16 rounded-full bg-gradient-to-br from-violet-100 to-indigo-100"></div>
            <svg
              class="animate-spin w-16 h-16 text-indigo-500 absolute inset-0"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                class="opacity-20"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                stroke-width="3"
              />
              <path
                class="opacity-90"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
              />
            </svg>
          </div>
          <div>
            <p class="text-sm font-bold text-gray-900">Generating & sending…</p>
            <p class="text-xs text-gray-400 mt-1.5">Usually takes 10–20 seconds. Hang tight.</p>
          </div>
        </div>
      <% else %>
        <%= if @done do %>
          <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-10 flex flex-col items-center text-center gap-5">
            <div class="w-14 h-14 bg-emerald-100 rounded-2xl flex items-center justify-center">
              <svg
                class="w-7 h-7 text-emerald-600"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="2.5"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <div>
              <p class="text-base font-bold text-gray-900">Test sent successfully</p>
              <p class="text-sm text-gray-400 mt-1">
                Invitation emailed to <span class="font-semibold text-gray-700"><%= @done.email %></span>.
              </p>
            </div>
            <div class="bg-gray-50 rounded-xl w-full p-4 text-left space-y-2.5 text-xs">
              <div class="flex justify-between">
                <span class="text-gray-400">Sector</span>
                <span class="font-semibold text-gray-700">{String.capitalize(@done.sector)}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-400">Difficulty</span>
                <span class="font-semibold text-gray-700">{String.capitalize(@done.difficulty)}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-400">Questions</span>
                <span class="font-semibold text-gray-700">{@done.question_count}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-400">Time limit</span>
                <span class="font-semibold text-gray-700">{@done.time_limit} min</span>
              </div>
            </div>
            <div class="flex gap-3 w-full pt-1">
              <button
                phx-click="reset"
                class="flex-1 text-sm font-semibold text-indigo-600 border border-indigo-200 px-4 py-2.5 rounded-xl hover:bg-indigo-50 transition-colors"
              >
                Create another
              </button>
              <.link
                navigate={~p"/admin/tests/#{@done.id}"}
                class="flex-1 text-sm font-semibold text-white bg-indigo-600 px-4 py-2.5 rounded-xl hover:bg-indigo-500 transition-colors text-center"
              >
                View test
              </.link>
              <.link
                navigate={~p"/admin"}
                class="flex-1 text-sm font-semibold text-gray-600 border border-gray-200 px-4 py-2.5 rounded-xl hover:border-gray-300 transition-colors text-center"
              >
                All tests
              </.link>
            </div>
          </div>
        <% else %>
          <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-7">
            <.form for={@form} phx-submit="create_test" class="space-y-5">
              <div>
                <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">
                  Candidate email
                </label>
                <input
                  type="email"
                  name="test[candidate_email]"
                  placeholder="candidate@example.com"
                  class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-violet-400 focus:border-transparent transition bg-white"
                  required
                />
              </div>

              <div>
                <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">
                  Sector / Topic
                </label>
                <select
                  name="test[sector]"
                  class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-900 focus:outline-none focus:ring-2 focus:ring-violet-400 focus:border-transparent transition bg-white"
                  required
                >
                  <option value="" disabled selected>Select a sector</option>
                  <option value="general knowledge">General Knowledge</option>
                  <option value="software engineering">Software Engineering</option>
                  <option value="marketing">Marketing</option>
                  <option value="finance">Finance</option>
                  <option value="human resources">Human Resources</option>
                  <option value="data science">Data Science</option>
                  <option value="product management">Product Management</option>
                  <option value="sales">Sales</option>
                </select>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">
                    Difficulty
                  </label>
                  <select
                    name="test[difficulty]"
                    class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-900 focus:outline-none focus:ring-2 focus:ring-violet-400 focus:border-transparent transition bg-white"
                    required
                  >
                    <option value="" disabled selected>Select</option>
                    <option value="easy">Easy</option>
                    <option value="medium">Medium</option>
                    <option value="hard">Hard</option>
                  </select>
                </div>

                <div>
                  <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">
                    Time limit
                  </label>
                  <select
                    name="test[time_limit]"
                    class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-900 focus:outline-none focus:ring-2 focus:ring-violet-400 focus:border-transparent transition bg-white"
                    required
                  >
                    <option value="" disabled selected>Select</option>
                    <option value="15">15 minutes</option>
                    <option value="30">30 minutes</option>
                    <option value="45">45 minutes</option>
                    <option value="60">60 minutes</option>
                    <option value="90">90 minutes</option>
                  </select>
                </div>
              </div>

              <div>
                <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">
                  Number of questions
                </label>
                <select
                  name="test[question_count]"
                  class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-900 focus:outline-none focus:ring-2 focus:ring-violet-400 focus:border-transparent transition bg-white"
                  required
                >
                  <option value="" disabled selected>Select</option>
                  <option value="5">5 questions</option>
                  <option value="10">10 questions</option>
                  <option value="15">15 questions</option>
                  <option value="20">20 questions</option>
                  <option value="25">25 questions</option>
                </select>
              </div>

              <div class="pt-1">
                <button
                  type="submit"
                  class="w-full flex items-center justify-center gap-2 bg-indigo-600 text-white text-sm font-bold px-4 py-3 rounded-xl hover:bg-indigo-500 transition-colors shadow-sm"
                >
                  Generate & send test
                </button>
              </div>
            </.form>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("create_test", %{"test" => params}, socket) do
    attrs = %{
      candidate_email: params["candidate_email"],
      sector: params["sector"],
      difficulty: params["difficulty"],
      time_limit: String.to_integer(params["time_limit"]),
      question_count: String.to_integer(params["question_count"]),
      user_id: socket.assigns.current_user.id
    }

    send(self(), {:do_create_test, attrs})
    {:noreply, assign(socket, generating: true)}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, done: nil, form: to_form(%{}, as: :test))}
  end

  @impl true
  def handle_info({:do_create_test, attrs}, socket) do
    case Tests.create_test(attrs) do
      {:ok, test} ->
        case OpenAI.generate_questions(test.sector, test.difficulty, test.question_count) do
          {:ok, questions} ->
            Tests.create_questions(test, questions)

            TestInvitation.send_invitation(test)

            {:noreply,
             assign(socket,
               generating: false,
               done: %{
                 id: test.id,
                 email: test.candidate_email,
                 sector: test.sector,
                 difficulty: test.difficulty,
                 question_count: test.question_count,
                 time_limit: test.time_limit
               }
             )}

          {:error, reason} ->
            {:noreply,
             socket
             |> assign(generating: false)
             |> put_flash(:error, "Failed to generate questions: #{inspect(reason)}")}
        end

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(generating: false, form: to_form(changeset, as: :test))
         |> put_flash(:error, "Please check the form fields")}
    end
  end
end
