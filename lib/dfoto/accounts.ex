defmodule Dfoto.Accounts do
  import Ecto.Query
  alias Dfoto.Repo
  alias Dfoto.Accounts.{User, UserToken}
  import Dfoto.Utils

  @roles ["dfoto", "dfoto-asp"]

  def update_user_info!(%{"name" => name, "sub" => authentik_id}) do
    attrs = %{name: name, authentik_id: authentik_id}

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!(
      on_conflict: {:replace, [:name]},
      conflict_target: :authentik_id
    )
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## Settings

  @doc """
  Checks whether the user is in sudo mode.

  The user is in sudo mode when the last authentication was done no further
  than 20 minutes ago. The limit can be given as second argument in minutes.
  """
  def sudo_mode?(user, minutes \\ -20)

  def sudo_mode?(%User{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    DateTime.after?(ts, DateTime.utc_now() |> DateTime.add(minutes, :minute))
  end

  def sudo_mode?(_user, _minutes), do: false

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user, %Oidcc.Token{} = token) do
    roles =
      token.id.claims["groups"]
      |> Enum.map(&String.downcase/1)
      |> Enum.filter(&static_member?(@roles, &1))

    params = %{
      user: user,
      refresh_token: token.refresh,
      expires_at: token.access.expires_at,
      roles: roles
    }

    {token, user_token} = UserToken.build_session_token(params)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.

  If the token is valid `{user, token_inserted_at}` is returned, otherwise `nil` is returned.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(from(UserToken, where: [token: ^token]))
    :ok
  end
end
