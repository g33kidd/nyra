defmodule Nyra.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :value, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(updated_at: false)
    end

    create index(:tokens, [:user_id])
    create unique_index(:tokens, [:value])
  end
end
