defmodule AptitudeWeb.UserConfirmationLive do
  use AptitudeWeb, :live_view

  alias Aptitude.Accounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl grid gap-8 lg:grid-cols-[0.95fr_1.05fr] lg:items-center">
      <div class="rounded-[2rem] border border-white/70 bg-white/75 p-6 shadow-[0_20px_70px_rgba(15,23,42,0.08)] backdrop-blur sm:p-8">
        <div class="inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1.5 text-xs font-semibold text-emerald-700">
          One last step
        </div>
        <h1 class="font-display mt-5 text-4xl font-bold leading-tight text-gray-950 sm:text-5xl">
          Confirm your account.
        </h1>
        <p class="mt-4 text-base leading-7 text-gray-600">
          Activate your account to start creating tests, sending candidate links, and reviewing results from your dashboard.
        </p>
      </div>

      <div class="rounded-[2rem] border border-gray-200/70 bg-white/95 p-7 shadow-[0_24px_80px_rgba(15,23,42,0.08)] sm:p-8">
        <div class="mb-8">
          <h2 class="font-display text-3xl font-bold text-gray-950">Confirm account</h2>
          <p class="mt-2 text-sm text-gray-500">
            Use the secure token from your email to activate access.
          </p>
        </div>

        <.simple_form for={@form} id="confirmation_form" phx-submit="confirm_account">
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <:actions>
            <.button
              phx-disable-with="Confirming..."
              class="w-full rounded-2xl bg-gray-900 py-3 text-sm font-bold text-white hover:bg-gray-800"
            >
              Confirm my account
            </.button>
          </:actions>
        </.simple_form>

        <p class="text-center mt-5 text-sm text-gray-500">
          <.link
            href={~p"/users/register"}
            class="font-semibold text-indigo-600 hover:text-indigo-500"
          >
            Register
          </.link>
          <span class="mx-2 text-gray-300">/</span>
          <.link href={~p"/users/log_in"} class="font-semibold text-indigo-600 hover:text-indigo-500">
            Log in
          </.link>
        </p>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("confirm_account", %{"user" => %{"token" => token}}, socket) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "User confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
