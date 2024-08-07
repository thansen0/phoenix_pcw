# lib/my_app_web/controllers/subscription_controller.ex
defmodule ParentcontrolswinWeb.SubscriptionController do
    use ParentcontrolswinWeb, :controller
    alias Stripe
    require Logger

    def index(conn, _params) do
        render(conn, :index)
    end

    def success(conn, _params) do
        conn
        |> put_flash(:info, "Thanks you for subscribing! Don't hesistate to contact us if you have any questions!")
        |> redirect(to: ~p"/install_pcw")
    end

    def cancel(conn, _params) do
        conn
        |> put_flash(:error, "Your attempt to subscribe was canceled; are not subscribed.")
        |> redirect(to: ~p"/subscriptions")
    end

    def new(conn, %{}) do
        # Or if it is a recurring customer, you can provide customer_id
        user = Pow.Plug.current_user(conn)
        customer_id = stripe_customer_id(conn, user)
        
        # Get this from the Stripe dashboard for your product
        price_id = Application.get_env(:stripity_stripe, :stripe_price_id)
        coupon_id = Application.get_env(:stripity_stripe, :stripe_coupon_id)
        quantity = 1

        # Logger.info("Customer id: #{customer_id}")
        # should never be empty after stripe_customer_id
        if customer_id in [nil, ""] do
            conn
            |> put_flash(:error, "Error finding your customer id. Please try again or contact support. #{customer_id}")
            |> redirect(to: ~p"/subscriptions")
        end

        checkout_session = %{
            payment_method_types: ["card"],
            customer: customer_id,
            mode: "subscription",
            discounts: [%{
                coupon: coupon_id
            }],
            line_items: [%{
                price: price_id,
                quantity: quantity
            }],
            success_url: build_external_url("/subscriptions/new/success"),
            cancel_url: build_external_url("/subscriptions/new/cancel")
        }
        
        session = case Stripe.Checkout.Session.create(checkout_session) do
            {:ok, session} ->
                session
            {:error, stripe_error} ->
                conn
                |> put_flash(:error, "Something went bringing you to checkout; #{stripe_error.message}")
                |> redirect(to: ~p"/subscriptions")
        end

        # Logger.info(IO.inspect(session))
        redirect(conn, external: session.url)
    end

    def edit(conn, %{}) do
        user = Pow.Plug.current_user(conn)
        customer_id = get_stripe_customer_id_from_email(user.email)
        if customer_id in [nil, ""] do
            conn
            |> put_flash(:error, "You must subscribe first before viewing Stripe Account Management. #{customer_id}")
            |> redirect(to: ~p"/subscriptions")
        end

        billing_page = Stripe.BillingPortal.Session.create(%{
            customer: customer_id,
            return_url: build_external_url("/devices")
        })

        case billing_page do
            {:ok, session} ->
                redirect(conn, external: session.url)

            {:error, stripe_error} ->
                IO.inspect(stripe_error)
                conn
                |> put_flash(:error, "Something went wrong with edit. #{stripe_error.message}")
                |> redirect(to: ~p"/")
        end
    end

    # check if a customer id exists, and if so return a new one
    defp stripe_customer_id(conn, user) do
        # trying to solve a caching issue with Pow
        stripe_customer_id = get_stripe_customer_id_from_email(user.email)

        if stripe_customer_id in [nil, ""] do
            new_customer = %{
                email: user.email,
                description: "Subscription user"
            }

            # {:ok, stripe_customer} = Stripe.Customer.create(new_customer)
            stripe_customer_id = case Stripe.Customer.create(new_customer) do
                {:ok, stripe_customer} -> 
                    stripe_customer.id
                {:error, stripe_customer_error} -> 
                    conn
                    |> put_flash(:error, "Error getting stripe_customer_id. Error: #{stripe_customer_error.message}")
                    |> redirect(to: ~p"/subscriptions")
                    nil
            end

            if stripe_customer_id do
                # create changeset for user
                changeset = Parentcontrolswin.Users.User.update_stripe_customer_id_changeset(user, %{stripe_customer_id: stripe_customer_id})
                case Parentcontrolswin.Repo.update(changeset) do
                    {:ok, _updated_user} ->
                        conn
                        # IO.inspect(updated_user)
                    {:error, _changeset} -> 
                        conn
                        |> put_flash(:error, "Error setting stripe_customer_id in schema.")
                        |> redirect(to: ~p"/subscriptions")
                end
            end

            stripe_customer_id
        else
            if is_subscribed?(user) do
                conn
                |> put_flash(:info, "Our records show you are currently subscribed! Please contact us if you do not believe this is the case or if you're experiencing issues.")
                |> redirect(to: ~p"/registration/edit")
            else
                # return 
                stripe_customer_id
            end
        end
    end

    # returns customer id but won't make a new one
    defp get_stripe_customer_id_from_email(email) do
        Parentcontrolswin.Repo.get_by(Parentcontrolswin.Users.User, email: email).stripe_customer_id
    end

    # returns true if subscribed
    def is_subscribed?(user) do
        customer_id = get_stripe_customer_id_from_email(user.email)

        # defined here for scope
        if customer_id in [nil, ""] do
            # no customer, can't be subscribed
            false
        else
            # case Stripe.Subscription.list(%{customer: customer_id, status: "active"}) do
            case Stripe.Subscription.list(%{customer: customer_id}) do
                {:ok, subscriptions} ->

                    Enum.any?(subscriptions.data, fn subscription ->
                        subscription.status == "active" || subscription.status == "trialing"
                    end)

                    # .data holds all of the subscriptions and metadata
                    # only [] actually matters, but just in case
                    # subscriptions.data not in [nil, "", []]
                {:error, _subscriptions} ->
                    false
            end
        end
    end

    # path MUST have a "/" before it
    def build_external_url(path) do
        # third arg is optional, default to production value
        base_url = Application.get_env(:parentcontrolswin, :base_url, "https://www.parentalcontrols.win")
        base_url <> path
    end
end