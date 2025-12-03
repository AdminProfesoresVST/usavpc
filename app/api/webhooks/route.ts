import { headers } from "next/headers";
import { NextResponse } from "next/server";
import { stripe } from "@/lib/stripe";
import { createClient } from "@supabase/supabase-js";
import Stripe from "stripe";

const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function POST(req: Request) {
    const body = await req.text();
    const headerPayload = await headers();
    const signature = headerPayload.get("Stripe-Signature") as string;

    let event: Stripe.Event;

    try {
        event = stripe.webhooks.constructEvent(
            body,
            signature,
            process.env.STRIPE_WEBHOOK_SECRET!
        );
    } catch (error: any) {
        return new NextResponse(`Webhook Error: ${error.message}`, { status: 400 });
    }

    const session = event.data.object as Stripe.Checkout.Session;

    if (event.type === "checkout.session.completed") {
        // Retrieve the subscription details from Stripe.
        // const subscription = await stripe.subscriptions.retrieve(
        //   session.subscription as string
        // );

        // Update Supabase
        // 1. Check if user exists by email (session.customer_details?.email)
        // 2. If not, create auth user (optional, or just create application record)
        // 3. Create/Update application record

        const email = session.customer_details?.email;
        const userId = session.client_reference_id;

        if (email) {
            const serviceType = session.metadata?.service_type || 'diy_strategy';
            const addons = session.metadata?.addons ? JSON.parse(session.metadata.addons) : [];

            const { error } = await supabase
                .from('applications')
                .insert({
                    user_id: userId, // Link to authenticated user if present
                    status: 'paid',
                    has_strategy_check: serviceType !== 'simulator',
                    service_tier: serviceType,
                    has_insurance_addon: addons.includes('insurance'),
                    ais_account_email: email,
                    form_data: {
                        stripe_session_id: session.id,
                        amount_total: session.amount_total,
                        currency: session.currency,
                        metadata: session.metadata,
                        addons: addons // Store all addons for reference (radar, simulator)
                    }
                });

            if (error) {
                console.error('Supabase Error:', error);
                return new NextResponse('Error updating database', { status: 500 });
            }
        }
    }

    return new NextResponse(null, { status: 200 });
}
