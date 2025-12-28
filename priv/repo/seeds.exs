# Script for populating the database with default status presets.

alias OfficeStatus.Repo
alias OfficeStatus.Statuses.Status

# Default status presets with e-ink friendly icons
statuses = [
  %{
    name: "Available",
    message: "Come on in!",
    icon: "✓",
    color: "green",
    is_active: true,
    display_order: 1
  },
  %{
    name: "In a Meeting",
    message: "In a meeting, please wait",
    icon: "⛔",
    color: "red",
    is_active: false,
    display_order: 2
  },
  %{
    name: "Deep Focus",
    message: "Deep work mode - check back later",
    icon: "🎧",
    color: "orange",
    is_active: false,
    display_order: 3
  },
  %{
    name: "On a Call",
    message: "On a call",
    icon: "📞",
    color: "red",
    is_active: false,
    display_order: 4
  },
  %{
    name: "Break",
    message: "Taking a break, back soon",
    icon: "☕",
    color: "yellow",
    is_active: false,
    display_order: 5
  },
  %{
    name: "Away",
    message: "Away from desk",
    icon: "🚶",
    color: "gray",
    is_active: false,
    display_order: 6
  }
]

# Only seed if statuses table is empty
if Repo.aggregate(Status, :count, :id) == 0 do
  Enum.each(statuses, fn attrs ->
    %Status{}
    |> Status.changeset(attrs)
    |> Repo.insert!()
  end)

  IO.puts("✓ Seeded #{length(statuses)} default statuses")
else
  IO.puts("Statuses already exist, skipping seed")
end
