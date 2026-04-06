defmodule AptitudeWeb.UserRegistrationLive do
  use AptitudeWeb, :live_view

  alias Aptitude.Accounts
  alias Aptitude.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="grid gap-8 lg:grid-cols-[0.95fr_1.05fr] lg:items-center">
      <div class="rounded-[2rem] border border-white/70 bg-white/75 p-6 shadow-[0_20px_70px_rgba(15,23,42,0.08)] backdrop-blur sm:p-8">
        <div class="inline-flex items-center gap-2 rounded-full border border-amber-200 bg-amber-50 px-3 py-1.5 text-xs font-semibold text-amber-700">
          Start testing candidates faster
        </div>
        <h1 class="font-display mt-5 text-4xl font-bold leading-tight text-gray-950 sm:text-5xl">
          Create your account.
        </h1>
        <p class="mt-4 max-w-xl text-base leading-7 text-gray-600">
          Launch branded aptitude tests, share secure links, and keep every candidate review in one clean workflow.
        </p>
        <div class="mt-8 rounded-[1.75rem] border border-gray-100 bg-white/90 p-5 shadow-sm">
          <p class="text-xs font-semibold uppercase tracking-[0.2em] text-gray-400">What you get</p>
          <ul class="mt-4 space-y-3 text-sm text-gray-600">
            <li class="flex items-start gap-3">
              <span class="mt-1 h-2.5 w-2.5 rounded-full bg-indigo-500"></span><span>AI-generated tests tailored to role, sector, and difficulty.</span>
            </li>
            <li class="flex items-start gap-3">
              <span class="mt-1 h-2.5 w-2.5 rounded-full bg-amber-500"></span><span>Candidate links that work instantly without account creation.</span>
            </li>
            <li class="flex items-start gap-3">
              <span class="mt-1 h-2.5 w-2.5 rounded-full bg-emerald-500"></span><span>Interview-ready reports with strengths, risks, and follow-up probes.</span>
            </li>
          </ul>
        </div>
      </div>

      <div class="w-full max-w-md lg:ml-auto">
        <div class="rounded-[2rem] border border-gray-200/70 bg-white/95 p-7 shadow-[0_24px_80px_rgba(15,23,42,0.08)] sm:p-8">
          <div class="mb-8">
            <h2 class="font-display text-3xl font-bold text-gray-950">Create your account</h2>
            <p class="mt-2 text-sm text-gray-500">
              Already have an account?
              <.link
                navigate={~p"/users/log_in"}
                class="font-semibold text-indigo-600 hover:text-indigo-500"
              >
                Log in
              </.link>
            </p>
          </div>

          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.simple_form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            phx-trigger-action={@trigger_submit}
            action={~p"/users/log_in?_action=registered"}
            method="post"
            class="space-y-4"
          >
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1.5">
                Email
              </label>
              <.input
                field={@form[:email]}
                type="email"
                required
                class="w-full px-4 py-3 rounded-2xl border border-gray-200 text-sm text-gray-900 placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent transition bg-white"
              />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1.5">
                Password
              </label>
              <.input
                field={@form[:password]}
                type="password"
                required
                class="w-full px-4 py-3 rounded-2xl border border-gray-200 text-sm text-gray-900 placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent transition bg-white"
              />
            </div>

            <:actions>
              <.button
                phx-disable-with="Creating account…"
                class="w-full flex items-center justify-center rounded-2xl bg-gray-900 px-4 py-3 text-sm font-bold text-white shadow-sm transition-colors hover:bg-gray-800 mt-2"
              >
                Create account
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
