defmodule OfficeStatus.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix installed.
  """
  @app :office_status

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def seed do
    load_app()

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn _repo ->
          seed_path = priv_path_for(repo, "seeds.exs")

          if File.exists?(seed_path) do
            Code.eval_file(seed_path)
          end
        end)
    end
  end

  def update_icons do
    load_app()

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn _repo ->
          import Ecto.Query
          alias OfficeStatus.Statuses.Status

          # Update to e-ink friendly icons
          repo.update_all(from(s in Status, where: s.name == "Available"), set: [icon: "✓"])
          repo.update_all(from(s in Status, where: s.name == "In a Meeting"), set: [icon: "⛔"])

          IO.puts("✓ Updated icons for e-ink displays")
        end)
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config(), :otp_app)
    priv_dir = Application.app_dir(app, "priv")
    Path.join([priv_dir, "repo", filename])
  end
end
