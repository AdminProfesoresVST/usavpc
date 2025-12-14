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
        <div className="h-[100dvh] w-full flex flex-col bg-[#F0F2F5] text-[#1F2937] overflow-hidden">
            {/* 1. App Header (Fixed) */}
            <header className="shrink-0 bg-white shadow-sm z-30 px-4 py-3 flex justify-between items-center border-b border-gray-100 h-16">
                <div>
                    <h1 className="text-lg font-bold text-[#003366] leading-none">{t('title')}</h1>
                    <p className="text-[10px] text-gray-400 font-mono mt-1">REF: {application?.id?.slice(0, 8).toUpperCase() || '---'}</p>
                </div>
                <div className="h-9 w-9 rounded-full bg-[#003366] flex items-center justify-center text-white font-bold text-sm shadow-md ring-2 ring-gray-100">
                    {user.email?.[0].toUpperCase()}
                </div>
            </header>

            {/* 2. Scrollable Content Area */}
            <main className="flex-1 overflow-y-auto w-full p-4 space-y-5 pb-24 scroll-smooth">

                {/* Welcome Message */}
                <div className="flex items-center gap-3 bg-white p-3 rounded-xl shadow-sm border border-gray-100">
                    <span className="relative flex h-3 w-3 ml-1">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
                    </span>
                    <p className="text-sm text-gray-600">
                        {t('welcome')}, <span className="font-bold text-[#003366]">{user.email?.split('@')[0]}</span>
                    </p>
                </div>

                {/* Main Status Hub */}
                <div className="bg-white p-0 rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
                    <div className="bg-[#003366] px-4 py-2 flex justify-between items-center">
                        <span className="text-[10px] uppercase font-bold text-white/90 tracking-widest">Case Status</span>
                        <Radar className="text-white/20" size={16} />
                    </div>
                    <div className="p-5">
                        {application?.service_tier === 'simulator' ? (
                            <InterviewSimulator />
                        ) : (
                            <StatusTracker currentStep={currentStep} />
                        )}
                    </div>
                </div>

                {/* Payment Gate */}
                {!isPaid && application && (
                    <div className="animate-in fade-in slide-in-from-bottom-2 duration-300">
                        <PaymentGate applicationId={application.id} plan={plan} price={displayPrice} />
                    </div>
                )}

                {/* Action Grid */}
                {isPaid && application?.service_tier !== 'simulator' && (
                    <div className="grid gap-4 md:grid-cols-2">

                        {/* Details Card */}
                        <Card className="p-4 bg-white border-0 shadow-sm rounded-2xl">
                            <div className="flex items-center gap-2 mb-3 text-gray-400">
                                <Brain size={16} />
                                <h2 className="text-xs font-bold uppercase tracking-widest">Details</h2>
                            </div>
                            <div className="space-y-3">
                                <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg border border-gray-100">
                                    <span className="text-xs font-semibold text-gray-500 uppercase">{t('statusLabel')}</span>
                                    <span className="text-xs font-bold px-2 py-1 rounded bg-[#003366] text-white">
                                        {application.status || t('statusInProgress')}
                                    </span>
                                </div>
                                <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg border border-gray-100">
                                    <span className="text-xs font-semibold text-gray-500 uppercase">{t('strategyReviewLabel')}</span>
                                    {application.has_strategy_check ? (
                                        <div className="flex items-center gap-1 text-green-700 text-xs font-bold">
                                            <ShieldCheck size={14} /> Completed
                                        </div>
                                    ) : (
                                        <div className="flex items-center gap-1 text-orange-600 text-xs font-bold">
                                            <div className="h-1.5 w-1.5 bg-orange-500 rounded-full animate-pulse" /> Pending
                                        </div>
                                    )}
                                </div>
                            </div>
                        </Card>

                        {/* Documents & Tools */}
                        <Card className="p-4 bg-white border-0 shadow-sm rounded-2xl flex flex-col">
                            <div className="flex items-center gap-2 mb-3 text-gray-400">
                                <Download size={16} />
                                <h2 className="text-xs font-bold uppercase tracking-widest">Documents</h2>
                            </div>

                            <div className="flex-1 flex flex-col justify-center gap-3">
                                {application.has_strategy_check ? (
                                    <SafeDownloadButton data={application} />
                                ) : (
                                    <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg border border-gray-100 opacity-50">
                                        <Download className="text-gray-400" size={16} />
                                        <p className="text-[10px] text-gray-400 font-semibold uppercase">{t('downloadUnlock')}</p>
                                    </div>
                                )}

                                {application.form_data?.addons?.includes('simulator') && (
                                    <Button
                                        variant="outline"
                                        className="w-full justify-between h-9 text-xs border-gray-200"
                                        onClick={() => window.location.href = '/assessment?plan=simulator'}
                                    >
                                        <span className="flex items-center gap-2">
                                            <Brain size={14} className="text-[#003366]" />
                                            {t('launchSimulator')}
                                        </span>
                                        <ChevronRight size={14} className="text-gray-300" />
                                    </Button>
                                )}
                            </div>
                        </Card>
                    </div>
                )}

                {/* Data Review */}
                {isPaid && application && (
                    <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100">
                        <DS160ReviewLoader supabase={supabase} payload={application.ds160_payload} />
                    </div>
                )}
            </main>
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
