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

  alias Nyra.Repo
  alias Nyra.Accounts.User

  # We automatically generate a UUID token for the user as their primary key.
  @primary_key {:id, Ecto.UUID, autogenerate: true}

  # Permitted keys that can pass through the changeset.
  @permitted_keys [
    :email,
    :banned,
    :premium,
    :username,
    :ban_level,
    :activated,
    :filter_access,
    :premium_level
  ]

  @creation_keys [:email, :username]
  @required_keys [:email, :username]

  schema "users" do
    field :age, :integer
    field :email, :string
    field :gender, :integer
    field :username, :string

    field :ban_level, :integer
    field :premium_level, :integer

    # Profile & System Flags
    field :banned, :boolean, default: false
    field :premium, :boolean, default: false
    field :activated, :boolean, default: false
    field :filter_access, :boolean, default: true

    timestamps()
  end

  @doc "Default changeset."
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @permitted_keys)
    |> validate_required(@required_keys)
    # |> validate_format(:email, ~r//)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc "Changeset used when creating a new user entirely."
  def creation_changeset(attrs \\ %{}) do
    %User{}
    |> cast(attrs, @creation_keys)
    |> validate_required(@required_keys)
    # |> validate_format(:email, ~r//)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc "Scoped query function for selecting with the UUID"
  def with_id(query, id) do
    from u in query, where: u.id == ^id
  end

  @doc "Scoped query function for selecting active entries."
  def where_active(query) do
    from u in query, where: u.activated == true
  end

  @doc "Scoped query function for selecting with the username."
  def with_username(query, username \\ "") do
    from u in query, where: u.username == ^username
  end

  @doc "Selects the count of the results within a query"
  def select_count(query) do
    from u in query, select: count(u.id)
  end

  @doc "Selects a few fields that we need to return."
  def select_fields(query, fields \\ []) do
    from u in query, select: ^fields
  end

  @doc "Commits changes for a changeset."
  def update(changeset) do
    case Repo.update(changeset) do
      {:ok, _} -> :ok
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc "Updates a users flags"
  def update_flags(changeset, [{k, v} | t]) do
    changeset
    |> put_change(k, v)
    |> update_flags(t)
  end

  def update_flags(changeset, []), do: changeset

  @doc """
  Commits a new Changeset to the database.
  """
  def insert(changeset) do
    case Repo.insert(changeset, returning: [:id]) do
      {:ok, user} ->
        {:created, user}

      {:error, err_changeset} ->
        {:error, err_changeset}
    end
  end
end
