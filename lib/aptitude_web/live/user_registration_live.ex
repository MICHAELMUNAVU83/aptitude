defmodule AptitudeWeb.UserRegistrationLive do
  use AptitudeWeb, :live_view

  alias Aptitude.Accounts
  alias Aptitude.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-center justify-center px-4">
      <div class="w-full max-w-sm">
        <div class="text-center mb-8">
          <.link navigate={~p"/"} class="text-xl font-black text-gray-900 tracking-tight">
            Aptitude
          </.link>
          <h1 class="text-2xl font-bold text-gray-900 mt-6 mb-1">Create your account</h1>
          <p class="text-sm text-gray-400">
            Already have an account?
            <.link
              navigate={~p"/users/log_in"}
              class="text-indigo-600 font-semibold hover:text-indigo-500"
            >
              Log in
            </.link>
          </p>
        </div>

        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-7">
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
                class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent transition bg-white"
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
                class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent transition bg-white"
              />
            </div>

            <:actions>
              <.button
                phx-disable-with="Creating account…"
                class="w-full flex items-center justify-center bg-indigo-600 text-white text-sm font-bold px-4 py-3 rounded-xl hover:bg-indigo-500 transition-colors shadow-sm mt-2"
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
