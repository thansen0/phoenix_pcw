# lib/my_app_web/controllers/subscription_controller.ex
defmodule ParentcontrolswinWeb.SubscriptionController do
    use ParentcontrolswinWeb, :controller
    alias Stripe

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
        # customer_id = "cus_PQMm8X3Ep8EL6G" # = get_customer_id_from_user(user)
        customer_id = stripeCustomerId(conn, user)
        # Get this from the Stripe dashboard for your product
        price_id = "price_1ObHZ6DrVDu5S9fVokHH2Fbt"
        quantity = 1

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

        # Previous customer? customer_id else customer_email
        # The stripe API only allows one of {customer_email, customer}
        # session_config =
        # if customer_id,
        #     do: Map.put(session_config, :customer, customer_id),
        #     else: Map.put(session_config, :customer_email, user.email)

        # case Stripe.Subscription.create(%{
        #     customer: customer_id,
        #     items: [
        #         %{price: price_id},
        #     ],
            
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
            # success_url: "https://www.parentcontrols.win/subscriptions/new/success",
            # cancel_url: "https://www.parentcontrols.win/subscriptions/new/cancel",
            # mode: "subscription",
            
            # expand: ["latest_invoice.payment_intent"],
        }

        case Stripe.BillingPortal.Session.create(session_config) do
        {:ok, session} ->
            redirect(conn, external: session.url)

        {:error, stripe_error} ->
            conn
            |> put_flash(:error, "Something went wrong with Billing Portal, #{stripe_error.message}")
            |> redirect(to: ~p"/")
        # Handle error (object Stripe.Error)
        end
    end

    def edit(conn, %{}) do
        user = Pow.Plug.current_user(conn)
        customer_id = user.stripe_customer_id
        # IO.inspect(user)
        if customer_id in [nil, ""] do
            conn
            |> put_flash(:error, "You must subscribe first before viewing Stripe Account Management.")
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
                |> put_flash(:error, "Something went wrong with edit")
                |> redirect(to: ~p"/")
                # TODO: Handle error (object Stripe.Error)
        end
    end

    # check if a customer id exists, and if so return a new one
    defp stripeCustomerId(conn, user) do
        stripe_customer_id = user.stripe_customer_id
        if stripe_customer_id in [nil, ""] do
            new_customer = %{
                email: user.email,
            }

            # {:ok, stripe_customer} = Stripe.Customer.create(new_customer)
            case Stripe.Customer.create(new_customer) do
                {:ok, stripe_customer} -> 
                    stripe_customer_id = stripe_customer.id
                    IO.inspect(stripe_customer)
                    # Handle success, maybe return the updated user or a success message
                {:error, stripe_customer_error} -> 
                    conn
                    |> put_flash(:error, "Error getting stripe_customer_id. Error: #{stripe_customer_error.message}")
                    |> redirect(to: ~p"/registration/edit")
            end

            # create changeset for user
            changeset = Parentcontrolswin.Users.User.update_stripe_customer_id_changeset(user, %{stripe_customer_id: stripe_customer_id})
            IO.inspect(changeset)
            case Parentcontrolswin.Repo.update(changeset) do
                {:ok, user} -> 
                    IO.inspect(user)
                    # Handle success, maybe return the updated user or a success message
                {:error, _changeset} -> 
                    conn
                    |> put_flash(:error, "Error getting stripe_customer_id")
                    |> redirect(to: ~p"/registration/edit")
            end
        end

        stripe_customer_id
    end

    # returns true if subscribed
    def is_subscribed?(customer_id) do
        subs = nil
        if customer_id not in [nil, ""] do
            {:ok, subscriptions} = Stripe.Subscription.list(customer: customer_id)
        # case Stripe.Subscription.list(customer: customer_id) do
        #     {:ok, subscriptions} ->
        #         IO.inspect(subscriptions)
        #     {:error, subscriptions} ->
        #         conn
        #         |> put_flash(:error, "Internal server error checking your subscriptions. Please try again or contact support. #{IO.inspect(subscriptions)}")
        #         |> redirect(to: ~p"/contact")
        # end
            subs = subscriptions.data
        end

        # .data holds all of the subscriptions and metadata
        # only [] actually matters, but just in case
        subs not in [nil, "", %{}, []]
    end

end