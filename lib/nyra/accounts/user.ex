defmodule Nyra.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  # Auto generate keys
  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "users" do
    field :activated, :boolean, default: false
    field :email, :string
    field :username, :string
    field :token, :string, default: nil

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email, :username, :activated])
    |> validate_required([:email, :username])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  def change_username(changeset, username), do: put_change(changeset, :username, username)

  def change_email(changeset, email), do: put_change(changeset, :email, email)

  def change_token(changeset, token), do: put_change(changeset, :token, token)
end
