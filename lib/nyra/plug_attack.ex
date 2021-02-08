defmodule Nyra.PlugAttack do
  use PlugAttack

  # Just in-case there are an overwhelming amount of auth attempts.
  rule "throttle by ip", conn do
    throttle(conn.remote_ip,
      period: 60_000,
      limit: 30,
      storage: {PlugAttack.Storage.Ets, Nyra.PlugAttack.Storage}
    )
  end
end
