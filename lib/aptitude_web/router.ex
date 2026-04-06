defmodule AptitudeWeb.Router do
  use AptitudeWeb, :router

  import AptitudeWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AptitudeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AptitudeWeb do
    pipe_through :browser

    # Public landing
    live_session :landing,
      on_mount: [{AptitudeWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/", LandingLive, :index
    end

    # Candidate routes (public — token-gated)
    live "/test/:token", Candidate.TestLive, :show
    live "/test/:token/done", Candidate.CompletionLive, :show
  end

  ## Authentication routes

  scope "/", AptitudeWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AptitudeWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", AptitudeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{AptitudeWeb.UserAuth, :ensure_authenticated}] do
      # Admin routes
      live "/admin", Admin.TestListLive, :index
      live "/admin/tests/new", Admin.CreateTestLive, :new
      live "/admin/tests/:id", Admin.TestDetailLive, :show
      live "/admin/tests/:id/result", Admin.ResultDetailLive, :show

      # User settings
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", AptitudeWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{AptitudeWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  if Application.compile_env(:aptitude, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AptitudeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
