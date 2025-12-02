import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export default async function AdminDashboard() {
    const cookieStore = await cookies();
    // Use service role key to bypass RLS for admin view if needed, 
    // but for now we'll try with the authenticated client and assume RLS allows it or is open.
    // Actually, to be safe and ensure we see EVERYTHING, we should probably use the service role key here
    // since this is a server component protected by our own email check.
    // However, creating a client with service role key requires a different setup usually.
    // Let's stick to the standard client and see if we get data. If not, we'll switch to service role.

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

    const { data: applications, error } = await supabase
        .from("applications")
        .select("*")
        .order("created_at", { ascending: false });

    if (error) {
        return <div className="text-red-500">Error loading applications: {error.message}</div>;
    }

    return (
        <div className="py-8">
            <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold">Applications Overview</h2>
                <Badge variant="outline" className="text-lg px-3 py-1">
                    Total: {applications?.length || 0}
                </Badge>
            </div>

            <Card>
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>ID</TableHead>
                            <TableHead>Email</TableHead>
                            <TableHead>Status</TableHead>
                            <TableHead>Strategy</TableHead>
                            <TableHead>Created At</TableHead>
                            <TableHead className="text-right">Amount</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {applications?.map((app) => (
                            <TableRow key={app.id}>
                                <TableCell className="font-mono text-xs text-muted-foreground">
                                    {app.id.slice(0, 8)}...
                                </TableCell>
                                <TableCell>{app.ais_account_email}</TableCell>
                                <TableCell>
                                    <Badge
                                        variant={app.status === "paid" ? "default" : "secondary"}
                                        className={
                                            app.status === "paid"
                                                ? "bg-success-green hover:bg-success-green/90"
                                                : ""
                                        }
                                    >
                                        {app.status || "pending"}
                                    </Badge>
                                </TableCell>
                                <TableCell>
                                    {app.has_strategy_check ? "✅ Ready" : "❌ Pending"}
                                </TableCell>
                                <TableCell className="text-sm text-muted-foreground">
                                    {new Date(app.created_at).toLocaleDateString()}
                                </TableCell>
                                <TableCell className="text-right">
                                    {app.form_data?.amount_total
                                        ? `$${(app.form_data.amount_total / 100).toFixed(2)}`
                                        : "-"}
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </Card>
        </div>
    );
}
