defmodule Nyra.Emails do
  use Bamboo.Phoenix, view: NyraWeb.EmailView

  import Bamboo.Email

  def login_link(code, user) do
    new_email()
    |> to(user.email)
    |> from("info@nyra.app")
    |> subject("🚀 Nyra Magic Login Code")
    |> text_body("""
    Here is your login code: #{code}

    It is valid for 30 minutes.
    """)
  end
end
