defmodule Dfoto.Utils do
  defmacro static_member?(enumerable, value) do
    quote do
      case unquote(value) do
        x when x in unquote(enumerable) -> true
        _ -> false
      end
    end
  end
end
