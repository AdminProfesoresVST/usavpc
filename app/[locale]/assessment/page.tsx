import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { AssessmentFlow } from "@/components/assessment/AssessmentFlow";

export default async function AssessmentPage({
    params,
    searchParams,
}: {
    params: Promise<{ locale: string }>;
    searchParams: Promise<{ [key: string]: string | string[] | undefined }>
}) {
    const cookieStore = await cookies();
    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) {
                    return cookieStore.get(name)?.value;
                },
            },
        }
    );

    const { data: { user } } = await supabase.auth.getUser();

    const { locale } = await params;

    if (!user) {
        const searchParamsValue = await searchParams;
        const plan = searchParamsValue.plan;
        const nextUrl = plan ? `/assessment?plan=${plan}` : '/assessment';
        redirect(`/${locale}/login?next=${encodeURIComponent(nextUrl)}`);
    }

    // Check if user has a paid application
    const { data: application } = await supabase
        .from("applications")
        .select("payment_status")
        .eq("ais_account_email", user.email)
        .single();

    const { payment_status } = application || {};
    const hasPaid = payment_status === 'paid';

    const searchParamsValue = await searchParams;
    const plan = searchParamsValue.plan;
    // const { locale } = await params; // Already declared at top
    // Actually, AssessmentPage props are ({ params, searchParams }).
    // I need to check the function signature.

    console.log("AssessmentPage Debug:", { user: user.email, hasPaid, plan });

    if (!hasPaid) {
        if (plan === 'diy' || plan === 'full') {
            // Redirect to Checkout
            // We need to construct the absolute URL for the API redirect, or just use a client component to trigger it?
            // Since this is a server component, we can't fetch internal API easily with relative path if we are not careful.
            // But we can redirect to a client-side "PrePayment" page or just handle it here.
            // Better: Render a "Payment Required" Client Component that auto-triggers Stripe or shows a "Pay Now" button.
            return <PaymentRequired plan={plan as string} locale={locale as string} />;
        } else {
            // STRICT RULE: NO FALLBACKS.
            // If plan is missing, we do not redirect to services. We show a critical error.
            return (
                <div className="min-h-screen flex flex-col items-center justify-center bg-red-50 p-8 text-center">
                    <h1 className="text-3xl font-bold text-red-700 mb-4">CRITICAL CONFIGURATION ERROR</h1>
                    <p className="text-red-600 mb-8">
                        The application cannot proceed because the 'plan' parameter is missing.
                        <br />
                        According to strict protocol, we do not fallback.
                    </p>
                    <div className="p-4 bg-white border border-red-200 rounded shadow-sm text-left inline-block">
                        <p className="font-mono text-xs text-red-500">Error Code: MISSING_PLAN_PARAM</p>
                        <p className="font-mono text-xs text-red-500">Path: /assessment</p>
                        <p className="font-mono text-xs text-red-500">User: {user.email}</p>
                    </div>
                </div>
            );
        }
    }

    return <AssessmentFlow />;
}

import { PaymentRequired } from "@/components/payment/PaymentRequired";
