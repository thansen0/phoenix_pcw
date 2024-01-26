defmodule Parentcontrolswin.BillingTest do
  use Parentcontrolswin.DataCase

  alias Parentcontrolswin.Billing

  describe "subscriptions" do
    alias Parentcontrolswin.Billing.Subscription

    import Parentcontrolswin.BillingFixtures

    @invalid_attrs %{end_date: nil, plan_tier: nil, start_date: nil, stripe_customer_id: nil}

    test "list_subscriptions/0 returns all subscriptions" do
      subscription = subscription_fixture()
      assert Billing.list_subscriptions() == [subscription]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()
      assert Billing.get_subscription!(subscription.id) == subscription
    end

    test "create_subscription/1 with valid data creates a subscription" do
      valid_attrs = %{end_date: ~D[2024-01-22], plan_tier: 42, start_date: ~D[2024-01-22], stripe_customer_id: "some stripe_customer_id"}

      assert {:ok, %Subscription{} = subscription} = Billing.create_subscription(valid_attrs)
      assert subscription.end_date == ~D[2024-01-22]
      assert subscription.plan_tier == 42
      assert subscription.start_date == ~D[2024-01-22]
      assert subscription.stripe_customer_id == "some stripe_customer_id"
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billing.create_subscription(@invalid_attrs)
    end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()
      update_attrs = %{end_date: ~D[2024-01-23], plan_tier: 43, start_date: ~D[2024-01-23], stripe_customer_id: "some updated stripe_customer_id"}

      assert {:ok, %Subscription{} = subscription} = Billing.update_subscription(subscription, update_attrs)
      assert subscription.end_date == ~D[2024-01-23]
      assert subscription.plan_tier == 43
      assert subscription.start_date == ~D[2024-01-23]
      assert subscription.stripe_customer_id == "some updated stripe_customer_id"
    end

    test "update_subscription/2 with invalid data returns error changeset" do
      subscription = subscription_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.update_subscription(subscription, @invalid_attrs)
      assert subscription == Billing.get_subscription!(subscription.id)
    end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = Billing.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_subscription!(subscription.id) end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = Billing.change_subscription(subscription)
    end
  end
end
