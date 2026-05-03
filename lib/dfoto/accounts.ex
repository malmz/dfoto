defmodule Dfoto.Accounts do
  alias Dfoto.Repo
  alias Dfoto.Accounts.User

  def update_user_info(user_info) do
    name = user_info["name"]
    authentik_id = user_info["sub"]

    attrs = %{name: name, authentik_id: authentik_id}

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!(
      on_conflict: {:replace, [:name]},
      conflict_target: :authentik_id
    )
  end
end
