# test/my_app_web/controllers/api/v1/registration_controller_test.exs
defmodule ParentcontrolswinWeb.API.V1.RegistrationControllerTest do
  use ParentcontrolswinWeb.ConnCase

  @password "secret1234"

# removed signup from api
#   describe "create/2" do
#     @valid_params %{"user" => %{"email" => "test@example.com", "password" => @password, "password_confirmation" => @password}}
#     @invalid_params %{"user" => %{"email" => "invalid", "password" => @password, "password_confirmation" => ""}}

#     test "with valid params", %{conn: conn} do
#       conn = post(conn, ~p"/registration", @valid_params)

#       assert json = json_response(conn, 200)
#       assert json["data"]["access_token"]
#       assert json["data"]["renewal_token"]
#     end

#     test "with invalid params", %{conn: conn} do
#       conn = post(conn, ~p"/registration", @invalid_params)

#       assert json = json_response(conn, 500)
#       assert json["error"]["message"] == "Couldn't create user"
#       assert json["error"]["status"] == 500
#       assert json["error"]["errors"]["password_confirmation"] == ["does not match confirmation"]
#       assert json["error"]["errors"]["email"] == ["has invalid format"]
#     end
#   end
end