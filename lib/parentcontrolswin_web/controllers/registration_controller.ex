defmodule ParentcontrolswinWeb.RegistrationController do
  use ParentcontrolswinWeb, :controller
  #use Pow.Phoenix.Controllers.Registration, otp_app: :parentcontrolswin

  alias Recaptcha

  def create(conn, %{"user" => user_params}) do
    case Recaptcha.verify(conn.params["g-recaptcha-response"]) do
      {:ok, _response} ->
        # super(conn, %{"user" => user_params}) # Call the default Pow registration logic
        conn
        |> Pow.Plug.create_user(user_params)
        |> case do
          {:ok, user, conn} ->
            conn
            |> put_flash(:info, "Welcome!")
            |> redirect(to: ~p"/subscriptions")

          {:error, changeset, conn} ->
            conn
            #|> put_flash(:error, "CAPTCHA verification failed.")
            |> redirect(to: ~p"/registration/new", changeset: changeset)
            #render(conn, "new.html", changeset: changeset)
        end
      {:error, _reason} ->
        conn
        |> put_flash(:error, "CAPTCHA verification failed.")
        |> redirect(to: ~p"/registration/new")
    end
  end
end