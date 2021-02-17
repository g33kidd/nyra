defmodule Nyra.Accounts do
  @moduledoc false

  import Ecto.Query

  alias Nyra.{Repo, Mailer}
  alias Nyra.Accounts.{Token, User}

  def get_users do
    User |> Repo.all()
  end

  def get_user(id) do
    User
    |> Repo.get(id)
  end

  def update_token(%User{} = user, token) do
    user
    |> User.changeset()
    |> User.change_token(token)
    |> Repo.update()
  end

  def find_or_create_user(%{"email" => email}, username \\ nil) do
    case get_user_by(email: email) do
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

  @spec is_activated?(String.t()) :: :ok | {:error, :account_not_active}
  def is_activated?(user_id) when is_binary(user_id) do
    result =
      from u in User,
        where: u.id == ^user_id,
        where: u.activated == true,
        select: count(u.id)

    result
    |> Repo.all()
    |> Enum.at(0)
    |> is_activated?()
  end

  def is_activated?(0), do: {:error, :account_not_active}
  def is_activated?(1), do: :ok
  def is_activated?(_default), do: {:error, :account_not_active}

  def insert_user(changeset), do: Repo.insert(changeset, returning: [:id])

  def get_user_by(email: email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def generate_username do
    # [[64][64]]
    [
      [
        "autumn",
        "hidden",
        "bitter",
        "misty",
        "silent",
        "empty",
        "dry",
        "dark",
        "summer",
        "icy",
        "delicate",
        "quiet",
        "white",
        "cool",
        "spring",
        "winter",
        "patient",
        "twilight",
        "dawn",
        "crimson",
        "wispy",
        "weathered",
        "blue",
        "billowing",
        "broken",
        "cold",
        "damp",
        "falling",
        "frosty",
        "green",
        "long",
        "late",
        "lingering",
        "bold",
        "little",
        "morning",
        "muddy",
        "old",
        "red",
        "rough",
        "still",
        "small",
        "sparkling",
        "throbbing",
        "shy",
        "wandering",
        "withered",
        "wild",
        "black",
        "young",
        "holy",
        "solitary",
        "fragrant",
        "aged",
        "snowy",
        "proud",
        "floral",
        "restless",
        "divine",
        "polished",
        "ancient",
        "purple",
        "lively",
        "nameless"
      ],
      [
        "waterfall",
        "river",
        "breeze",
        "moon",
        "rain",
        "wind",
        "sea",
        "morning",
        "snow",
        "lake",
        "sunset",
        "pine",
        "shadow",
        "leaf",
        "dawn",
        "glitter",
        "forest",
        "hill",
        "cloud",
        "meadow",
        "sun",
        "glade",
        "bird",
        "brook",
        "butterfly",
        "bush",
        "dew",
        "dust",
        "field",
        "fire",
        "flower",
        "firefly",
        "feather",
        "grass",
        "haze",
        "mountain",
        "night",
        "pond",
        "darkness",
        "snowflake",
        "silence",
        "sound",
        "sky",
        "shape",
        "surf",
        "thunder",
        "violet",
        "water",
        "wildflower",
        "wave",
        "water",
        "resonance",
        "sun",
        "wood",
        "dream",
        "cherry",
        "tree",
        "fog",
        "frost",
        "voice",
        "paper",
        "frog",
        "smoke",
        "star"
      ]
    ]
    |> Enum.map(fn names -> Enum.random(Enum.map(names, fn n -> String.capitalize(n) end)) end)
    |> Enum.join("")
  end
end
