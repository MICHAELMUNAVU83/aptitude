defmodule AptitudeWeb.UserLoginLive do
  use AptitudeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-center justify-center px-4">
      <div class="w-full max-w-sm">
        <div class="text-center mb-8">
          <.link navigate={~p"/"} class="text-xl font-black text-gray-900 tracking-tight">
            Aptitude
          </.link>
          <h1 class="text-2xl font-bold text-gray-900 mt-6 mb-1">Welcome back</h1>
          <p class="text-sm text-gray-400">
            Don't have an account?
            <.link
              navigate={~p"/users/register"}
              class="text-indigo-600 font-semibold hover:text-indigo-500"
            >
              Sign up
            </.link>
          </p>
        </div>

        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-7">
          <.simple_form
            for={@form}
            id="login_form"
            action={~p"/users/log_in"}
            phx-update="ignore"
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
              <div class="flex items-center justify-between mb-1.5">
                <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wide">
                  Password
                </label>
                <.link
                  href={~p"/users/reset_password"}
                  class="text-xs text-indigo-600 hover:text-indigo-500 font-medium"
                >
                  Forgot password?
                </.link>
              </div>
              <.input
                field={@form[:password]}
                type="password"
                required
                class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent transition bg-white"
              />
            </div>

            <div class="flex items-center gap-2 pt-1">
              <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
            </div>

            <:actions>
              <.button
                phx-disable-with="Logging in…"
                class="w-full flex items-center justify-center bg-indigo-600 text-white text-sm font-bold px-4 py-3 rounded-xl hover:bg-indigo-500 transition-colors shadow-sm mt-2"
              >
                Log in
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
