defmodule ParentcontrolswinWeb.PageController do
  use ParentcontrolswinWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home) #, layout: false)
  end

  def contact(conn, _params) do
    render(conn, :contact)
  end

  def content_filter_faq(conn, _params) do
    render(conn, :content_filter_faq)
  end
end
