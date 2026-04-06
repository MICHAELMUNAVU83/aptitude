defmodule Aptitude.Gmail do
  @moduledoc """
  Sends transactional emails via the Nexus email API.
  All outgoing emails use the shared branded HTML wrapper.
  """

  require Logger

  @api_url "https://app.nexuscale.ai/api/v1/email/send"
  @from_email "contact@aptitudetest.info"

  # ── Public API ────────────────────────────────────────────────────────────

  def send_email(to_email, subject, html_body) do
    payload = %{
      from_email: @from_email,
      to: to_email,
      subject: subject,
      body: html_body,
      html_body: html_body
    }

    Logger.info("[Gmail] Sending \"#{subject}\" → #{to_email}")

    case Req.post(@api_url,
           headers: [{"Content-Type", "application/json"}],
           json: payload,
           receive_timeout: 60_000
         ) do
      {:ok, %{status: status}} when status in 200..299 ->
        Logger.info("[Gmail] Delivered \"#{subject}\" → #{to_email} (HTTP #{status})")
        {:ok, status}

      {:ok, %{status: status, body: body}} ->
        Logger.error(
          "[Gmail] API error #{status} for \"#{subject}\" → #{to_email}: #{inspect(body)}"
        )

        {:error, {status, body}}

      {:error, reason} ->
        Logger.error(
          "[Gmail] HTTP error sending \"#{subject}\" → #{to_email}: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end
end
