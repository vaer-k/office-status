defmodule OfficeStatus.Statuses.Status do
  use Ecto.Schema
  import Ecto.Changeset

  schema "statuses" do
    field :name, :string
    field :message, :string
    field :icon, :string
    field :color, :string
    field :is_active, :boolean, default: false
    field :display_order, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:name, :message, :icon, :color, :is_active, :display_order])
    |> validate_required([:name, :message, :icon, :color, :is_active, :display_order])
  end
end
