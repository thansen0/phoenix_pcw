defmodule ParentcontrolswinWeb.PageController do
  use ParentcontrolswinWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home) #, layout: false)
  end

  def contact(conn, _params) do
    render(conn, :contact, page_title: "Contact")
  end

  def content_filter_faq(conn, _params) do
    render(conn, :content_filter_faq, page_title: "Content Filter FAQ's")
  end

  def nsfw_ad_intake(conn, _params) do
    render(conn, :nsfw_ad_intake, page_title: "Sign up for ParentControlsWin")
  end

  def trans_ad_intake(conn, _params) do
    render(conn, :trans_ad_intake, page_title: "Sign up for ParentControlsWin")
  end

  def ad_intake(conn, _params) do
    render(conn, :ad_intake, page_title: "Sign up for ParentControlsWin")
  end

  def install_pcw(conn, _params) do
    render(conn, :install_pcw, page_title: "Install")
  end

  def privacy_policy(conn, _params) do
    render(conn, :privacy_policy, page_title: "Privacy Policy")
  end

  def terms_of_service(conn, _params) do
    file_path = Path.join(:code.priv_dir(:parentcontrolswin), "downloads/terms-of-use.pdf")
    conn
    |> put_resp_content_type("application/octet-stream")
    |> put_resp_header("content-disposition", "attachment; filename=\"terms-of-use.pdf\"")
    |> send_file(200, file_path)
  end

  def downloads(conn, _params) do
    # make sure user is subscribed, otherwise send them to subscribe
    user = Pow.Plug.current_user(conn)
    if !ParentcontrolswinWeb.SubscriptionController.is_subscribed?(user) do
      conn
      |>put_flash(:error, "You must subscribe to download the Windows client")
      |> assign(:page_title, "Downloads")
      |>redirect(to: ~p"/subscriptions")
    else
      render(conn, :downloads)
    end
  end

  def installer_download(conn, _params) do
    file_path = Path.join(:code.priv_dir(:parentcontrolswin), "downloads/ParentControlsWinSetup.exe")
    conn
    |> put_resp_content_type("application/octet-stream")
    |> put_resp_header("content-disposition", "attachment; filename=\"ParentControlsWinSetup.exe\"")
    |> send_file(200, file_path)
  end
end
