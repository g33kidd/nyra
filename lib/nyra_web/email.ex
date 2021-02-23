defmodule Nyra.Emails do
  use Bamboo.Phoenix, view: NyraWeb.EmailView

  import Bamboo.Email

  @from "info@nyra.app"

  def login_link(email, code: code) do
    title = "🚀 Nyra Magic Login Code"

    body = ~s"""
    <p>Here is your login code:</p>
    <h1><strong>#{code}</strong></h1>
    <p>It is valid for 30 minutes.</p>
    """

    new_email()
    |> to(email)
    |> from(@from)
    |> subject(title)
    |> html_body(body)
  end
end
