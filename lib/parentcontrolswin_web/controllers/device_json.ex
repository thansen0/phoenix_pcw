defmodule ParentcontrolswinWeb.DeviceJSON do
  # alias Parentcontrolswin.Devices
  alias Parentcontrolswin.Devices.Device

  @doc """
  Renders a list of devices.
  """
  def index(%{devices: devices}) do
    %{data: for(device <- devices, do: data(device))}
  end

  @doc """
  Renders a single device.
  """
  def show(%{device: device}) do
    %{data: data(device)}
  end

  defp data(%Device{} = device) do
    %{
      id: device.id,
      name: device.name,
      user_id: device.user_id
    }
  end
end
