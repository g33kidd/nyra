defmodule Nyra.Messaging.Message do
  defstruct author: nil, content: nil, sent_at: :os.system_time(:seconds)
end
