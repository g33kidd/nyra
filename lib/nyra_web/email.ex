defmodule Nyra.Emails do
  use Bamboo.Phoenix, view: NyraWeb.EmailView

  import Bamboo.Email

  def login_link(token, user) do
    new_email()
    |> to(user.email)
    |> from("info@nyra.app")
    |> subject("🚀 Nyra Magic Login Link")
    |> assign(:token, token)
    |> render("login_link.text")
  end
end
