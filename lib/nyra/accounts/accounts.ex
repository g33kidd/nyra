defmodule Nyra.Accounts do
  @moduledoc false

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

  def find(:email, email), do: Repo.get_by(User, email: email)

  @doc """
  Helper method for taking only certain fields from a user.

  Returns the data for the user in the form of a tuple `{:ok, fields}`.
  Returns `nil` if a user couldn't be found.
  """
  def take(id, fields \\ []) do
    User
    |> User.with_id(id)
    |> User.select_fields(fields)
    |> Repo.one()
  end

  @doc """
  Returns a user if a user with the email given isn't found.
  Creates & Returns a new user with a randomly generated username if one isn't found.

  TODO the return information should not be like it is..
  """
  def find_or_create_user(email) do
    case find(:email, email) do
      nil ->
        username = generate_username()
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

  @doc "Creates & Inserts a new user into the database."
  def create_user(email, username) do
    %{
      "email" => email,
      "username" => username
    }
    |> User.creation_changeset()
    |> User.insert()
    |> case do
      {:created, user} ->
        user

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc "Checks if a user is activated based on the UUID provided."
  @spec is_activated?(String.t()) :: :ok | {:error, :account_not_active}
  def is_activated?(user_id) do
    User
    |> User.with_id(user_id)
    |> User.where_active()
    |> User.select_count()
    |> Repo.all()
    |> Enum.at(0)
    |> case do
      0 -> {:error, :account_not_found}
      1 -> :ok
    end
  end

  @doc """
  Inserts a new user into the database.
  Note:
    Using the returning option since we're using UUID as a primary key.
    It's necessary to get the ID in a return value I guess.
  """
  def insert_user(changeset), do: Repo.insert(changeset, returning: [:id])

  def generate_username() do
    Nyra.Naming.generate_username(:normal)
  end
end
