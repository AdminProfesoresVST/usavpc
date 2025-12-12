
import { NextResponse } from "next/server";
import { getStripe } from "@/lib/stripe";
import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function POST(req: Request) {
    try {
        const { locale, plan, addons = [], applicationId } = await req.json();

        let priceAmount = 3900; // Default DIY
        let productName = 'US Visa Strategy Review (DIY)';

        const line_items = [];

        // Base Product
        if (plan === 'full') {
            priceAmount = 9900;
            productName = 'US Visa Full Service Application';
        } else if (plan === 'simulator') {
            priceAmount = 2900;
            productName = 'AI Interview Simulator (30 Days)';
        }

        line_items.push({
            price_data: {
                currency: 'usd',
                product_data: {
                    name: productName,
                    description: 'Comprehensive analysis and VisaScore™ report.',
                },
                unit_amount: priceAmount,
            },
            quantity: 1,
        });

        // Add-ons (Upsells)
        if (Array.isArray(addons)) {
            if (addons.includes('radar')) {
                line_items.push({
                    price_data: {
                        currency: 'usd',
                        product_data: { name: 'Priority Appointment Radar', description: '24/7 Monitoring for earlier slots.' },
                        unit_amount: 2900,
                    },
                    quantity: 1,
                });
            }
            if (addons.includes('insurance')) {
                line_items.push({
                    price_data: {
                        currency: 'usd',
                        product_data: { name: 'Refusal Guard 365', description: 'Free re-processing if denied.' },
                        unit_amount: 1500,
                    },
                    quantity: 1,
                });
            }
            if (addons.includes('simulator')) {
                // Discounted price for Upsell ($19 instead of $29)
                line_items.push({
                    price_data: {
                        currency: 'usd',
                        product_data: { name: 'AI Interview Simulator (Add-on)', description: 'Unlimited practice sessions.' },
                        unit_amount: 1900,
                    },
                    quantity: 1,
                });
            }
        }

        // Get User for linking (Supports Dev Mode)
        const { getCurrentUser } = await import("@/lib/auth/current-user");
        const { data: { user } } = await getCurrentUser();

        // Create Checkout Sessions from body params.
        const stripe = getStripe();
        const session = await stripe.checkout.sessions.create({
            line_items: line_items,
            mode: 'payment',
            success_url: `${req.headers.get("origin")}/${locale}/success?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: `${req.headers.get("origin")}/${locale}/services?canceled=true`,
            client_reference_id: user?.id, // Link to User
            metadata: {
                locale,
                application_id: applicationId, // Pass App ID for Webhook
                service_type: plan === 'full' ? 'full_service' : plan === 'simulator' ? 'simulator' : 'diy_strategy',
                addons: JSON.stringify(addons) // Store addons in metadata for webhook
            }
        });

        return NextResponse.json({ url: session.url });
    } catch (err) {
        console.error("Stripe Error:", err);
        return NextResponse.json(
            { error: "Internal Server Error" },
            { status: 500 }
        );
    }
}
