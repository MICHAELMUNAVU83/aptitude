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
    email = email_payload(to_email, subject, html_body)

    case Application.get_env(:aptitude, :email_delivery_mode, :api) do
      :test ->
        {:ok, email}

      _ ->
        deliver_via_api(email)
    end
  end

  defp email_payload(to_email, subject, html_body) do
    %{
      to: to_email,
      subject: subject,
      html_body: html_body,
      text_body: html_body,
      from_email: @from_email,
      body: html_body
    }
  end

  defp deliver_via_api(email) do
    Logger.info("[Gmail] Sending \"#{email.subject}\" → #{email.to}")

    case Req.post(@api_url,
           headers: [{"Content-Type", "application/json"}],
           json: %{
             from_email: email.from_email,
             to: email.to,
             subject: email.subject,
             body: email.body,
             html_body: email.html_body
           },
           receive_timeout: 60_000
         ) do
      {:ok, %{status: status}} when status in 200..299 ->
        Logger.info("[Gmail] Delivered \"#{email.subject}\" → #{email.to} (HTTP #{status})")
        {:ok, email}

      {:ok, %{status: status, body: body}} ->
        Logger.error(
          "[Gmail] API error #{status} for \"#{email.subject}\" → #{email.to}: #{inspect(body)}"
        )

        {:error, {status, body}}

      {:error, reason} ->
        Logger.error(
          "[Gmail] HTTP error sending \"#{email.subject}\" → #{email.to}: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end
end
