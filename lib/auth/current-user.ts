import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

export type DevUserRole = 'client' | 'admin' | 'agent';

export const DEV_USERS: Record<DevUserRole, { id: string; email: string; role: DevUserRole }> = {
    client: {
        id: '00000000-0000-0000-0000-000000000001',
        email: 'dev_applicant@example.com',
        role: 'client'
    },
    admin: {
        id: '00000000-0000-0000-0000-000000000002',
        email: 'dev_admin@example.com',
        role: 'admin'
    },
    agent: {
        id: '00000000-0000-0000-0000-000000000003',
        email: 'dev_agent@example.com',
        role: 'agent'
    }
};

export async function getCurrentUser() {
    const cookieStore = await cookies();
    const isDev = process.env.NEXT_PUBLIC_DEV_MODE === 'true';

    // 1. Dev Mode Bypass
    if (isDev) {
        const devUserRole = cookieStore.get('x-dev-user')?.value as DevUserRole | undefined;
        if (devUserRole && DEV_USERS[devUserRole]) {
            const devUser = DEV_USERS[devUserRole];
            // Return structure matching supabase.auth.getUser()
            return {
                data: {
                    user: {
                        id: devUser.id,
                        email: devUser.email,
                        role: 'authenticated', // Supabase Auth role
                        aud: 'authenticated',
                        app_metadata: { provider: 'email' },
                        user_metadata: { name: `Dev ${devUserRole.charAt(0).toUpperCase() + devUserRole.slice(1)}` },
                        created_at: new Date().toISOString(),
                    }
                },
                error: null
            };
        }
    }

    // 2. Real Supabase Auth
    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) {
                    return cookieStore.get(name)?.value;
                },
                set(name: string, value: string, options: any) {
                    try {
                        cookieStore.set({ name, value, ...options });
                    } catch (error) {
                        // The `set` method was called from a Server Component.
                        // This can be ignored if you have middleware refreshing
                        // user sessions.
                    }
                },
                remove(name: string, options: any) {
                    try {
                        cookieStore.set({ name, value: '', ...options });
                    } catch (error) {
                        // The `delete` method was called from a Server Component.
                        // This can be ignored if you have middleware refreshing
                        // user sessions.
                    }
                },
            },
        }
    );

    return await supabase.auth.getUser();
}
