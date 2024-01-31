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

  def install_pcw(conn, _params) do
    render(conn, :install_pcw)
  end

  def privacy_policy(conn, _params) do
    render(conn, :privacy_policy)
  end

  def terms_of_service(conn, _params) do
    render(conn, :terms_of_service)
  end

  def downloads(conn, _params) do
    # make sure user is subscribed, otherwise send them to subscribe
    user = Pow.Plug.current_user(conn)
    if !ParentcontrolswinWeb.SubscriptionController.is_subscribed?(user.stripe_customer_id) do
      conn
      |>put_flash(:error, "You must subscribe to download the Windows client. All subscriptions have a 60 day money back guarantee")
      |>redirect(to: ~p"/subscriptions")
    else
      render(conn, :downloads)
    end
  end

  def installer_download(conn, _params) do
    file_path = Path.join(:code.priv_dir(:parentcontrolswin), "downloads/fake_installer.exe")
    conn
    |> put_resp_content_type("application/octet-stream")
    |> put_resp_header("content-disposition", "attachment; filename=\"fake_installer.exe\"")
    |> send_file(200, file_path)
  end
end
