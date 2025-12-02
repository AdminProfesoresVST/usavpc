import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";

export default async function AdminLayout({
    children,
}: {
    children: React.ReactNode;
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

    const {
        data: { user },
    } = await supabase.auth.getUser();

    if (!user || user.email !== process.env.ADMIN_EMAIL) {
        redirect("/");
    }

    return (
        <div className="flex min-h-screen flex-col">
            <header className="bg-slate-900 text-white p-4">
                <div className="container mx-auto flex justify-between items-center">
                    <h1 className="font-bold text-xl">USVPC Admin</h1>
                    <span className="text-sm opacity-75">{user.email}</span>
                </div>
            </header>
            <main className="flex-1 container mx-auto p-4">{children}</main>
        </div>
    );
}
