defmodule DfotoWeb.PageController do
  use DfotoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
