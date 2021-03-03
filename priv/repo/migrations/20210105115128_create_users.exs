defmodule Nyra.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")

      # Profile Information
      add :email, :string
      add :username, :string
      add :age, :integer, default: 0, null: false
      add :gender, :integer, default: 0, null: false

      # ban_level | after a certain amount of restrictions an account will be deleted.
      # premium_level | what the users perks are and how much they have paid basically.
      add :ban_level, :integer, default: 0, null: false
      add :premium_level, :integer, default: 0, null: false

      # Profile & System Flags
      # filter_access | users can have filters revoked if they are abused.
      add :premium, :boolean, default: false, null: false
      add :banned, :boolean, default: false, null: false
      add :activated, :boolean, default: false, null: false
      add :filter_access, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
