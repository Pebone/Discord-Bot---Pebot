defmodule Pebot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Pebot.Consumer
      # Starts a worker by calling: Pebot.Worker.start_link(arg)
      # {Pebot.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pebot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
