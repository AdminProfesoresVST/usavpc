import createMiddleware from 'next-intl/middleware';
import { routing } from './src/i18n/routing';
import { NextRequest, NextResponse } from 'next/server';
import { createServerClient } from "@supabase/ssr";

const intlMiddleware = createMiddleware(routing);

export default async function middleware(request: NextRequest) {
    const response = intlMiddleware(request);

    // 1. Setup Supabase Client
    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) {
                    return request.cookies.get(name)?.value;
                },
                set(name: string, value: string, options: any) {
                    request.cookies.set({ name, value, ...options });
                    response.cookies.set({ name, value, ...options });
                },
                remove(name: string, options: any) {
                    request.cookies.set({ name, value: '', ...options });
                    response.cookies.set({ name, value: '', ...options });
                },
            },
        }
    );

    // 2. Refresh Session
    const { data: { user } } = await supabase.auth.getUser();

    // 3. Client Intelligence (Preserve existing logic)
    const ip = request.headers.get('x-forwarded-for') || '127.0.0.1';
    const userAgent = request.headers.get('user-agent') || 'Unknown';
    const country = request.headers.get('x-vercel-ip-country') || 'Unknown';
    const city = request.headers.get('x-vercel-ip-city') || 'Unknown';
    response.cookies.set('x-client-geo', JSON.stringify({ ip, country, city }), { httpOnly: true, sameSite: 'lax' });

    const url = new URL(request.url);
    const utmSource = url.searchParams.get('utm_source');
    const utmMedium = url.searchParams.get('utm_medium');
    const utmCampaign = url.searchParams.get('utm_campaign');
    const referrer = request.headers.get('referer');
    if (utmSource || utmMedium || utmCampaign || (referrer && !referrer.includes(request.nextUrl.hostname))) {
        const trafficData = { utm_source: utmSource, utm_medium: utmMedium, utm_campaign: utmCampaign, referrer: referrer };
        response.cookies.set('x-traffic-source', JSON.stringify(trafficData), { httpOnly: true, sameSite: 'lax' });
    }

    // 4. Role-Based Routing
    // Check for Dev Mode Cookie first
    const isDev = process.env.NEXT_PUBLIC_DEV_MODE === 'true';
    const devUserRole = request.cookies.get('x-dev-user')?.value;

    let currentUser = user;
    let currentRole = null;

    if (isDev && devUserRole) {
        // Mock User for Middleware
        currentUser = { id: 'dev-id', role: 'authenticated' } as any;
        // Map 'client_fresh' to 'client' for role checks, OR keep it distinct if we want special routing
        // For general role checks, 'client_fresh' behaves like 'client'
        currentRole = devUserRole === 'client_fresh' ? 'client' : devUserRole;
    } else if (user) {
        // Fetch User Role from Real DB
        const { data: profile } = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();
        currentRole = profile?.role || 'client';
    }

    if (currentUser && currentRole) {
        const pathname = request.nextUrl.pathname;

        // Extract locale to preserve it
        const locale = pathname.split('/')[1] || 'es'; // default implication

        // Protect Admin Routes
        if (pathname.includes('/admin') && currentRole !== 'admin') {
            return NextResponse.redirect(new URL(`/${locale}/dashboard`, request.url));
        }

        // Protect Agent Routes
        if (pathname.includes('/agent') && currentRole !== 'agent' && currentRole !== 'admin') {
            return NextResponse.redirect(new URL(`/${locale}/dashboard`, request.url));
        }

        // Redirect Logged-in Users from Landing Page to their specific Dashboard
        if (pathname.endsWith('/dashboard')) {
            if (currentRole === 'admin') {
                // Admin goes to admin dashboard
                if (!pathname.includes('/admin')) {
                    return NextResponse.redirect(new URL(`/${locale}/admin`, request.url));
                }
            } else if (currentRole === 'agent') {
                // Agent goes to agent dashboard
                if (!pathname.includes('/agent')) {
                    return NextResponse.redirect(new URL(`/${locale}/agent`, request.url));
                }
            } else if (currentRole === 'client_fresh') {
                // client_fresh stays on /dashboard
                // No redirect needed if already on /dashboard
            }
            // Client stays on /dashboard
        }
    }

    return response;
}

export const config = {
    // Match all pathnames except for
    // - … if they start with `/api`, `/_next`, `/_vercel`, or `/auth/callback`
    // - … the ones containing a dot (e.g. `favicon.ico`)
    matcher: ['/((?!api|_next|_vercel|auth/callback|.*\\..*).*)']
};
