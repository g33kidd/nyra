defmodule Nyra.Accounts do
  @moduledoc """
    Provides functions for dealing with accounts.
  """

  import Ecto.Query

  alias Nyra.{Repo, Mailer}
  alias Nyra.Accounts.{Token, User}

  def get_users do
    User |> Repo.all()
  end

  def give_token(nil), do: {:error, :not_found}

  def give_token(email) when is_binary(email) do
    User
    |> Repo.get_by(email: email)
    |> send_token()
  end

  def give_token(user = %User{}), do: send_token(user)

  def send_token(user) do
    user
    |> create_token()

    {:ok, user}
  end

  def create_token(user) do
    changeset = Token.changeset(%Token{}, user)
    token = Repo.insert!(changeset)
    token.value
  end
end
