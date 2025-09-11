defmodule Dfoto.GalleryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dfoto.Gallery` context.
  """

  @doc """
  Generate a album.
  """
  def album_fixture(attrs \\ %{}) do
    {:ok, album} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title"
      })
      |> Dfoto.Gallery.create_album()

    album
  end
end
