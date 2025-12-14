import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { Card } from "@/components/ui/card";
import { ShieldCheck, Brain, Radar, Download, CreditCard, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { StatusTracker } from "@/components/dashboard/StatusTracker";
import { SafeDownloadButton } from "@/components/pdf/SafeDownloadButton";
import { ExtensionDataButton } from "@/components/dashboard/ExtensionDataButton";
import { InterviewSimulator } from "@/components/dashboard/InterviewSimulator";
import { getTranslations } from 'next-intl/server';
import { PaymentGate } from "@/components/dashboard/PaymentGate";
import { getCurrentUser } from "@/lib/auth/current-user";
import { SupabaseClient } from "@supabase/supabase-js";
import { DS160Review } from "@/components/dashboard/DS160Review";

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

    const { data: { user } } = await getCurrentUser();
    if (!user) redirect("/login");

    // Fetch application data
    const { data: application } = await supabase
        .from("applications")
        .select("*")
        .eq("ais_account_email", user.email)
        .single();

    // Determine current step
    let currentStep: 1 | 2 | 3 | 4 = 1;
    if (application?.status === 'validated') currentStep = 2;
    if (application?.status === 'queue') currentStep = 3;
    if (application?.status === 'ready') currentStep = 4;
    if (application?.has_strategy_check) currentStep = 2;

    const isPaid = application?.payment_status === 'paid';
    const plan = application?.service_tier || 'diy';

    // Price Mapping
    const prices: Record<string, string> = {
        'diy': '$39', 'full': '$99', 'simulator': '$29'
    };
    const displayPrice = prices[plan] || '$39';

    return (
        <div className="min-h-screen bg-[#F0F2F5] pb-20">
            {/* Mobile-App Header */}
            <div className="bg-white shadow-sm border-b border-gray-100 sticky top-0 z-10">
                <div className="container mx-auto px-4 py-4 flex justify-between items-center">
                    <div>
                        <h1 className="text-xl font-bold text-[#111827]">{t('title')}</h1>
                        <p className="text-xs text-gray-400 font-mono mt-0.5 ml-0.5">ID: {application?.id?.slice(0, 8).toUpperCase() || '---'}</p>
                    </div>
                    <div className="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-bold text-xs ring-2 ring-blue-50">
                        {user.email?.[0].toUpperCase()}
                    </div>
                </div>
            </div>

            <div className="container mx-auto px-4 py-6 space-y-6 max-w-4xl">

                {/* Welcome Pill */}
                <div className="flex items-center gap-3 bg-white p-3 rounded-2xl shadow-sm border border-gray-100">
                    <div className="h-2 w-2 rounded-full bg-green-500 animate-pulse ml-2"></div>
                    <p className="text-sm text-gray-600">
                        {t('welcome')}, <span className="font-semibold text-gray-900">{user.email?.split('@')[0]}</span>
                    </p>
                </div>

                {/* Main Status Card (The Wallet "Balance") */}
                <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100 relative overflow-hidden">
                    <div className="absolute top-0 right-0 p-4 opacity-5">
                        <Radar size={120} />
                    </div>

                    {application?.service_tier === 'simulator' ? (
                        <InterviewSimulator />
                    ) : (
                        <StatusTracker currentStep={currentStep} />
                    )}
                </div>

                {/* Payment / Action Gate */}
                {!isPaid && application && (
                    <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                        <PaymentGate applicationId={application.id} plan={plan} price={displayPrice} />
                    </div>
                )}

                {/* Application Hub (Grid) */}
                {isPaid && application?.service_tier !== 'simulator' && (
                    <div className="grid gap-4 md:grid-cols-2">

                        {/* Details Card */}
                        <Card className="p-5 bg-white border-0 shadow-sm rounded-3xl flex flex-col justify-between h-full hover:shadow-md transition-all duration-300 group">
                            <div>
                                <div className="flex items-center gap-2 mb-4 text-gray-500">
                                    <Brain size={18} />
                                    <h2 className="text-sm font-semibold uppercase tracking-wider">{t('applicationDetails')}</h2>
                                </div>
                                <div className="space-y-4">
                                    <div className="flex justify-between items-center p-3 bg-gray-50 rounded-xl">
                                        <span className="text-sm text-gray-500">{t('statusLabel')}</span>
                                        <span className={`text-sm font-bold px-3 py-1 rounded-full ${application.status === 'validated' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'
                                            }`}>
                                            {application.status || t('statusInProgress')}
                                        </span>
                                    </div>
                                    <div className="flex justify-between items-center p-3 bg-gray-50 rounded-xl">
                                        <span className="text-sm text-gray-500">{t('strategyReviewLabel')}</span>
                                        <div className="flex items-center gap-2">
                                            {application.has_strategy_check ? (
                                                <ShieldCheck className="text-green-500" size={16} />
                                            ) : (
                                                <div className="h-2 w-2 bg-orange-400 rounded-full animate-ping" />
                                            )}
                                            <span className="font-semibold text-sm">
                                                {application.has_strategy_check ? t('statusCompleted') : t('statusPending')}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </Card>

                        {/* Tools Card */}
                        <Card className="p-5 bg-white border-0 shadow-sm rounded-3xl flex flex-col h-full hover:shadow-md transition-all duration-300">
                            <div className="flex items-center gap-2 mb-4 text-gray-500">
                                <Download size={18} />
                                <h2 className="text-sm font-semibold uppercase tracking-wider">{t('documentsTools')}</h2>
                            </div>

                            <div className="flex-1 flex flex-col justify-center space-y-4">
                                {application.has_strategy_check ? (
                                    <div className="w-full">
                                        <SafeDownloadButton data={application} />
                                    </div>
                                ) : (
                                    <div className="flex items-center gap-3 p-4 bg-gray-50 rounded-2xl border border-gray-100 opacity-60">
                                        <Download className="text-gray-400" />
                                        <p className="text-xs text-gray-500">{t('downloadUnlock')}</p>
                                    </div>
                                )}

                                {/* Simulator CTA */}
                                {application.form_data?.addons?.includes('simulator') && (
                                    <Button
                                        variant="outline"
                                        className="w-full justify-between group-hover:border-blue-200"
                                        onClick={() => window.location.href = '/assessment?plan=simulator'}
                                    >
                                        <span className="flex items-center gap-2">
                                            <Brain size={16} className="text-purple-500" />
                                            {t('launchSimulator')}
                                        </span>
                                        <ChevronRight size={16} className="text-gray-300" />
                                    </Button>
                                )}
                            </div>
                        </Card>

                    </div>
                )}

                {/* DS-160 Review Data */}
                {isPaid && application && (
                    <div className="mt-6 bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
                        <DS160ReviewLoader supabase={supabase} payload={application.ds160_payload} />
                    </div>
                )}
            </div>
        </div>
    );
}

async function DS160ReviewLoader({ supabase, payload }: { supabase: SupabaseClient, payload: any }) {
    const { data: schema } = await supabase
        .from('ai_interview_flow')
        .select('*')
        .order('order_index', { ascending: true });

    if (!schema) return null;
    return <DS160Review payload={payload} schema={schema} />;
}
