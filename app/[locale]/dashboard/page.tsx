import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { Card } from "@/components/ui/card";
import { DownloadReportButton } from "@/components/pdf/DownloadButton";

export default async function DashboardPage() {
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

    if (!user) {
        redirect("/login");
    }

    // Fetch application data
    const { data: application } = await supabase
        .from("applications")
        .select("*")
        .eq("ais_account_email", user.email) // Assuming we link by email for now
        .single();

    return (
        <div className="container mx-auto px-4 py-12">
            <h1 className="text-3xl font-serif font-bold text-primary mb-8">
                My Application Dashboard
            </h1>

            <div className="grid gap-6 md:grid-cols-2">
                <Card className="p-6 bg-white border-border shadow-sm">
                    <h2 className="text-xl font-bold mb-4">Application Status</h2>
                    <div className="space-y-2">
                        <div className="flex justify-between">
                            <span className="text-muted-foreground">Status:</span>
                            <span className="font-semibold uppercase text-primary">
                                {application?.status || "Not Started"}
                            </span>
                        </div>
                        <div className="flex justify-between">
                            <span className="text-muted-foreground">Strategy Review:</span>
                            <span className="font-semibold">
                                {application?.has_strategy_check ? "Completed" : "Pending"}
                            </span>
                        </div>
                    </div>
                </Card>

                <Card className="p-6 bg-white border-border shadow-sm">
                    <h2 className="text-xl font-bold mb-4">Documents</h2>
                    {application?.has_strategy_check ? (
                        <div className="space-y-4">
                            <p className="text-sm text-muted-foreground">
                                Your VisaScore™ Strategy Report is ready for download.
                            </p>
                            <DownloadReportButton />
                        </div>
                    ) : (
                        <p className="text-sm text-muted-foreground">
                            Complete the eligibility review and payment to unlock your strategy report.
                        </p>
                    )}
                </Card>
            </div>
        </div>
    );
}
