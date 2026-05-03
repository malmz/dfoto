defmodule DFotoWeb.AuthController do
  use DFotoWeb, :controller
  require Logger
  alias Oidcc.Plug.AuthorizationCallback

  plug Oidcc.Plug.Authorize,
       [
         provider: Application.compile_env(:dfoto, [__MODULE__, :provider]),
         client_id: &__MODULE__.client_id/0,
         client_secret: &__MODULE__.client_secret/0,
         redirect_uri: &__MODULE__.callback_uri/0
       ]
       when action in [:authorize]

  plug AuthorizationCallback,
       [
         provider: Application.compile_env(:dfoto, [__MODULE__, :provider]),
         client_id: &__MODULE__.client_id/0,
         client_secret: &__MODULE__.client_secret/0,
         redirect_uri: &__MODULE__.callback_uri/0
       ]
       when action in [:callback]

  def authorize(conn, _params) do
    conn
  end

  def callback(
        %Plug.Conn{private: %{AuthorizationCallback => {:ok, {token, user_info}}}} = conn,
        params
      ) do
    Logger.debug("Userinfo: #{inspect(user_info)}")
    Logger.debug("Tokens: #{inspect(token)}")

    DFoto.Accounts.update_user_info(user_info)

    DFoto.Accounts.User
    |> Ash.Changeset.for_create(:login, %{user_info: user_info, tokens: token})
    |> Ash.create!()

    conn
    |> put_session("oidcc_claims", user_info)
    |> redirect(
      to:
        case params[:state] do
          nil -> "/"
          state -> state
        end
    )
  end

  def callback(%Plug.Conn{private: %{AuthorizationCallback => {:error, reason}}} = conn, _params) do
    conn |> put_status(400) |> render(:error, reason: reason)
  end

  @doc false
  def client_id do
    Application.fetch_env!(:dfoto, :authentik)[:client_id]
  end

  @doc false
  def client_secret do
    Application.fetch_env!(:dfoto, :authentik)[:client_secret]
  end

  @doc false
  def callback_uri do
    url(~p"/auth/callback")
  end
end
