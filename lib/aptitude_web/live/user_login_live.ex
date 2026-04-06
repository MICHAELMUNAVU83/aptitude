defmodule AptitudeWeb.UserLoginLive do
  use AptitudeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="grid gap-8 lg:grid-cols-[0.95fr_1.05fr] lg:items-center">
      <div class="rounded-[2rem] border border-white/70 bg-white/75 p-6 shadow-[0_20px_70px_rgba(15,23,42,0.08)] backdrop-blur sm:p-8">
        <div class="inline-flex items-center gap-2 rounded-full border border-indigo-200 bg-indigo-50 px-3 py-1.5 text-xs font-semibold text-indigo-700">
          Sign in to your hiring workspace
        </div>
        <h1 class="font-display mt-5 text-4xl font-bold leading-tight text-gray-950 sm:text-5xl">
          Welcome back.
        </h1>
        <p class="mt-4 max-w-xl text-base leading-7 text-gray-600">
          Manage candidate tests, resend secure links, and review AI-assisted reports from one dashboard.
        </p>
        <div class="mt-8 grid gap-3 sm:grid-cols-2">
          <div class="rounded-2xl border border-gray-100 bg-white/90 p-4 shadow-sm">
            <p class="font-display text-2xl font-bold text-gray-950">Fast</p>
            <p class="mt-1 text-sm text-gray-500">Create and send assessments in a few clicks.</p>
          </div>
          <div class="rounded-2xl border border-gray-100 bg-white/90 p-4 shadow-sm">
            <p class="font-display text-2xl font-bold text-gray-950">Focused</p>
            <p class="mt-1 text-sm text-gray-500">Review candidate performance before interviews start.</p>
          </div>
        </div>
      </div>

      <div class="w-full max-w-md lg:ml-auto">
        <div class="rounded-[2rem] border border-gray-200/70 bg-white/95 p-7 shadow-[0_24px_80px_rgba(15,23,42,0.08)] sm:p-8">
          <div class="mb-8">
            <h2 class="font-display text-3xl font-bold text-gray-950">Log in</h2>
            <p class="mt-2 text-sm text-gray-500">
              Don't have an account?
              <.link
                navigate={~p"/users/register"}
                class="font-semibold text-indigo-600 hover:text-indigo-500"
              >
                Sign up
              </.link>
            </p>
          </div>

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
                class="w-full px-4 py-3 rounded-2xl border border-gray-200 text-sm text-gray-900 placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent transition bg-white"
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
                class="w-full px-4 py-3 rounded-2xl border border-gray-200 text-sm text-gray-900 placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent transition bg-white"
              />
            </div>

            <div class="flex items-center gap-2 pt-1">
              <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
            </div>

            <:actions>
              <.button
                phx-disable-with="Logging in…"
                class="w-full flex items-center justify-center rounded-2xl bg-gray-900 px-4 py-3 text-sm font-bold text-white shadow-sm transition-colors hover:bg-gray-800 mt-2"
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
