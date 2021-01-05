defmodule Nyra.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :activated, :boolean, default: false
    field :email, :string
    field :username, :string

    has_many :tokens, Nyra.Accounts.Token

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :activated])
    |> validate_required([:email, :username, :activated])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end
