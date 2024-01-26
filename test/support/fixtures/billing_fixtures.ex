defmodule Parentcontrolswin.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Parentcontrolswin.Billing` context.
  """

  @doc """
  Generate a subscription.
  """
  def subscription_fixture(attrs \\ %{}) do
    {:ok, subscription} =
      attrs
      |> Enum.into(%{
        end_date: ~D[2024-01-22],
        plan_tier: 42,
        start_date: ~D[2024-01-22],
        stripe_customer_id: "some stripe_customer_id"
      })
      |> Parentcontrolswin.Billing.create_subscription()

    subscription
  end
end
