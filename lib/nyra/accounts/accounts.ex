defmodule Nyra.Accounts do
  @moduledoc false

  use Nyra.Names

  alias Nyra.{Mailer, Emails, Repo}
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
  Helper method for taking only certain fields from a user.

  Returns the data for the user in the form of a tuple `{:ok, fields}`.
  Returns `nil` if a user couldn't be found.
  """
  def take(id, fields \\ []) do
    case find(id) do
      nil ->
        nil

      user ->
        Map.take(user, fields)
    end
  end

  @doc """
  Returns a user if a user with the email given isn't found.
  Creates & Returns a new user with a randomly generated username if one isn't found.

  TODO the return information should not be like it is..
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

  @doc "Sends the login link email with the authentication code."
  def deliver_code(email, code) do
    email
    |> Emails.login_link(code: code)
    |> Mailer.deliver_later()
  end

  @doc "Activates a user that isn't already active"
  def activate(%User{} = user) do
    user
    |> User.changeset()
    |> User.update_flags(activated: true)
    |> User.update()
  end

  # !! Marking for removal
  # !! Marking for removal
  # !! Marking for removal
  # !! Marking for removal
  # !! Marking for removal
  # !! Marking for removal
  # def update_token(id, token) when is_binary(id) do
  #   case find(id) do
  #     nil -> {:error, :invalid_user}
  #     user -> update_token(user, token)
  #   end
  # end
  # def update_token(%User{} = user, token) when is_struct(user) do
  #   user
  #   |> User.changeset()
  #   |> put_change(:token, token)
  #   |> User.update()
  # end

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
    count =
      User
      |> User.with_username(username)
      |> User.select_count()
      |> Repo.all()

    case Enum.at(count, 0) do
      0 -> :ok
      1 -> :taken
    end
  end
end
