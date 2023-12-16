defmodule Parentcontrolswin.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Parentcontrolswin.Devices` context.
  """

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        name: "some name",
        user_id: 42
      })
      |> Parentcontrolswin.Devices.create_device()

    device
  end
end
