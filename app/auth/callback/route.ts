import { NextResponse } from "next/server";
import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function GET(request: Request) {
    const { searchParams, origin } = new URL(request.url);
    const code = searchParams.get("code");
    const next = searchParams.get("next") ?? "/dashboard";

    let errorMessage = "Verification failed";

    if (code) {
        const cookieStore = await cookies();
        const supabase = createServerClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
            {
                cookies: {
                    get(name: string) {
                        return cookieStore.get(name)?.value;
                    },
                    set(name: string, value: string, options: CookieOptions) {
                        cookieStore.set({ name, value, ...options });
                    },
                    remove(name: string, options: CookieOptions) {
                        cookieStore.set({ name, value: "", ...options });
                    },
                },
            }
        );
        const { data: { session }, error } = await supabase.auth.exchangeCodeForSession(code);
        if (!error && session) {
            // Analytics: Log Login Event
            try {
                const geoCookie = cookieStore.get('x-client-geo')?.value;
                const geo = geoCookie ? JSON.parse(geoCookie) : {};
                const userAgent = request.headers.get('user-agent') || 'Unknown';

                await supabase.from('analytics_events').insert({
                    user_id: session.user.id,
                    event_type: 'login',
                    ip_address: geo.ip,
                    country: geo.country,
                    city: geo.city,
                    user_agent: userAgent,
                    metadata: { method: 'auth_callback' }
                });
            } catch (e) {
                console.error("Analytics Error:", e); // Non-blocking
            }

            return NextResponse.redirect(`${origin}${next}`);
        }
        errorMessage = error?.message || "Authentication failed";
    }

    // return the user to an error page with instructions
    // Middleware will handle the locale redirection for /auth/auth-code-error
    return NextResponse.redirect(`${origin}/auth/auth-code-error?error=${encodeURIComponent(errorMessage)}`);
}
