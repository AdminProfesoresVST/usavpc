import { headers } from "next/headers";
import { NextResponse } from "next/server";
import { getStripe } from "@/lib/stripe";
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
        const stripe = getStripe();
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
            const applicationId = session.metadata?.application_id; // Check for explicit ID

            let updateError = null;

            if (applicationId) {
                // Explicit update
                const { error } = await supabase
                    .from('applications')
                    .update({
                        status: 'paid',
                        payment_status: 'paid', // Explicit payment status
                        has_strategy_check: serviceType !== 'simulator',
                        service_tier: serviceType,
                        has_insurance_addon: addons.includes('insurance'),
                        form_data: { // Merge or overwrite? Ideally merge but for now overwrite payment info is fine
                            stripe_session_id: session.id,
                            amount_total: session.amount_total,
                            currency: session.currency,
                            metadata: session.metadata,
                            addons: addons
                        }
                    })
                    .eq('id', applicationId);
                updateError = error;
            } else {
                // Fallback: Find by User ID or Email
                // Try to find existing 'draft' or 'unpaid' application
                let { data: existingApp } = await supabase
                    .from('applications')
                    .select('id')
                    .eq('user_id', userId)
                    .single();

                if (existingApp) {
                    const { error } = await supabase
                        .from('applications')
                        .update({
                            status: 'paid',
                            payment_status: 'paid',
                            has_strategy_check: serviceType !== 'simulator',
                            service_tier: serviceType,
                            has_insurance_addon: addons.includes('insurance'),
                            form_data: {
                                stripe_session_id: session.id,
                                amount_total: session.amount_total,
                                currency: session.currency,
                                metadata: session.metadata,
                                addons: addons
                            }
                        })
                        .eq('id', existingApp.id);
                    updateError = error;
                } else {
                    // Insert New (Legacy behavior)
                    const { error } = await supabase
                        .from('applications')
                        .insert({
                            user_id: userId,
                            status: 'paid',
                            payment_status: 'paid',
                            has_strategy_check: serviceType !== 'simulator',
                            service_tier: serviceType,
                            has_insurance_addon: addons.includes('insurance'),
                            ais_account_email: email,
                            form_data: {
                                stripe_session_id: session.id,
                                amount_total: session.amount_total,
                                currency: session.currency,
                                metadata: session.metadata,
                                addons: addons
                            }
                        });
                    updateError = error;
                }
            }

            if (updateError) {
                console.error('Supabase Error:', updateError);
                return new NextResponse('Error updating database', { status: 500 });
            }


        }
    }

    return new NextResponse(null, { status: 200 });
}
