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
      |>put_flash(:error, "You must subscribe to view your devices. All subscriptions have a 30 day money back guarantee!")
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
    user = Pow.Plug.current_user(conn)
    device = Devices.get_device!(id)
    conn
    |> assign(:page_title, "Viewing Device")
    |> render(:show, device: device, user: user)
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
    checkbox_fields = [:nsfw, :trans, :lgbt, :genai, :atheism, :drug, :weed, :alcohol, :tobacco]

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
        |> put_flash(:info, "Filter successfully updated to #{checked_options}.")
        |> redirect(to: ~p"/devices")
      {:error, nil} ->
        conn
        |> put_flash(:error, "Filter failed to update.")
        |> redirect(to: ~p"/devices")
    end
  end
end
