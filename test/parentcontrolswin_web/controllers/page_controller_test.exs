defmodule ParentcontrolswinWeb.PageControllerTest do
  use ParentcontrolswinWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200)
  end

  test "GET /contact", %{conn: conn} do
    conn = get(conn, ~p"/contact")
    assert html_response(conn, 200)
  end
end
