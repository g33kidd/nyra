defmodule Nyra.Emails do
  use Bamboo.Phoenix, view: NyraWeb.EmailView

  import Bamboo.Email

  def login_link(code, user) do
    new_email()
    |> to(user.email)
    |> from("info@nyra.app")
    |> subject("🚀 Nyra Magic Login Code")
    |> html_body("""
    <p>Here is your login code:</p>
    <h1><strong>#{code}</strong></h1>
    <p>It is valid for 30 minutes.</p>
    """)
  end
end
