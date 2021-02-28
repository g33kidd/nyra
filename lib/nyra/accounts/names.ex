defmodule Nyra.Names do
  @moduledoc """
  Honestly I just did this to clean up the code of accounts.ex
  The only purpose of this file is to store pieces of usernames to be generated.
  Though I'm sure more logic will be implemented here at some point in the future.

  TODO marking this for up next
  TODO marking this for up next
  TODO marking this for up next
  TODO marking this for up next
  """

  @descriptors %{
    :normal => [
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
      "crimson"
    ],
    :music => [],
    :code => [],
    :cyber => [],
    :colors => [
      "blue"
    ]
  }

  @things %{
    :normal => [],
    :music => [],
    :cyber => [],
    :colors => [],
    :default => [
      "wind"
    ]
  }

  defmacro __using__(_) do
    quote do
      # Metaprogramming FTW

      # General Names (64x64)
      # full btw
      @names_matrix_1 [
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

      # TODO generate a new name matrix.
      @names_matrix_2 []

      @names_matrix_3 []
    end
  end
end
