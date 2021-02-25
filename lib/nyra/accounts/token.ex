defmodule Nyra.Accounts.Token do
  @moduledoc """
  TODO
  I think this is dead
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Nyra.{Endpoint}
  alias Nyra.Accounts.User
  alias Phoenix.Token

  schema "tokens" do
    field :value, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(token, user) do
    token
    |> cast(%{}, [])
    |> put_assoc(:user, user)
    |> put_change(:value, generate_token(user))
    |> validate_required([:value, :user])
    |> unique_constraint(:value)
  end

  defp generate_token(nil), do: nil
  defp generate_token(user), do: Token.sign(Endpoint, "user", user.id)
end
