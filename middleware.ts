import createMiddleware from 'next-intl/middleware';
import { routing } from './src/i18n/routing';
import { NextRequest, NextResponse } from 'next/server';

const intlMiddleware = createMiddleware(routing);

export default function middleware(request: NextRequest) {
    const response = intlMiddleware(request);

    // Capture Client Intelligence Headers
    const ip = request.headers.get('x-forwarded-for') || '127.0.0.1';
    const userAgent = request.headers.get('user-agent') || 'Unknown';
    const country = request.headers.get('x-vercel-ip-country') || 'Unknown';
    const city = request.headers.get('x-vercel-ip-city') || 'Unknown';

    // Pass them to the backend via response headers (for server components)
    // Note: In Next.js middleware, modifying request headers for downstream is done by returning a response with request headers
    // But here we are returning the intl response.
    // We can set headers on the response object, but that goes to the client.
    // To pass to Server Components, we usually use `request.headers` mutation if we were continuing.
    // But since we return `response`, we should set headers on it? No, that's for the browser.
    // Actually, for API routes, they read the request headers directly.
    // Vercel already populates x-forwarded-for, etc.
    // So we don't strictly *need* to do anything here unless we want to normalize them or store them in a cookie for client-side access.

    // Let's store them in a cookie so the Client Side (and Server Actions) can easily access "Session Info"
    response.cookies.set('x-client-geo', JSON.stringify({ ip, country, city }), { httpOnly: true, sameSite: 'lax' });

    // Capture Traffic Source (Referrer & UTMs)
    const url = new URL(request.url);
    const utmSource = url.searchParams.get('utm_source');
    const utmMedium = url.searchParams.get('utm_medium');
    const utmCampaign = url.searchParams.get('utm_campaign');
    const referrer = request.headers.get('referer');

    // Only set if present to avoid overwriting existing session data with empty values
    if (utmSource || utmMedium || utmCampaign || (referrer && !referrer.includes(request.nextUrl.hostname))) {
        const trafficData = {
            utm_source: utmSource,
            utm_medium: utmMedium,
            utm_campaign: utmCampaign,
            referrer: referrer
        };
        response.cookies.set('x-traffic-source', JSON.stringify(trafficData), { httpOnly: true, sameSite: 'lax' });
    }

    return response;
}

export const config = {
    // Match all pathnames except for
    // - … if they start with `/api`, `/_next`, `/_vercel`, or `/auth/callback`
    // - … the ones containing a dot (e.g. `favicon.ico`)
    matcher: ['/((?!api|_next|_vercel|auth/callback|.*\\..*).*)']
};
