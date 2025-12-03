import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
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
                    set(name: string, value: string, options: CookieOptions) {
                        cookieStore.set({ name, value, ...options });
                    },
                    remove(name: string, options: CookieOptions) {
                        cookieStore.set({ name, value: "", ...options });
                    },
                },
            }
        );

        const { event_type, metadata } = await request.json();

        // Get User if authenticated
        const { data: { user } } = await supabase.auth.getUser();

        // Get Geo/Traffic Info from Cookies
        const geoCookie = cookieStore.get('x-client-geo')?.value;
        const geo = geoCookie ? JSON.parse(geoCookie) : {};

        const trafficCookie = cookieStore.get('x-traffic-source')?.value;
        const traffic = trafficCookie ? JSON.parse(trafficCookie) : {};

        // Merge Metadata
        const finalMetadata = {
            ...metadata,
            ...traffic, // Include UTMs/Referrer in every event for easy filtering
            timestamp: new Date().toISOString()
        };

        const { error } = await supabase.from('analytics_events').insert({
            user_id: user?.id || null, // Allow anonymous tracking
            event_type,
            ip_address: geo.ip,
            country: geo.country,
            city: geo.city,
            user_agent: request.headers.get('user-agent') || 'Unknown',
            metadata: finalMetadata
        });

        if (error) {
            console.error("Analytics Insert Error:", error);
            return NextResponse.json({ error: error.message }, { status: 500 });
        }

        return NextResponse.json({ success: true });

    } catch (error) {
        console.error("Analytics API Error:", error);
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
