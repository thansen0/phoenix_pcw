defmodule ParentcontrolswinWeb.API.V1.SessionController do
  use ParentcontrolswinWeb, :controller
  require Logger

  alias ParentcontrolswinWeb.APIAuthPlug
  alias Plug.Conn

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> case do
      {:ok, conn} ->
        json(conn, %{data: %{access_token: conn.private.api_access_token, renewal_token: conn.private.api_renewal_token}})

      {:error, conn} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid email or password"}})
    end
  end

  @spec renew(Conn.t(), map()) :: Conn.t()
  def renew(conn, _params) do
    config = Pow.Plug.fetch_config(conn)

    conn
    |> APIAuthPlug.renew(config)
    |> case do
      {conn, nil} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid token"}})

      {conn, _user} ->
        json(conn, %{data: %{access_token: conn.private.api_access_token, renewal_token: conn.private.api_renewal_token}})
    end
  end

  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> json(%{data: %{}})
  end

  # added after the fact, not great placement
  @spec getContentFilters(Conn.t(), map()) :: Conn.t()
  def getContentFilters(conn, _params) do
    current_user = Pow.Plug.current_user(conn)
    content_filters = current_user.content_filters
    conn
    |> json(%{data: %{content_filters: content_filters}})
  end

  def getURDeviceInfo(conn, params) do
    with {:ok, device_id} <- validate_param(params["device_id"], "device_id"),
        {:ok, user_email} <- validate_param(params["email"], "email") do

      content_filters = getContentFiltersFromEmail(user_email)
      is_internet_allowed = getInternetScheduleFromDeviceId(device_id)
      timezone = getTimezoneFromDeviceId(device_id)

      conn
      |> json(%{is_internet_allowed: is_internet_allowed, timezone: timezone, content_filters: content_filters})

    else
      {:error, message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: message})
    end
  end

  defp getContentFiltersFromEmail(email) do
    Parentcontrolswin.Repo.get_by(Parentcontrolswin.Users.User, email: email).content_filters
  end

  defp getInternetScheduleFromDeviceId(device_id) do
    Parentcontrolswin.Repo.get_by(Parentcontrolswin.Devices.Device, id: device_id).is_allowed_schedule
  end

  defp getTimezoneFromDeviceId(device_id) do
    Parentcontrolswin.Repo.get_by(Parentcontrolswin.Devices.Device, id: device_id).timezone
  end

  defp validate_param(param, param_name) do
    case param do
      nil -> {:error, "#{param_name} is required"}
      "" -> {:error, "#{param_name} cannot be empty"}
      _ -> {:ok, param}
    end
  end
end