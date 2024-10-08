defmodule ParentcontrolswinWeb.RegistrationController do
  use ParentcontrolswinWeb, :controller
  alias Recaptcha

  # TODO I don't think I'm verifying captcha's correctly
  # https://developers.google.com/recaptcha/docs/verify#api-request
  def create(conn, %{"user" => user_params}) do
    # IO.inspect(conn.params["g-recaptcha-response"], label: "reCAPTCHA Response")

    case Recaptcha.verify(conn.params["g-recaptcha-response"]) do
      {:ok, _response} ->
        conn
        |> Pow.Plug.create_user(user_params)
        |> case do
          {:ok, _user, conn} ->
            conn
            |> put_flash(:info, "Welcome!")
            |> redirect(to: ~p"/subscriptions")

          {:error, changeset, conn} ->
            conn
            |> put_flash(:error, "CAPTCHA verification failed.")
            |> redirect(to: ~p"/registration/new", changeset: changeset)
        end
      {:error, _message} ->
        conn
        |> put_flash(:error, "CAPTCHA verification failed.")
        |> redirect(to: ~p"/registration/new")
    end
  end
end