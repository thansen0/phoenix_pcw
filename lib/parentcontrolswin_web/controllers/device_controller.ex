defmodule ParentcontrolswinWeb.DeviceController do
  use ParentcontrolswinWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias Parentcontrolswin.Devices
  alias Parentcontrolswin.Devices.Device

  def index(conn, _params) do
    user = Pow.Plug.current_user(conn)
    # devices = Devices.list_devices()
    devices = Parentcontrolswin.Repo.all(from d in Device, where: d.user_id == ^user.id, order_by: [desc: d.inserted_at])
    render(conn, :index, devices: devices)
  end

  def new(conn, _params) do
    user = Pow.Plug.current_user(conn)
    changeset = Devices.change_device(%Device{user_id: user.id})
    render(conn, :new, changeset: changeset)
  end

  # only works for json right now
  def create(conn, %{"device" => device_params}) do
    IO.inspect(conn.body_params, label: "Received body params")
    user = Pow.Plug.current_user(conn)
    modified_device_params = Map.put(device_params, "user_id", user.id)

    case Devices.create_device(modified_device_params) do
      {:ok, device} ->
        conn
#        |> put_flash(:info, "Device created successfully.") # errors on json
#        |> redirect(to: ~p"/devices/#{device}")
        |> redirect(to: ~p"/api/v1/devices/#{device}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Pow.Plug.current_user(conn)
    device = Devices.get_device!(id)
    conn
    |> assign(:user, user)
    |> render(:show, device: device)
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
end
