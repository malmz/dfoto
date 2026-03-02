defmodule DFoto.Gallery do
  @moduledoc """
  The Gallery context.
  """
  import Ecto.Query, warn: false
  alias DFoto.Repo

  alias DFoto.Gallery.Album
  alias DFoto.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any album changes.

  The broadcasted messages match the pattern:

    * {:created, %Album{}}
    * {:updated, %Album{}}
    * {:deleted, %Album{}}

  """
  def subscribe_albums(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(DFoto.PubSub, "user:#{key}:albums")
  end

  defp broadcast_album(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(DFoto.PubSub, "user:#{key}:albums", message)
  end

  @doc """
  Returns the list of albums.

  ## Examples

      iex> list_albums(scope)
      [%Album{}, ...]

  """
  def list_albums(%Scope{} = scope) do
    Repo.all(Album)
  end

  @doc """
  Returns the list of albums.

  ## Examples

      iex> list_published_albums(scope)
      [%Album{}, ...]

  """
  def list_published_albums() do
    Repo.all_by(Album, state: :published)
  end

  def search_albums(query) do
    Album
    |> where(state: :published)
    |> where(
      fragment(
        "to_tsvector('swedish', title || ' ' || description) @@ websearch_to_tsquery('swedish', ?)",
        ^query
      )
    )
    |> Repo.all()
  end

  @doc """
  Publishes an album.

  Sets the album status to :published and automatically assigns a thumbnail
  from the first image if no thumbnail is set.

  ## Examples

      iex> publish_album(album)
      {:ok, %Album{}}

      iex> publish_album(album)
      {:error, %Ecto.Changeset{}}

  """
  def publish_album(%Album{status: :published}) do
    {:error, "Album is already published"}
  end

  def publish_album(%Album{} = album) do
    album =
      if is_nil(album.thumbnail_id) do
        first_image =
          Repo.one(
            from(i in DFoto.Gallery.Image,
              where: i.album_id == ^album.id,
              order_by: [asc: i.inserted_at],
              limit: 1
            )
          )

        if first_image do
          %{album | thumbnail_id: first_image.id}
        else
          album
        end
      else
        album
      end

    album
    |> Album.changeset(%{status: :published})
    |> Repo.update()
  end

  @doc """
  Gets a single album.

  Raises `Ecto.NoResultsError` if the Album does not exist.

  ## Examples

      iex> get_album!(scope, 123)
      %Album{}

      iex> get_album!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_album!(%Scope{} = scope, id) do
    Repo.get_by!(Album, id: id)
  end

  def get_album_with_images!(%Scope{} = scope, id) do
    query =
      from a in Album,
        join: i in assoc(m, :images),
        preload: [images: i]

    Repo.get_by!(query, id: id)
  end

  @doc """
  Creates a album.

  ## Examples

      iex> create_album(scope, %{field: value})
      {:ok, %Album{}}

      iex> create_album(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_album(%Scope{} = scope, attrs) do
    with {:ok, album = %Album{}} <-
           %Album{}
           |> Album.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_album(scope, {:created, album})
      {:ok, album}
    end
  end

  @doc """
  Updates a album.

  ## Examples

      iex> update_album(scope, album, %{field: new_value})
      {:ok, %Album{}}

      iex> update_album(scope, album, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_album(%Scope{} = scope, %Album{} = album, attrs) do
    true = album.user_id == scope.user.id

    with {:ok, album = %Album{}} <-
           album
           |> Album.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_album(scope, {:updated, album})
      {:ok, album}
    end
  end

  @doc """
  Deletes a album.

  ## Examples

      iex> delete_album(scope, album)
      {:ok, %Album{}}

      iex> delete_album(scope, album)
      {:error, %Ecto.Changeset{}}

  """
  def delete_album(%Scope{} = scope, %Album{} = album) do
    true = album.user_id == scope.user.id

    with {:ok, album = %Album{}} <-
           Repo.delete(album) do
      broadcast_album(scope, {:deleted, album})
      {:ok, album}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking album changes.

  ## Examples

      iex> change_album(scope, album)
      %Ecto.Changeset{data: %Album{}}

  """
  def change_album(%Scope{} = scope, %Album{} = album, attrs \\ %{}) do
    true = album.user_id == scope.user.id

    Album.changeset(album, attrs, scope)
  end
end
