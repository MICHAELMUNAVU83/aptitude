defmodule Aptitude.Accounts.UserNotifier do
  alias Aptitude.Gmail

  @brand_color "#4f46e5"

  defp deliver(recipient, subject, html_body) do
    Gmail.send_email(recipient, subject, html_body)
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirm your Aptitude account", account_email(%{
      title: "Confirm your account",
      preheader: "Click the link below to confirm your Aptitude account.",
      body: """
      <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">
        Welcome to Aptitude! Please confirm your email address to activate your account.
      </p>
      #{cta_button("Confirm account →", url)}
      <p style="color:#9ca3af;font-size:12px;line-height:1.6;margin:20px 0 0;text-align:center;">
        If you didn't create an Aptitude account, you can safely ignore this email.
      </p>
      """
    }))
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset your Aptitude password", account_email(%{
      title: "Reset your password",
      preheader: "A password reset was requested for your Aptitude account.",
      body: """
      <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">
        We received a request to reset the password for your account.
        Click the button below to choose a new password.
      </p>
      #{cta_button("Reset password →", url)}
      <p style="color:#9ca3af;font-size:12px;line-height:1.6;margin:20px 0 0;text-align:center;">
        If you didn't request a password reset, no action is needed — your password remains unchanged.
      </p>
      """
    }))
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Confirm your new Aptitude email", account_email(%{
      title: "Confirm email change",
      preheader: "Click the link below to confirm your new email address.",
      body: """
      <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">
        You requested to change the email address on your Aptitude account.
        Click the button below to confirm the new address.
      </p>
      #{cta_button("Confirm new email →", url)}
      <p style="color:#9ca3af;font-size:12px;line-height:1.6;margin:20px 0 0;text-align:center;">
        If you didn't request this change, please ignore this email.
      </p>
      """
    }))
  end

  # ── Private helpers ─────────────────────────────────────────────────────────

  defp account_email(%{title: title, preheader: preheader, body: body}) do
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>#{title}</title>
    </head>
    <body style="margin:0;padding:0;background-color:#f3f4f6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">

      <span style="display:none;max-height:0;overflow:hidden;opacity:0;">#{preheader}</span>

      <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f3f4f6;padding:40px 20px;">
        <tr>
          <td align="center">
            <table width="100%" cellpadding="0" cellspacing="0" style="max-width:520px;">

              <tr>
                <td align="center" style="padding-bottom:24px;">
                  <table cellpadding="0" cellspacing="0">
                    <tr>
                      <td style="background:linear-gradient(135deg,#7c3aed,#4f46e5);border-radius:14px;padding:10px 14px;">
                        <span style="color:#ffffff;font-size:16px;font-weight:700;letter-spacing:-0.3px;">Aptitude</span>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>

              <tr>
                <td style="background:#ffffff;border-radius:16px;border:1px solid #e5e7eb;padding:40px 36px;box-shadow:0 1px 4px rgba(0,0,0,0.06);">
                  <h1 style="margin:0 0 16px;font-size:22px;font-weight:700;color:#111827;line-height:1.3;">
                    #{title}
                  </h1>
                  #{body}
                </td>
              </tr>

              <tr>
                <td align="center" style="padding-top:24px;">
                  <p style="margin:0;font-size:12px;color:#9ca3af;line-height:1.6;">
                    Sent by <strong style="color:#6b7280;">Aptitude</strong> — AI-powered aptitude testing platform
                  </p>
                </td>
              </tr>

            </table>
          </td>
        </tr>
      </table>

    </body>
    </html>
    """
  end

  defp cta_button(label, url) do
    """
    <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:8px;">
      <tr>
        <td align="center">
          <a href="#{url}"
             target="_blank"
             rel="noopener"
             style="display:inline-block;background:linear-gradient(135deg,#7c3aed,#4f46e5);color:#ffffff;text-decoration:none;font-size:15px;font-weight:600;padding:14px 36px;border-radius:10px;letter-spacing:0.1px;">
            #{label}
          </a>
        </td>
      </tr>
    </table>
    """
  end
end
