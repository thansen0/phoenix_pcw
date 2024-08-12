defmodule ParentcontrolswinWeb.DeviceController do
  use ParentcontrolswinWeb, :controller
  import Ecto.Query, only: [from: 2]
  require Logger

  alias Parentcontrolswin.Devices
  alias Parentcontrolswin.Devices.Device

  def index(conn, _params) do
    # make sure user is subscribed, otherwise send them to subscribe
    user = Pow.Plug.current_user(conn)
    if !ParentcontrolswinWeb.SubscriptionController.is_subscribed?(user) do
      conn
      |>put_flash(:error, "You must subscribe to view your devices. All subscriptions have a 30 day money back guarantee.")
      |>redirect(to: ~p"/subscriptions")
    end

    csrf_token = Plug.CSRFProtection.get_csrf_token()
    checkbox_form_action = ~p"/device_form_action"

    updated_cache_content_filters = Parentcontrolswin.Repo.get_by(Parentcontrolswin.Users.User, email: user.email).content_filters
    content_filters = String.split(updated_cache_content_filters, ",")
    devices = Parentcontrolswin.Repo.all(from d in Device, where: d.user_id == ^user.id, order_by: [desc: d.inserted_at])

    #Logger.info("filters #{content_filters}")

    render(conn, :index, 
        devices: devices, 
        checkbox_form_action: checkbox_form_action,
        content_filters: content_filters,
        csrf_token: csrf_token)
  end

  def new(conn, _params) do
    user = Pow.Plug.current_user(conn)
    changeset = Devices.change_device(%Device{user_id: user.id})
    render(conn, :new, changeset: changeset)
  end

  # only works for json, returns json
  def create(conn, %{"device" => device_params}) do
    # IO.inspect(conn.body_params, label: "Received body params")
    user = Pow.Plug.current_user(conn)
    modified_device_params = Map.put(device_params, "user_id", user.id)

    case Devices.create_device(modified_device_params) do
      {:ok, device} ->
        conn
        |> put_status(:created) # Set the HTTP status to 201 (Created)
        |> json(%{data: %{id: device.id} })

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    csrf_token = Plug.CSRFProtection.get_csrf_token()
    user = Pow.Plug.current_user(conn)
    device = Devices.get_device!(id)
    timezone = device.timezone
    
    is_internet_allowed = get_device_schedule(device)
    # Logger.info("is_internet_allowed #{inspect(is_internet_allowed)}")

    changeset = Devices.change_device(device, %{
      "timezone" => timezone,
      "is_internet_allowed" => is_internet_allowed
    })

    conn
    |> assign(:page_title, "Viewing Device")
    |> render(:show, device: device, user: user, timezone: timezone, is_internet_allowed: is_internet_allowed, csrf_token: csrf_token, changeset: changeset)
    # is_internet_allowed: is_internet_allowed, 
  end

  # "is_internet_allowed" => internetallowed_params, "timezone" => timezone, 
  def updateallowedhours(conn, %{"id" => id, "device" => device_params, "f" => f}) do
    device = Devices.get_device!(id)

    #Logger.info("Change log: #{inspect(internetallowed_params)}")
    is_internet_allowed = get_empty_day_hour_map(false)

    is_internet_allowed = Enum.reduce(f[":is_internet_allowed"], is_internet_allowed, fn {key, value}, acc ->
      updated_value = Map.merge(Map.get(acc, key, %{}), conv_on_to_true(value))
      Map.put(acc, key, updated_value)
    end)

    # Logger.debug("is_internet_allowed: #{inspect(is_internet_allowed)}")
    Logger.debug("updateallowedhours device_params: #{inspect(device_params)}")
    IO.inspect(device_params["timezone"])

    # changeset = Devices.change_device(device, device_params)
    changeset = Ecto.Changeset.change(device, is_allowed_schedule: is_internet_allowed, timezone: device_params["timezone"])
    case Parentcontrolswin.Repo.update(changeset) do
      {:ok, _device} ->
        conn
        |> put_flash(:info, "Device Schedule Updated Successfully.")
        |> assign(:page_title, "Updated Hours for Device")
        |> redirect(to: ~p"/devices/#{device}")
      {:error, nil} ->
        conn
        |> put_flash(:error, "Device Schedule Failed to Update.")
        |> redirect(to: ~p"/devices/#{device}")
    end
  end

  def updateallowedhours(conn, %{"id" => id}) do
    device = Devices.get_device!(id)

    #Logger.info("Change log: #{inspect(internetallowed_params)}")

    # TODO consider passing internetallowed_params back into redirect?
    conn
    |> put_flash(:error, "You must set a timezone.")
    |> assign(:page_title, "Device Page")
    |> redirect(to: ~p"/devices/#{device}")
  end

  def edit(conn, %{"id" => id}) do
    device = Devices.get_device!(id)
    changeset = Devices.change_device(device)
    render(conn, :edit, device: device, changeset: changeset)
  end

  def update(conn, %{"id" => id, "device" => device_params}) do
    device = Devices.get_device!(id)

    case Devices.update_device(device, device_params) do
      {:ok, device} ->
        conn
        |> put_flash(:info, "Device updated successfully.")
        |> redirect(to: ~p"/devices/#{device}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, device: device, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    device = Devices.get_device!(id)
    {:ok, _device} = Devices.delete_device(device)

    conn
    |> put_flash(:info, "Device deleted successfully.")
    |> redirect(to: ~p"/devices")
  end

  # custom controller methods
  def checkbox_form_submission(conn, params) do
    user = Pow.Plug.current_user(conn)
    checkbox_fields = [:nsfw, :trans, :lgbt, :genai, :atheism, :drug, :weed, :alcohol, :tobacco, :antiwork, :antiparent, :shortvideo, :safesearch, :gambling, :nonmonogamy, :suicide, :socialism, :communism]

    # Filtering and joining checked options
    checked_options = 
      checkbox_fields
      |> Enum.filter(fn field -> Map.has_key?(params, Atom.to_string(field)) end)
      |> Enum.map(&Atom.to_string/1)
      |> Enum.join(",")

    changeset = Ecto.Changeset.change(user, content_filters: checked_options)
    case Parentcontrolswin.Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Filter successfully updated.") # to #{checked_options}
        |> redirect(to: ~p"/devices")
      {:error, nil} ->
        conn
        |> put_flash(:error, "Filter failed to update.")
        |> redirect(to: ~p"/devices")
    end
  end

  def checkbox_checked?(is_internet_allowed, day, hour) do
    hour = Integer.to_string(hour)
    day = Integer.to_string(day)

    # Logger.info("checkbox checked?: #{inspect(is_internet_allowed)}\n\n")

    case Map.get(is_internet_allowed, day) do
      nil -> false
      day_map -> Map.get(day_map, hour, false)
    end
  end

  defp conv_on_to_true(mm) do
    mm
    |> Enum.map(fn
      {key, "on"} -> {key, true}
      {key, true} -> {key, true}
      {key, _} -> {key, false}
    end)
    |> Enum.into(%{})
  end

  defp get_device_schedule(device) do
    case device.is_allowed_schedule do
      nil ->
        Logger.info("is_allowed_schedule is nil")
        get_empty_day_hour_map(true)
      %{} when map_size(device.is_allowed_schedule) == 0 ->
        Logger.info("is_allowed_schedule is an empty map")
        get_empty_day_hour_map(true)
      _ ->
        Logger.info("is_allowed_schedule has data")
        device.is_allowed_schedule
    end
  end

  defp get_empty_day_hour_map(set_value) do
    for day <- 0..6, into: %{} do
      { Integer.to_string(day), for hour <- 0..23, into: %{} do
      { Integer.to_string(hour) , set_value }
      end}
    end
  end
end