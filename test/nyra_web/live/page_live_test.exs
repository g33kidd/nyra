defmodule NyraWeb.PageLiveTest do
  use NyraWeb.ConnCase

  import Phoenix.LiveViewTest

  test "Email form submit", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
  end

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")

    assert disconnected_html =~ "LOGIN"
    assert render(page_live) =~ "LOGIN"
  end
end
