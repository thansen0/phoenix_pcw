defmodule ParentcontrolswinWeb.DeviceController do
  use ParentcontrolswinWeb, :controller

  alias Parentcontrolswin.Devices
  alias Parentcontrolswin.Devices.Device

  def index(conn, _params) do
    devices = Devices.list_devices()
    render(conn, :index, devices: devices)
  end

  def new(conn, _params) do
    changeset = Devices.change_device(%Device{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"device" => device_params}) do
    case Devices.create_device(device_params) do
      {:ok, device} ->
        conn
        |> put_flash(:info, "Device created successfully.")
        |> redirect(to: ~p"/devices/#{device}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    device = Devices.get_device!(id)
    render(conn, :show, device: device)
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
