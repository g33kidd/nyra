defmodule Nyra.Accounts do
  @moduledoc false

  use Nyra.Names

  alias Nyra.Repo
  alias Nyra.Accounts.User

  import Ecto.Changeset

  @doc "Gets all users from the database."
  def get_users, do: Repo.all(User)

  @doc "Get all users that are active."
  def get_users_active do
    User
    |> User.where_active()
    |> Repo.all()
  end

  @doc """
  Generalized function to getting a user as it makes it a bit simpler to reason about without having to
  deal with aliasing the User module in other places. Just call `find/1` or `find/2`

  By default the user is queried by their uuid. Though, you can pass in any available field
  as a parameter.

  Current queryable fields == :username | :email
  """
  def find(uuid) when is_binary(uuid), do: Repo.get(User, uuid)

  def find(query) when is_list(query) do
    case Repo.get_by(User, query) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def find(:username, username), do: Repo.get_by(User, username: username)
  def find(:email, email), do: Repo.get_by(User, email: email)

  @doc """
  Returns a user if a user with the email given isn't found.
  Creates & Returns a new user with a randomly generated username if one isn't found.
  """
  def find_or_create_user(email) do
    case find(:email, email) do
      nil ->
        {:ok, username} = generate_username()
        new_user = create_user(email, username)
        {:ok, new_user, :new}

      user ->
        {:ok, user, :existing}
    end
  end

  @doc "Activates a user that isn't already active"
  def activate(%User{} = user) do
    user
    |> User.changeset()
    |> User.update_flags(activated: true)
    |> User.update()
  end

  @doc "Creates & Inserts a new user into the database."
  def create_user(email, username) do
    changeset =
      %{"email" => email, "username" => username}
      |> User.creation_changeset()

    case User.insert(changeset) do
      {:created, user} ->
        user

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc "Checks if a user is activated based on the UUID provided."
  @spec is_activated?(String.t()) :: :ok | {:error, :account_not_active}
  def is_activated?(user_id) do
    count =
      User
      |> User.with_id(user_id)
      |> User.where_active()
      |> User.select_count()
      |> Repo.all()

    case Enum.at(count, 0) do
      0 -> :ok
      1 -> {:error, :account_not_found}
    end
  end

  @doc """
  Inserts a new user into the database.
  Note:
    Using the returning option since we're using UUID as a primary key.
    It's necessary to get the ID in a return value I guess.
  """
  def insert_user(changeset), do: Repo.insert(changeset, returning: [:id])

  @doc """
  Generates a mostly random username with 64x64 possible combinations.
  """
  def generate_username do
    name =
      @names_matrix_1
      |> Enum.map(fn names -> Enum.random(Enum.map(names, fn n -> String.capitalize(n) end)) end)
      |> Enum.join("")

    case ensure_username_available(name) do
      :ok -> {:ok, name}
      _default -> generate_username()
    end
  end

  @doc "Ensures a name isn't taken by another user already."
  def ensure_username_available(username \\ "") do
    User
    |> User.with_username(username)
    |> User.select_count()
    |> Repo.all()
    |> Enum.at(0)
    |> ensure_username_available?()
  end

  @doc "Keeps trying if username is not available."
  def ensure_username_available?(0), do: :ok
  def ensure_username_available?(1), do: :taken
  def ensure_username_available?(error), do: {:error, error}
end
