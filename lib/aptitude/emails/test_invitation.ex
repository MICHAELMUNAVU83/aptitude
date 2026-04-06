defmodule Aptitude.Emails.TestInvitation do
  @moduledoc """
  Branded transactional emails for test invitations and completions.
  All emails are sent via Aptitude.Gmail.
  """

  alias Aptitude.Gmail

  # ── Public API ─────────────────────────────────────────────────────────────

  def send_invitation(test) do
    test_url = AptitudeWeb.Endpoint.url() <> "/test/#{test.token}"
    subject = "You've been invited to take an aptitude test"

    html =
      branded_email(%{
        title: "Your aptitude test is ready",
        preheader: "You've been invited to complete a #{String.capitalize(test.sector)} aptitude test.",
        body: """
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">
          Hi there — you've been invited to complete an aptitude test. Click the button below whenever you're ready to begin.
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;margin-bottom:28px;">
          #{detail_row("Topic", String.capitalize(test.sector))}
          #{detail_row("Difficulty", String.capitalize(test.difficulty))}
          #{detail_row("Questions", "#{test.question_count}")}
          #{detail_row("Time limit", "#{test.time_limit} minutes")}
        </table>

        #{cta_button("Start test →", test_url)}

        <p style="color:#9ca3af;font-size:12px;line-height:1.6;margin:20px 0 0;text-align:center;">
          The timer starts the moment you open the link. Make sure you're in a quiet spot before clicking.
        </p>
        """
      })

    Gmail.send_email(test.candidate_email, subject, html)
  end

  def send_completion_to_candidate(test) do
    subject = "Your aptitude test has been submitted"

    html =
      branded_email(%{
        title: "Test submitted — thank you!",
        preheader: "Your #{String.capitalize(test.sector)} aptitude test has been received.",
        body: """
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">
          Thanks for completing the test. Your responses have been submitted and are now being reviewed.
          You will hear back from the team shortly.
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;margin-bottom:28px;">
          #{detail_row("Topic", String.capitalize(test.sector))}
          #{detail_row("Difficulty", String.capitalize(test.difficulty))}
          #{detail_row("Questions", "#{test.question_count}")}
        </table>

        <p style="color:#9ca3af;font-size:12px;line-height:1.6;margin:0;text-align:center;">
          You do not need to take any further action. Good luck!
        </p>
        """
      })

    Gmail.send_email(test.candidate_email, subject, html)
  end

  def send_completion_to_owner(test, owner_email) do
    subject = "#{test.candidate_email} has completed their aptitude test"

    result_url =
      AptitudeWeb.Endpoint.url() <> "/admin/tests/#{test.id}/result"

    html =
      branded_email(%{
        title: "Test completed",
        preheader: "#{test.candidate_email} just submitted their aptitude test.",
        body: """
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">
          A candidate has just finished their test. The AI analysis is running in the background —
          the full report will be available in your dashboard shortly.
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;margin-bottom:28px;">
          #{detail_row("Candidate", test.candidate_email)}
          #{detail_row("Topic", String.capitalize(test.sector))}
          #{detail_row("Difficulty", String.capitalize(test.difficulty))}
          #{detail_row("Questions", "#{test.question_count}")}
        </table>

        #{cta_button("View report →", result_url)}
        """
      })

    Gmail.send_email(owner_email, subject, html)
  end

  # ── Private helpers ─────────────────────────────────────────────────────────

  defp branded_email(%{title: title, preheader: preheader, body: body}) do
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>#{title}</title>
    </head>
    <body style="margin:0;padding:0;background-color:#f3f4f6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">

      <!-- Preheader (hidden preview text) -->
      <span style="display:none;max-height:0;overflow:hidden;opacity:0;">#{preheader}</span>

      <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f3f4f6;padding:40px 20px;">
        <tr>
          <td align="center">
            <table width="100%" cellpadding="0" cellspacing="0" style="max-width:520px;">

              <!-- Logo / Brand header -->
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

              <!-- Card -->
              <tr>
                <td style="background:#ffffff;border-radius:16px;border:1px solid #e5e7eb;padding:40px 36px;box-shadow:0 1px 4px rgba(0,0,0,0.06);">

                  <!-- Title -->
                  <h1 style="margin:0 0 16px;font-size:22px;font-weight:700;color:#111827;line-height:1.3;">
                    #{title}
                  </h1>

                  <!-- Body content -->
                  #{body}

                </td>
              </tr>

              <!-- Footer -->
              <tr>
                <td align="center" style="padding-top:24px;">
                  <p style="margin:0;font-size:12px;color:#9ca3af;line-height:1.6;">
                    Sent by <strong style="color:#6b7280;">Aptitude</strong> — AI-powered aptitude testing platform<br/>
                    You received this because a test was created for your email address.
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

  defp detail_row(label, value) do
    """
    <tr>
      <td style="padding:9px 0;border-bottom:1px solid #f3f4f6;font-size:13px;color:#9ca3af;width:40%;">#{label}</td>
      <td style="padding:9px 0;border-bottom:1px solid #f3f4f6;font-size:13px;color:#111827;font-weight:600;text-align:right;">#{value}</td>
    </tr>
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
