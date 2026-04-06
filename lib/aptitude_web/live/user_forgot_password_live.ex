defmodule AptitudeWeb.UserForgotPasswordLive do
  use AptitudeWeb, :live_view

  alias Aptitude.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl grid gap-8 lg:grid-cols-[0.95fr_1.05fr] lg:items-center">
      <div class="rounded-[2rem] border border-white/70 bg-white/75 p-6 shadow-[0_20px_70px_rgba(15,23,42,0.08)] backdrop-blur sm:p-8">
        <div class="inline-flex items-center gap-2 rounded-full border border-indigo-200 bg-indigo-50 px-3 py-1.5 text-xs font-semibold text-indigo-700">
          Secure account recovery
        </div>
        <h1 class="font-display mt-5 text-4xl font-bold leading-tight text-gray-950 sm:text-5xl">
          Forgot your password?
        </h1>
        <p class="mt-4 text-base leading-7 text-gray-600">
          Enter your email and we'll send a secure reset link so you can get back into your hiring dashboard quickly.
        </p>
      </div>

      <div class="rounded-[2rem] border border-gray-200/70 bg-white/95 p-7 shadow-[0_24px_80px_rgba(15,23,42,0.08)] sm:p-8">
        <div class="mb-8">
          <h2 class="font-display text-3xl font-bold text-gray-950">Reset your password</h2>
          <p class="mt-2 text-sm text-gray-500">We'll send the reset link to your inbox.</p>
        </div>

        <.simple_form for={@form} id="reset_password_form" phx-submit="send_email" class="space-y-4">
          <div>
            <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1.5">
              Email
            </label>
            <.input
              field={@form[:email]}
              type="email"
              placeholder="you@company.com"
              required
              class="w-full px-4 py-3 rounded-2xl border border-gray-200 text-sm text-gray-900 placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent transition bg-white"
            />
          </div>
          <:actions>
            <.button
              phx-disable-with="Sending..."
              class="w-full rounded-2xl bg-gray-900 py-3 text-sm font-bold text-white hover:bg-gray-800"
            >
              Send password reset instructions
            </.button>
          </:actions>
        </.simple_form>
        <p class="text-center text-sm mt-5 text-gray-500">
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

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
