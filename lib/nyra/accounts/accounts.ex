defmodule Nyra.Accounts do
  @moduledoc """
    Provides functions for dealing with accounts.
  """

  import Ecto.Query

  alias Nyra.{Repo, Mailer}
  alias Nyra.Accounts.{Token, User}

  def get_users do
    User |> Repo.all()
  end

  def create_user do
    create_user_changeset() |> Repo.insert()
  end

  def create_user_changeset do
    # TODO this is a non-nononono FUCKk cant think of a better solution atm.
    %User{}
    |> User.changeset(%{username: generate_username(), email: generate_username()})
  end

  def find_or_create_user(%{"email" => email}, username \\ nil) do
    case get_user_by(email: email) do
      {:ok, user} ->
        {:ok, user}

      {:error, :not_found} ->
        %User{}
        |> User.changeset(%{
          username: if(username == nil, do: generate_username(), else: username),
          email: email
        })
        |> Repo.insert()
    end
  end

  def insert_user(changeset), do: Repo.insert(changeset)

  def get_user_by(email: email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  # TODO make a new list of random names or whatever.
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
