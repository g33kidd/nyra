defmodule Nyra.Naming do
  @moduledoc """
  Honestly I just did this to clean up the code of accounts.ex
  The only purpose of this file is to store pieces of usernames to be generated.
  Though I'm sure more logic will be implemented here at some point in the future.
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
    :music => [
      "jazzy",
      "retro",
      ""
      # etc..
    ],
    :code => [],
    :cyber => [],
    :colors => [
      "blue"
    ]
  }

  @things %{
    :normal => [
      "biscuit",
      "forest",
      "apple",
      "gemini"
    ],
    :music => [],
    :cyber => [],
    :colors => [],
    :default => [
      "wind"
    ]
  }

  # Extras can be Transformers
  @transformers %{
    :normal => [],
    :music => [],
    :cyber => [],
    :colors => [],
    :default => []
  }

  @default_transformer_flags [
    "lowcase",
    "upcase",
    "generations",
    "vowel_removal",
    "leetspeak",
    "shuffle"
  ]

  @doc """

  Generates a username in a Haiku-like format, being related to a "Topic".
  Topics are things such as art, music, color, etc..
  This gives some variety when generating usernames or re-shuffling names

  !note idc about a token now, but a randomize token would help with regeneration

  Steps:

    Shuffle name Maps
    Take X NAMEs from DESCRIPTORs && THINGs && EXTRAS
    Shuffle NAMEs based on a token value
    Randomize flags for mutators

  """
  def generate_username(descriptor \\ :normal) when is_atom(descriptor) do
    desc =
      @descriptors[descriptor]
      |> shuffle_words()
      |> take_words()
      |> shuffle_words()
      |> get_final()

    what =
      @things[descriptor]
      |> shuffle_words()
      |> take_words()
      |> shuffle_words()
      |> get_final()

    # |> transform(@default_transformer_flags)

    # TODO ranzomize joiner
    joiner = ""

    Enum.join([String.capitalize(desc), String.capitalize(what)], joiner)
  end

  def shuffle_words(list \\ []), do: Enum.shuffle(list)
  def take_words(list \\ []), do: Enum.take_random(list, 6)
  def get_final(list \\ []), do: Enum.take_random(list, 1) |> Enum.at(0)

  @doc """
  Transformers are responsible for altering text based on some formatting
  """

  def transform(text), do: transform(@default_transformer_flags, text)

  def transform([transformer | rest], text) do
    text = transform_with(transformer, text)
    transform(rest, text)
  end

  def transform([], text), do: text

  def transform_with("upcase", text), do: String.upcase(text, :ascii)
end
