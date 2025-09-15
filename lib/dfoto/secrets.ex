defmodule Dfoto.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Dfoto.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:dfoto, :token_signing_secret)
  end

  def secret_for(
        [:authentication, :strategies, :authentik, :client_id],
        Dfoto.Accounts.User,
        _opts,
        _context
      ) do
    get_authentik(:client_id)
  end

  def secret_for(
        [:authentication, :strategies, :authentik, :client_secret],
        Dfoto.Accounts.User,
        _opts,
        _context
      ) do
    get_authentik(:client_secret)
  end

  def secret_for(
        [:authentication, :strategies, :authentik, :base_url],
        Dfoto.Accounts.User,
        _opts,
        _context
      ) do
    get_authentik(:base_url)
  end

  def secret_for(
        [:authentication, :strategies, :authentik, :redirect_uri],
        Dfoto.Accounts.User,
        _opts,
        _context
      ) do
    get_authentik(:redirect_uri)
  end

  defp get_authentik(key) do
    Application.get_env(:dfoto, :authentik, [])
    |> Keyword.fetch(key)
  end
end
