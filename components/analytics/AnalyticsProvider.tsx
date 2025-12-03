"use client";

import { usePathname, useSearchParams } from "next/navigation";
import { useEffect, useRef } from "react";

export function AnalyticsProvider({ children }: { children: React.ReactNode }) {
    const pathname = usePathname();
    const searchParams = useSearchParams();
    const hasLoggedReferrer = useRef(false);

    // 1. Track Page Views
    useEffect(() => {
        const logPageView = async () => {
            try {
                await fetch('/api/analytics', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        event_type: 'page_view',
                        metadata: {
                            path: pathname,
                            search: searchParams.toString(),
                            title: document.title
                        }
                    })
                });
            } catch (e) {
                console.error("Analytics Error:", e);
            }
        };

        logPageView();
    }, [pathname, searchParams]);

    // 2. Track Initial Referrer (Client Side Backup)
    useEffect(() => {
        if (!hasLoggedReferrer.current && typeof document !== 'undefined') {
            const referrer = document.referrer;
            if (referrer && !referrer.includes(window.location.hostname)) {
                // Only log external referrers
                fetch('/api/analytics', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        event_type: 'external_referrer',
                        metadata: {
                            referrer: referrer,
                            landing_page: pathname
                        }
                    })
                }).catch(console.error);
            }
            hasLoggedReferrer.current = true;
        }
    }, []);

    return <>{children}</>;
}
