defmodule Dfoto.CustomFunctions do
  defmacro to_tsvector(lang, body) do
    quote do
      fragment("to_tsvector(?, ?)", unquote(lang), unquote(body))
    end
  end

  defmacro websearch_to_tsquery(lang, query) do
    quote do
      fragment("websearch_to_tsquery(?, ?)", unquote(lang), unquote(query))
    end
  end

  defmacro tsquery_match(left, right) do
    quote do
      fragment("? @@ ?", unquote(left), unquote(right))
    end
  end
end
