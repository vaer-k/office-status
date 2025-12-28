defmodule OfficeStatus.Repo.Migrations.CreateStatuses do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :name, :string
      add :message, :string
      add :icon, :string
      add :color, :string
      add :is_active, :boolean, default: false, null: false
      add :display_order, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
