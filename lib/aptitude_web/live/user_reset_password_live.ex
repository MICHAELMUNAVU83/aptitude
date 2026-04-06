defmodule AptitudeWeb.UserResetPasswordLive do
  use AptitudeWeb, :live_view

  alias Aptitude.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl grid gap-8 lg:grid-cols-[0.95fr_1.05fr] lg:items-center">
      <div class="rounded-[2rem] border border-white/70 bg-white/75 p-6 shadow-[0_20px_70px_rgba(15,23,42,0.08)] backdrop-blur sm:p-8">
        <div class="inline-flex items-center gap-2 rounded-full border border-indigo-200 bg-indigo-50 px-3 py-1.5 text-xs font-semibold text-indigo-700">
          Secure password reset
        </div>
        <h1 class="font-display mt-5 text-4xl font-bold leading-tight text-gray-950 sm:text-5xl">Choose a new password.</h1>
        <p class="mt-4 text-base leading-7 text-gray-600">
          Your new password should be strong, memorable, and at least 12 characters long.
        </p>
      </div>

      <div class="rounded-[2rem] border border-gray-200/70 bg-white/95 p-7 shadow-[0_24px_80px_rgba(15,23,42,0.08)] sm:p-8">
        <div class="mb-8">
          <h2 class="font-display text-3xl font-bold text-gray-950">Reset password</h2>
          <p class="mt-2 text-sm text-gray-500">Update your password to regain access.</p>
        </div>

        <.simple_form
          for={@form}
          id="reset_password_form"
          phx-submit="reset_password"
          phx-change="validate"
          class="space-y-4"
        >
          <.error :if={@form.errors != []}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.input field={@form[:password]} type="password" label="New password" required class="rounded-2xl" />
          <.input
            field={@form[:password_confirmation]}
            type="password"
            label="Confirm new password"
            required
            class="rounded-2xl"
          />
          <:actions>
            <.button phx-disable-with="Resetting..." class="w-full rounded-2xl bg-gray-900 py-3 text-sm font-bold text-white hover:bg-gray-800">Reset Password</.button>
          </:actions>
        </.simple_form>

        <p class="text-center text-sm mt-5 text-gray-500">
          <.link href={~p"/users/register"} class="font-semibold text-indigo-600 hover:text-indigo-500">Register</.link>
          <span class="mx-2 text-gray-300">/</span>
          <.link href={~p"/users/log_in"} class="font-semibold text-indigo-600 hover:text-indigo-500">Log in</.link>
        </p>
      </div>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{user: user} ->
          Accounts.change_user_password(user)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
