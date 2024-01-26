defmodule ParentcontrolswinWeb.SubscriptionControllerTest do
  use ParentcontrolswinWeb.ConnCase

  import Parentcontrolswin.BillingFixtures

  @create_attrs %{end_date: ~D[2024-01-22], plan_tier: 42, start_date: ~D[2024-01-22], stripe_customer_id: "some stripe_customer_id"}
  @update_attrs %{end_date: ~D[2024-01-23], plan_tier: 43, start_date: ~D[2024-01-23], stripe_customer_id: "some updated stripe_customer_id"}
  @invalid_attrs %{end_date: nil, plan_tier: nil, start_date: nil, stripe_customer_id: nil}

  describe "index" do
    test "lists all subscriptions", %{conn: conn} do
      conn = get(conn, ~p"/subscriptions")
      assert html_response(conn, 200) =~ "Listing Subscriptions"
    end
  end

  describe "new subscription" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/subscriptions/new")
      assert html_response(conn, 200) =~ "New Subscription"
    end
  end

  describe "create subscription" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/subscriptions", subscription: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/subscriptions/#{id}"

      conn = get(conn, ~p"/subscriptions/#{id}")
      assert html_response(conn, 200) =~ "Subscription #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/subscriptions", subscription: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Subscription"
    end
  end

  describe "edit subscription" do
    setup [:create_subscription]

    test "renders form for editing chosen subscription", %{conn: conn, subscription: subscription} do
      conn = get(conn, ~p"/subscriptions/#{subscription}/edit")
      assert html_response(conn, 200) =~ "Edit Subscription"
    end
  end

  describe "update subscription" do
    setup [:create_subscription]

    test "redirects when data is valid", %{conn: conn, subscription: subscription} do
      conn = put(conn, ~p"/subscriptions/#{subscription}", subscription: @update_attrs)
      assert redirected_to(conn) == ~p"/subscriptions/#{subscription}"

      conn = get(conn, ~p"/subscriptions/#{subscription}")
      assert html_response(conn, 200) =~ "some updated stripe_customer_id"
    end

    test "renders errors when data is invalid", %{conn: conn, subscription: subscription} do
      conn = put(conn, ~p"/subscriptions/#{subscription}", subscription: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Subscription"
    end
  end

  describe "delete subscription" do
    setup [:create_subscription]

    test "deletes chosen subscription", %{conn: conn, subscription: subscription} do
      conn = delete(conn, ~p"/subscriptions/#{subscription}")
      assert redirected_to(conn) == ~p"/subscriptions"

      assert_error_sent 404, fn ->
        get(conn, ~p"/subscriptions/#{subscription}")
      end
    end
  end

  defp create_subscription(_) do
    subscription = subscription_fixture()
    %{subscription: subscription}
  end
end
