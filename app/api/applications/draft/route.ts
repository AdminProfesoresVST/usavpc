
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
    try {
        const body = await req.json();
        const { plan, locale } = body;

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

        // 1. Auth Check
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) {
            return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
        }

        // 2. Check if application already exists
        const { data: existingApp } = await supabase
            .from("applications")
            .select("id")
            .eq("user_id", user.id)
            .single();

        if (existingApp) {
            // If exists, just update the plan if needed (or do nothing and redirect)
            // Ideally we shouldn't overwrite if they are far along, but for now let's assume restart or continue.
            // We'll just return success.
            return NextResponse.json({ success: true, applicationId: existingApp.id });
        }

        // 3. Create Draft Application
        const { data: newApp, error: createError } = await supabase
            .from("applications")
            .insert([{
                user_id: user.id,
                ais_account_email: user.email, // Important for linking
                service_tier: plan,
                status: 'draft',
                payment_status: 'unpaid',
                step: 1, // Start at step 1
                ds160_payload: {
                    ds160_data: {
                        personal: {},
                        travel: {},
                        work_history: { current_job: {}, previous_jobs: [] },
                        security_questions: {}
                    }
                },
                client_metadata: { locale }
            }])
            .select()
            .single();

        if (createError) {
            console.error("Create App Error:", createError);
            return NextResponse.json({ error: createError.message }, { status: 500 });
        }

        return NextResponse.json({ success: true, applicationId: newApp.id });

    } catch (error) {
        console.error("Draft API Error:", error);
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
