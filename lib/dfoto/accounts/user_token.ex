defmodule Dfoto.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query
  alias Dfoto.Accounts.UserToken

  @rand_size 32

  @roles [dfoto: "dfoto", asp: "dfoto-asp"]

  schema "users_tokens" do
    field :token, :binary
    field :roles, {:array, Ecto.Enum}, values: @roles
    field :refresh_token, :string
    field :authenticated_at, :utc_datetime
    field :expires_at, :utc_datetime
    belongs_to :user, Dfoto.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix's default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(%{
        user: user,
        refresh_token: refresh_token,
        expires_at: expires_at,
        roles: roles
      }) do
    token = :crypto.strong_rand_bytes(@rand_size)
    dt = user.authenticated_at || DateTime.utc_now(:second)

    {token,
     %UserToken{
       token: token,
       user_id: user.id,
       refresh_token: refresh_token,
       expires_at: expires_at,
       roles: roles,
       authenticated_at: dt
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any, along with the token's creation time.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query =
      from token in UserToken,
        join: user in assoc(token, :user),
        where: [token: ^token],
        select:
          {%{user | authenticated_at: token.authenticated_at, roles: token.roles},
           token.expires_at}

    {:ok, query}
  end
end
