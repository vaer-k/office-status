defmodule OfficeStatus.Repo do
  use Ecto.Repo,
    otp_app: :office_status,
    adapter: Ecto.Adapters.Postgres
end
