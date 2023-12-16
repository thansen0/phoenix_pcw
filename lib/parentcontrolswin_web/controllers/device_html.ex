defmodule ParentcontrolswinWeb.DeviceHTML do
  use ParentcontrolswinWeb, :html

  embed_templates "device_html/*"

  @doc """
  Renders a device form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def device_form(assigns)
end
