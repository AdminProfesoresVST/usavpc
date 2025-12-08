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

    // Check if user has an application (started service)
    const { data: application } = await supabase
        .from("applications")
        .select("id") // We just need to know if it exists
        .eq("ais_account_email", user.email)
        .single();

    if (!application) {
        // If we have a plan in the URL, create the draft application now (Post-Login Flow)
        const searchParamsValue = await searchParams;
        const plan = searchParamsValue.plan;

        if (plan) {
            const { error: createError } = await supabase.from('applications').insert({
                service_tier: plan,
                status: 'draft',
                payment_status: 'unpaid',
                ais_account_email: user.email,
                locale: locale // Ensure locale is saved
            });

            if (createError) {
                console.error("Auto-creation failed:", createError);
                // Fallback to home with error
                redirect(`/${locale}/?error=draft_failed`);
            }
            // If success, just proceed to render AssessmentFlow below
        } else {
            // No application and no plan -> Go to Home Services section
            redirect(`/${locale}/#services`);
        }
    }

    // Payment Logic Removed: Service First, Pay Later.
    // We allow access to AssessmentFlow as long as an application record exists (Draft or otherwise).


    return <AssessmentFlow />;
}

import { PaymentRequired } from "@/components/payment/PaymentRequired";
