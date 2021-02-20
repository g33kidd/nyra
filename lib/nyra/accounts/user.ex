defmodule Nyra.Accounts.User do
  @moduledoc """
  User contains both the authentication information and their profile information and flags.

  Current flags:

    - Premium
    - Banned
    - Activated
    - Filter Access

  """
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  # We automatically generate a UUID token for the user as their primary key.
  @primary_key {:id, Ecto.UUID, autogenerate: true}

  # Permitted keys that can pass through the changeset.
  @permitted_keys [
    :email,
    :username,
    :activated,
    :banned,
    :premium,
    :activated,
    :filter_access,
    :ban_level,
    :premium_level
  ]

  @required_keys [
    :email,
    :username
  ]

  schema "users" do
    field :email, :string
    field :username, :string

    # Profile & System Flags
    field :activated, :boolean, default: false
    field :banned, :boolean, default: false
    field :premium, :boolean, default: false
    field :filter_access, :boolean, default: true

    timestamps()
  end

  # TODO create default and other changesets for updating and creating user accounts or profile information.
  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @permitted_keys)
    |> validate_required(@required_keys)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc "Scoped query function for selecting with the UUID"
  def with_id(query, id) do
    from u in query, where: u.id == ^id
  end

  @doc "Scoped query function for selecting active entries."
  def where_active(query) do
    from u in query, where: u.active == true
  end

  @doc "Scoped query function for selecting with the username."
  def with_username(query, username \\ "") do
    from u in query, where: u.username == ^username
  end

  @doc "Selects the count of the results within a query"
  def select_count(query) do
    from u in query, select: count(u.id)
  end
end
