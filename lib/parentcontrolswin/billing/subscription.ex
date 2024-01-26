defmodule Parentcontrolswin.Billing.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    field :end_date, :date
    field :plan_tier, :integer, default: 0
    field :start_date, :date
    field :stripe_customer_id, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:stripe_customer_id, :plan_tier, :start_date, :end_date])
    |> validate_required([:stripe_customer_id, :plan_tier, :start_date, :end_date])
  end
end
