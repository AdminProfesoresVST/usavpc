import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { Card } from "@/components/ui/card";
import { ShieldCheck, Brain, Radar } from "lucide-react";
import { Button } from "@/components/ui/button";
import { StatusTracker } from "@/components/dashboard/StatusTracker";
import { SafeDownloadButton } from "@/components/pdf/SafeDownloadButton";
import { ExtensionDataButton } from "@/components/dashboard/ExtensionDataButton";
import { InterviewSimulator } from "@/components/dashboard/InterviewSimulator";
import { getTranslations } from 'next-intl/server';

export default async function DashboardPage() {
    const t = await getTranslations('Dashboard');
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

    // Determine current step based on status
    // Default to 1 (Received)
    let currentStep: 1 | 2 | 3 | 4 = 1;

    if (application?.status === 'validated') currentStep = 2;
    if (application?.status === 'queue') currentStep = 3;
    if (application?.status === 'ready') currentStep = 4;
    if (application?.has_strategy_check) currentStep = 2; // At least step 2 if strategy check is done

    return (
        <div className="container mx-auto px-4 py-12">
            <h1 className="text-3xl font-serif font-bold text-trust-navy mb-2">
                {t('title')}
            </h1>
            <p className="text-gray-600 mb-8 flex items-center gap-2">
                <span className="bg-green-100 text-green-800 text-xs font-bold px-2 py-1 rounded-full">{t('liveSession')}</span>
                {t('welcome')}, <span className="font-semibold text-trust-navy">{user.email}</span>
            </p>

            <div className="bg-white p-8 rounded-lg shadow-sm border border-gray-200 mb-8">
                {application?.service_tier === 'simulator' ? (
                    <InterviewSimulator />
                ) : (
                    <StatusTracker currentStep={currentStep} />
                )}
            </div>

            {application?.service_tier !== 'simulator' && (
                <div className="grid gap-6 md:grid-cols-2">
                    <Card className="p-6 bg-white border-border shadow-sm">
                        <h2 className="text-xl font-bold mb-4">{t('applicationDetails')}</h2>
                        <div className="space-y-2">
                            <div className="flex justify-between">
                                <span className="text-muted-foreground">{t('statusLabel')}</span>
                                <span className="font-semibold uppercase text-primary">
                                    {application?.status || t('statusInProgress')}
                                </span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-muted-foreground">{t('strategyReviewLabel')}</span>
                                <span className="font-semibold">
                                    {application?.has_strategy_check ? t('statusCompleted') : t('statusPending')}
                                </span>
                            </div>
                        </div>
                    </Card>

                    <Card className="p-6 bg-white border-border shadow-sm">
                        <h2 className="text-xl font-bold mb-4">{t('documentsTools')}</h2>
                        {application?.has_strategy_check ? (
                            <div className="space-y-4">
                                <p className="text-sm text-muted-foreground">
                                    {t('downloadReady')}
                                </p>
                                <SafeDownloadButton data={application} />
                            </div>
                        ) : (
                            <div className="space-y-4">
                                <p className="text-sm text-muted-foreground">
                                    {t('downloadUnlock')}
                                </p>
                                <div className="h-10 bg-gray-100 rounded animate-pulse"></div>
                            </div>
                        )}

                        {/* Add-on Badges */}
                        <div className="flex flex-wrap gap-2 mt-4">
                            {application?.has_insurance_addon && (
                                <div className="bg-green-100 text-green-800 text-xs font-bold px-2 py-1 rounded flex items-center gap-1">
                                    <ShieldCheck size={12} /> {t('refusalGuardActive')}
                                </div>
                            )}
                            {application?.form_data?.addons?.includes('radar') && (
                                <div className="bg-blue-100 text-blue-800 text-xs font-bold px-2 py-1 rounded flex items-center gap-1">
                                    <Radar size={12} /> {t('priorityRadarActive')}
                                </div>
                            )}
                        </div>

                        {/* Simulator Addon Access */}
                        {application?.form_data?.addons?.includes('simulator') && (
                            <div className="mt-4 pt-4 border-t border-gray-100">
                                <p className="text-sm font-bold text-trust-navy mb-2">{t('aiSimulator')}</p>
                                <Button className="w-full" variant="outline" onClick={() => window.location.href = '/assessment?plan=simulator'}>
                                    {t('launchSimulator')}
                                </Button>
                            </div>
                        )}

                        {/* Extension Integration */}
                        {application && (
                            <div className="mt-4">
                                <ExtensionDataButton data={application} />
                            </div>
                        )}
                    </Card>
                </div>
            )}
        </div>
    );
}
