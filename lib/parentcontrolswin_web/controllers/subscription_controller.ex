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
        |> redirect(to: ~p"/subscriptions/new/success")
    end

    def cancel(conn, _params) do
        conn
        |> put_flash(:info, "Your attempt to subscribe was canceled; are not subscribed.")
        |> redirect(to: ~p"/subscriptions/new/cancel")
    end

    defp get_customer_from_email(email) do
        # TODO: Handle storing and retrieving customer_id
        # Is on the format
        # nil
        Parentcontrolswin.Repo.get_by(Parentcontrolswin.Users.User, email: email).stripe_customer_id
        # customer_id = "cus_PQMm8X3Ep8EL6G"
    end

    def new(conn, %{}) do
        # Or if it is a recurring customer, you can provide customer_id
        user = Pow.Plug.current_user(conn)
        customer_id = stripeCustomerId(conn, user)
        # Get this from the Stripe dashboard for your product
        price_id = "price_1ObHZ6DrVDu5S9fVokHH2Fbt"
        product_id = "prod_PSEzDvsCNOKrGu" # maybe I should be using this?
        quantity = 1

        Logger.info("Customer id: #{customer_id}")
        # should never be empty after stripeCustomerId
        if customer_id in [nil, ""] do
            conn
            |> put_flash(:error, "You must subscribe first before viewing Stripe Account Management. #{customer_id}")
            |> redirect(to: ~p"/subscriptions")
        end

        subscription_config = %{
            customer: customer_id,
            # success_url: "https://www.parentcontrols.win/subscriptions/new/success",
            # cancel_url: "https://www.parentcontrols.win/subscriptions/new/cancel",
            # mode: "subscription",
            items: [
            %{
                price: price_id,
                quantity: quantity
            }],
            # expand: ["latest_invoice.payment_intent"],
        }
            
        # }) do
        case Stripe.Subscription.create(subscription_config) do
        {:ok, subscription} ->
            IO.inspect(subscription)
        {:error, subscription_error} ->
            IO.inspect(subscription_error)
        end

        # # Check if further action is needed for payment
        # payment_intent = subscription.latest_invoice.payment_intent
        # if payment_intent.status == 'requires_action' do
        #     # Redirect customer to Stripe's hosted authentication flow...
        #     IO.inspect(subscription)
        #     conn
        #     |> put_flash(:error, "Something went wrong creating your subscription, if this continues to happen please contact support. #{payment_intent.message}")
        #     |> redirect(to: ~p"/registration/edit")
        # end

        session_config = %{
            customer: customer_id,
            return_url: "https://www.parentcontrols.win/devices",
        }

        case Stripe.BillingPortal.Session.create(session_config) do
        {:ok, session} ->
            redirect(conn, external: session.url)

        {:error, stripe_error} ->
            conn
            |> put_flash(:error, "Something went wrong with Billing Portal, #{stripe_error.message}")
            |> redirect(to: ~p"/")
        end
    end

    def edit(conn, %{}) do
        user = Pow.Plug.current_user(conn)
        customer_id = stripeCustomerId(conn, user)
        if customer_id in [nil, ""] do
            conn
            |> put_flash(:error, "You must subscribe first before viewing Stripe Account Management. #{customer_id}")
            |> redirect(to: ~p"/subscriptions")
        end

        billing_page = Stripe.BillingPortal.Session.create(%{
            customer: customer_id,
            return_url: "https://www.parentcontrols.win/devices"
        })

        case billing_page do
            {:ok, session} ->
                redirect(conn, external: session.url)

            {:error, stripe_error} ->
                IO.inspect(stripe_error)
                conn
                |> put_flash(:error, "Something went wrong with edit. #{stripe_error.message}") # stripe_error.user_message
                |> redirect(to: ~p"/")
                # TODO: Handle error (object Stripe.Error)
        end
    end

    # check if a customer id exists, and if so return a new one
    defp stripeCustomerId(conn, user) do
        stripe_customer_id = user.stripe_customer_id

        stripe_customer_id = if stripe_customer_id in [nil, ""] do
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
                    |> redirect(to: ~p"/registration/edit")
                    nil
            end

            # create changeset for user
            changeset = Parentcontrolswin.Users.User.update_stripe_customer_id_changeset(user, %{stripe_customer_id: stripe_customer_id})
            case Parentcontrolswin.Repo.update(changeset) do
                {:ok, user} -> 
                    IO.inspect(user)
                    # Handle success, maybe return the updated user or a success message
                {:error, _changeset} -> 
                    conn
                    |> put_flash(:error, "Error setting stripe_customer_id in schema.")
                    |> redirect(to: ~p"/registration/edit")
            end

            stripe_customer_id
        end

        stripe_customer_id
    end

    # returns true if subscribed
    def is_subscribed?(customer_id) do
        # defined here for scope
        if customer_id in [nil, ""] do
            # no customer, still not subscribed
            false
        else
            case Stripe.Subscription.list(customer: customer_id) do
                {:ok, subscriptions} ->
                    IO.inspect(subscriptions)
                    # .data holds all of the subscriptions and metadata
                    # only [] actually matters, but just in case
                    subscriptions.data not in [nil, "", %{}, []]
                {:error, _subscriptions} ->
                    false
                    # conn
                    # |> put_flash(:error, "Internal server error checking your subscriptions. Please try again or contact support. #{IO.inspect(subscriptions)}")
                    # |> redirect(to: ~p"/contact")
            end
        end
    end

end