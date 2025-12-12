import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { KanbanBoard } from "@/components/admin/KanbanBoard";
import { Badge } from "@/components/ui/badge";
import { KnowledgeBase } from "@/components/admin/KnowledgeBase";
import { StrategyReport } from "@/components/admin/StrategyReport";

export default async function AdminDashboard() {
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

    // 1. Get User
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
        return <div className="text-red-500 p-8">Unauthorized</div>;
    }

    // 2. Check Role
    const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    if (profile?.role !== 'admin') {
        // Should have been caught by middleware, but double safety
        return <div className="text-red-500 p-8">Access Denied: Admins Only</div>;
    }

    // Fetch applications with user email
    const { data: applications, error } = await supabase
        .from("applications")
        .select(`
            *,
            profiles (
                email,
                first_name,
                last_name
            )
        `)
        .order("created_at", { ascending: false });

    if (error) {
        return <div className="text-red-500 p-8">Error loading applications: {error.message}</div>;
    }

    return (
        <div className="h-[calc(100vh-64px)] flex flex-col p-6 bg-gray-50 overflow-y-auto">
            <div className="flex justify-between items-center mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Mission Control</h1>
                    <p className="text-sm text-gray-500">Overview of all active visa applications</p>
                </div>
                <div className="flex gap-2">
                    <Badge variant="outline" className="bg-white">
                        Total: {applications?.length || 0}
                    </Badge>
                    <Badge className="bg-blue-600">Live Mode</Badge>
                </div>
            </div>

            <div className="flex-1 space-y-8 pb-10">
                <KanbanBoard applications={applications || []} />
                <StrategyReport />
                <KnowledgeBase />
            </div>
        </div>
    );
}
