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
        <div className="flex flex-col h-[100dvh] bg-official-grey text-trust-navy overflow-hidden">
            {/* 1. Header (Fixed, Compact) */}
            <div className="bg-white px-4 py-2 border-b border-gray-100 flex-none z-20 flex items-center justify-between shrink-0 h-14">
                <div>
                    <h1 className="text-base font-extrabold text-trust-navy leading-none">
                        {t('Common.Mobile.title')}
                    </h1>
                    <p className="text-[9px] text-gray-400 uppercase tracking-widest font-semibold mt-0.5">
                        Official Application Center
                    </p>
                </div>
            </div>

            {/* 2. Main Content (Flex Column - Filles available space) */}
            <div className="flex-1 flex flex-col p-3 min-h-0 space-y-3">

                {/* Hero Section (Flexible height, shrinks if needed) */}
                <div className="bg-trust-navy rounded-xl p-4 text-white shadow-lg relative overflow-hidden shrink-0 flex flex-col justify-center min-h-[25%]">
                    <div className="absolute top-0 right-0 w-32 h-32 bg-white/5 rounded-full -mr-10 -mt-10 blur-2xl"></div>
                    <div className="relative z-10">
                        <div className="inline-flex items-center gap-1.5 bg-white/10 px-2 py-0.5 rounded-full text-[9px] uppercase tracking-wide font-bold mb-2 border border-white/20 text-accent-gold w-fit">
                            <ShieldCheck className="w-2.5 h-2.5" /> Official
                        </div>
                        <h2 className="text-xl font-extrabold mb-1 leading-tight text-white">
                            Start Visa App
                        </h2>
                        <p className="text-white/70 text-xs mb-3 font-light leading-snug max-w-[80%]">
                            AI-Powered Step-by-Step Guidance
                        </p>
                        <Link href="/services" className="block w-full">
                            <Button className="w-full bg-white text-trust-navy hover:bg-white/90 font-bold h-10 rounded-lg text-sm shadow-sm transition-transform active:scale-95">
                                Check Eligibility <ArrowRight className="w-3.5 h-3.5 ml-1.5" />
                            </Button>
                        </Link>
                    </div>
                </div>

                {/* Services Section (Takes remaining space) */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden flex-1 flex flex-col min-h-0">
                    <div className="px-3 py-2 border-b border-gray-100 bg-gray-50/50 shrink-0">
                        <h3 className="font-extrabold text-[10px] text-gray-400 uppercase tracking-widest">Select Plan</h3>
                    </div>
                    {/* Inner flex to distribute items evenly */}
                    <div className="flex-1 flex flex-col justify-evenly p-1 overflow-y-auto">
                        <Link href="/services?plan=full" className="flex items-center justify-between p-3 rounded-lg hover:bg-gray-50 active:bg-blue-50 transition-colors group">
                            <div className="flex items-center gap-3">
                                <div className="w-9 h-9 bg-trust-navy/10 group-hover:bg-trust-navy group-active:bg-trust-navy rounded-lg flex items-center justify-center text-trust-navy group-hover:text-white group-active:text-white font-black text-sm transition-colors">01</div>
                                <div>
                                    <h4 className="font-bold text-sm text-gray-900 leading-tight">Full Service</h4>
                                    <p className="text-[10px] text-gray-500 font-medium">Concierge (Recommended)</p>
                                </div>
                            </div>
                            <span className="font-bold text-trust-navy text-sm bg-gray-100 px-2 py-1 rounded-md">$99</span>
                        </Link>

                        <div className="h-px bg-gray-50 mx-4 shrink-0"></div>

                        <Link href="/services?plan=diy" className="flex items-center justify-between p-3 rounded-lg hover:bg-gray-50 active:bg-blue-50 transition-colors group">
                            <div className="flex items-center gap-3">
                                <div className="w-9 h-9 bg-gray-100 group-hover:bg-gray-200 rounded-lg flex items-center justify-center text-gray-500 font-bold text-xs transition-colors">02</div>
                                <div>
                                    <h4 className="font-bold text-sm text-gray-900 leading-tight">DIY Audit</h4>
                                    <p className="text-[10px] text-gray-500 font-medium">AI Risk Check</p>
                                </div>
                            </div>
                            <span className="font-bold text-trust-navy text-sm bg-gray-100 px-2 py-1 rounded-md">$39</span>
                        </Link>

                        <div className="h-px bg-gray-50 mx-4 shrink-0"></div>

                        <Link href="/services?plan=simulator" className="flex items-center justify-between p-3 rounded-lg hover:bg-gray-50 active:bg-blue-50 transition-colors group">
                            <div className="flex items-center gap-3">
                                <div className="w-9 h-9 bg-gray-100 group-hover:bg-gray-200 rounded-lg flex items-center justify-center text-gray-500 font-bold text-xs transition-colors">03</div>
                                <div>
                                    <h4 className="font-bold text-sm text-gray-900 leading-tight">Simulator</h4>
                                    <p className="text-[10px] text-gray-500 font-medium">Practice Interview</p>
                                </div>
                            </div>
                            <span className="font-bold text-trust-navy text-sm bg-gray-100 px-2 py-1 rounded-md">$29</span>
                        </Link>
                    </div>
                </div>

                {/* 3. Footer / Status (Very Compact) */}
                <div className="flex items-center justify-between text-[9px] text-gray-400 px-1 shrink-0 pb-1">
                    <div className="flex gap-2">
                        <span className="flex items-center gap-1"><ShieldCheck className="w-3 h-3" /> Encryption</span>
                        <span className="flex items-center gap-1"><BrainCircuit className="w-3 h-3" /> AI Engine</span>
                    </div>
                    <span className="font-mono text-xs font-bold text-accent-gold">v1.5.3</span>
                </div>
            </div>
        </div>
    );
}
