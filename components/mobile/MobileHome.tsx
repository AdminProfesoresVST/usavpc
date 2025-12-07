"use client";

import { useTranslations } from 'next-intl';
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import {
    ArrowRight,
    FileText,
    ShieldCheck,
    Zap,
    BrainCircuit,
    ChevronRight,
    PlayCircle,
    Briefcase,
    Download
} from "lucide-react";
import { SafeInterviewGuideButton } from "@/components/pdf/SafeInterviewGuideButton";

export function MobileHome() {
    const t = useTranslations();

    return (
        <div className="flex flex-col h-[calc(100vh-60px)] bg-gray-50 overflow-hidden">
            {/* App Header (Sticky) */}
            <div className="bg-white px-4 py-3 border-b border-gray-100 flex-none z-20">
                <h1 className="text-lg font-bold text-trust-navy">
                    {t('Common.Mobile.title')}
                </h1>
                <p className="text-[10px] text-gray-400 uppercase tracking-wider">
                    Official Application Center
                </p>
            </div>

            {/* Scrollable Content Area within 100vh */}
            <div className="flex-1 overflow-y-auto p-4 space-y-4 pb-20">
                {/* Hero Card (Compact) */}
                <div className="bg-trust-navy rounded-2xl p-4 text-white shadow-lg relative overflow-hidden group shrink-0">
                    <div className="absolute top-0 right-0 w-24 h-24 bg-white/10 rounded-full -mr-12 -mt-12 blur-xl"></div>
                    <div className="relative z-10">
                        <h2 className="text-lg font-bold mb-1 leading-tight text-white">
                            Start Application
                        </h2>
                        <p className="text-white/70 text-xs mb-3">
                            AI-Powered DS-160 Assistance
                        </p>
                        <Link href="/services" className="block">
                            <Button className="w-full bg-white text-trust-navy hover:bg-white/90 font-bold h-9 rounded-lg text-xs shadow-sm">
                                Check Eligibility <ArrowRight className="w-3 h-3 ml-2" />
                            </Button>
                        </Link>
                    </div>
                </div>

                {/* Services List (Compact) */}
                <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden shrink-0">
                    <div className="px-4 py-2 border-b border-gray-50 bg-gray-50/50">
                        <h3 className="font-bold text-xs text-gray-500 uppercase tracking-wider">Select Service</h3>
                    </div>
                    <div className="divide-y divide-gray-50">
                        <Link href="/services?plan=full" className="flex items-center justify-between p-3 active:bg-blue-50 transition-colors">
                            <div className="flex items-center gap-3">
                                <div className="w-8 h-8 bg-trust-navy/10 rounded-lg flex items-center justify-center text-trust-navy font-bold text-xs">01</div>
                                <div>
                                    <h4 className="font-bold text-sm text-gray-900">Full Service</h4>
                                    <p className="text-[10px] text-gray-500">We do everything for you</p>
                                </div>
                            </div>
                            <span className="font-bold text-trust-navy text-sm">$99</span>
                        </Link>

                        <Link href="/services?plan=diy" className="flex items-center justify-between p-3 active:bg-blue-50 transition-colors">
                            <div className="flex items-center gap-3">
                                <div className="w-8 h-8 bg-gray-100 rounded-lg flex items-center justify-center text-gray-500 font-bold text-xs">02</div>
                                <div>
                                    <h4 className="font-bold text-sm text-gray-900">DIY Audit</h4>
                                    <p className="text-[10px] text-gray-500">AI Risk Check</p>
                                </div>
                            </div>
                            <span className="font-bold text-trust-navy text-sm">$39</span>
                        </Link>

                        <Link href="/services?plan=simulator" className="flex items-center justify-between p-3 active:bg-blue-50 transition-colors">
                            <div className="flex items-center gap-3">
                                <div className="w-8 h-8 bg-gray-100 rounded-lg flex items-center justify-center text-gray-500 font-bold text-xs">03</div>
                                <div>
                                    <h4 className="font-bold text-sm text-gray-900">Interview Sim</h4>
                                    <p className="text-[10px] text-gray-500">Practice with AI</p>
                                </div>
                            </div>
                            <span className="font-bold text-trust-navy text-sm">$29</span>
                        </Link>
                    </div>
                </div>

                {/* Quick Status */}
                <Link href="/dashboard" className="bg-white p-3 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between active:scale-95 transition-transform">
                    <div className="flex items-center gap-3">
                        <div className="w-8 h-8 bg-blue-50 rounded-full flex items-center justify-center">
                            <FileText className="w-4 h-4 text-trust-navy" />
                        </div>
                        <div>
                            <h3 className="font-bold text-gray-900 text-xs">Check Status</h3>
                            <p className="text-[10px] text-gray-500">Track application</p>
                        </div>
                    </div>
                    <ChevronRight className="w-4 h-4 text-gray-300" />
                </Link>
            </div>
        </div>
    );
}
