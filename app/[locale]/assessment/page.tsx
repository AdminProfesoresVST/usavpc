import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { AssessmentFlow } from "@/components/assessment/AssessmentFlow";

export default async function AssessmentPage({
    searchParams,
}: {
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

    if (!user) {
        redirect("/login");
    }

    // Check if user has a paid application
    const { data: application } = await supabase
        .from("applications")
        .select("payment_status")
        .eq("ais_account_email", user.email)
        .single();

    const hasPaid = application?.payment_status === 'paid';
    const params = await searchParams;
    const plan = params.plan;

    if (!hasPaid) {
        if (plan === 'diy' || plan === 'full') {
            // Redirect to Checkout
            // We need to construct the absolute URL for the API redirect, or just use a client component to trigger it?
            // Since this is a server component, we can't fetch internal API easily with relative path if we are not careful.
            // But we can redirect to a client-side "PrePayment" page or just handle it here.
            // Better: Render a "Payment Required" Client Component that auto-triggers Stripe or shows a "Pay Now" button.
            return <PaymentRequired plan={plan as string} />;
        } else {
            // No plan selected, force selection
            redirect("/services");
        }
    }

    return <AssessmentFlow />;
}

import { PaymentRequired } from "@/components/payment/PaymentRequired";
