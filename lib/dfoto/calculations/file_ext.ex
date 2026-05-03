defmodule Dfoto.Calculations.FileExt do
  use Ash.Resource.Calculation

  @impl true
  def init(opts) do
    if opts[:key] && is_atom(opts[:key]) do
      {:ok, opts[:key]}
    else
      {:error, "Expected a `key` option for which key to get extention from"}
    end
  end

  @impl true
  def calculate(records, opts, _context) do
    {:ok,
     Enum.map(records, fn record ->
       Map.get(record, opts)
       |> Path.extname()
     end)}
  end
end
