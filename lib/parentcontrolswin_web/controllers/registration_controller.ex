defmodule ParentcontrolswinWeb.RegistrationController do
  use ParentcontrolswinWeb, :controller
#  use Pow.Phoenix.Controller
  alias Recaptcha

#  plug :verify_recaptcha when action in [:create]

  def create(conn, %{"user" => user_params}) do
    IO.inspect(conn.params["g-recaptcha-response"], label: "reCAPTCHA Response")

    case Recaptcha.verify(conn.params["g-recaptcha-response"]) do
    # case verify_recaptcha(conn.params["g-recaptcha-response"]) do
      {:ok, response} ->
        IO.inspect(response, label: "IN OK RESP")
        # super(conn, %{"user" => user_params}) # Call the default Pow registration logic
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
            #render(conn, "new.html", changeset: changeset)
        end
      {:error, message} ->
        IO.inspect(message, label: "IN ERROR RESP")
        conn
        |> put_flash(:error, "CAPTCHA verification failed.")
        |> redirect(to: ~p"/registration/new")
    end
  end

  def verify_recaptcha(recaptcha_response) do
    case Recaptcha.verify(recaptcha_response) do
      "" ->
        IO.inspect("returned empty string") 
        {:error, "Invalid captcha"}
      _ ->
        IO.inspect("returned full string")
        {:ok}
    end
  end
end