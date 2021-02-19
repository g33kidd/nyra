defmodule Nyra.Accounts do
  @moduledoc false

  use Nyra.Names

  alias Nyra.Repo
  alias Nyra.Accounts.User

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
  Finds or creates a user by their email address.

  """
  def find_or_create_user(%{"email" => email}, username \\ nil) do
    case find(:email, email) do
      {:ok, user} ->
        {:ok, user}

      {:error, :not_found} ->
        changeset =
          %User{}
          |> User.changeset(%{
            username: if(username == nil, do: generate_username(), else: username),
            email: email
          })

        case Repo.insert(changeset, returning: [:id]) do
          {:ok, new_user} -> {:created, new_user}
          {:error, error_changeset} -> {:error, error_changeset}
        end
    end
  end

  @doc "Checks if a user is activated based on the UUID provided."
  @spec is_activated?(String.t()) :: :ok | {:error, :account_not_active}
  def is_activated?(user_id) when is_binary(user_id) do
    User
    |> User.with_id(user_id)
    |> User.where_active()
    |> User.select_count()
    |> Repo.all()
    |> Enum.at(0)
    |> is_activated?()
  end

  @doc "Pattern matching for the result above."
  def is_activated?(0), do: {:error, :account_not_active}
  def is_activated?(1), do: :ok
  def is_activated?(_default), do: {:error, :account_not_active}

  @doc """
  Inserts a new user into the database.
  Note:
    Using the returning option since we're using UUID as a primary key.
    It's necessary to get the ID in a return value I guess.
  """
  def insert_user(changeset), do: Repo.insert(changeset, returning: [:id])

  @doc """
  Generates a mostly random username with 64x64 possible combinations.
  # TODO ensure name isn't already taken.
  """
  def generate_username do
    @names_matrix_1
    |> Enum.map(fn names -> Enum.random(Enum.map(names, fn n -> String.capitalize(n) end)) end)
    |> Enum.join("")
    |> ensure_name_available()
  end

  @doc "Ensures a name isn't taken by another user already."
  def ensure_name_available(username \\ "") do
    User
    |> User.with_username(username)
    |> User.select_count()
    |> Repo.all()
    |> Enum.at(0)
    |> ensure_name_available?()
  end

  @doc "Pattern matching for the result above."
  def ensure_name_available?(0), do: :ok
  def ensure_name_available?(1), do: {:error, :name_taken}
  def ensure_name_available?(_default), do: {:error, :name_taken}
end
