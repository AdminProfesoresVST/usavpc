import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";

export async function GET(req: Request) {
    try {
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

        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) {
            return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
        }

        const { searchParams } = new URL(req.url);
        const targetAppId = searchParams.get('applicationId');

        let query = supabase.from("applications").select("ds160_payload");

        if (targetAppId) {
            // Admin Mode: Fetch specific application
            // Note: Strict Admin Role check should be enforced here in production
            query = query.eq("id", targetAppId);
        } else {
            // User Mode: Fetch own application
            query = query.eq("user_id", user.id);
        }

        const { data: application, error: dbError } = await query.single();

        if (dbError || !application) {
            return NextResponse.json({ error: "Application not found" }, { status: 404 });
        }

        return NextResponse.json({
            payload: application.ds160_payload,
            meta: {
                version: "1.0",
                generated_at: new Date().toISOString(),
                target_id: targetAppId || "self"
            }
        });

    } catch (error) {
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
