import { NextResponse } from "next/server";
import { stripe } from "@/lib/stripe";

export async function POST(req: Request) {
    try {
        const { locale } = await req.json();

        // Create Checkout Sessions from body params.
        const session = await stripe.checkout.sessions.create({
            line_items: [
                {
                    // Provide the exact Price ID (for example, pr_1234) of the product you want to sell
                    // For now, we use price_data to create it on the fly for testing
                    price_data: {
                        currency: 'usd',
                        product_data: {
                            name: 'US Visa Eligibility & Strategy Review',
                            description: 'Comprehensive analysis and VisaScore™ report.',
                        },
                        unit_amount: 3900, // $39.00
                    },
                    quantity: 1,
                },
            ],
            mode: 'payment',
            success_url: `${req.headers.get("origin")}/${locale}/success?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: `${req.headers.get("origin")}/${locale}/?canceled=true`,
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
