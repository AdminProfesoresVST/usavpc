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
            {/* 1. Header (Fixed Ultra Compact) */}
            <div className="bg-white px-4 py-2 border-b border-gray-100 flex-none z-20 flex items-center justify-between shrink-0 h-12">
                <div>
                    <h1 className="text-sm font-black text-trust-navy leading-none">
                        {t('Common.Mobile.title')}
                    </h1>
                    <p className="text-[9px] text-gray-400 uppercase tracking-widest font-bold">
                        Official US Visa Center
                    </p>
                </div>
                <div className="bg-green-50 text-success-green text-[9px] font-bold px-1.5 py-0.5 rounded border border-green-100">
                    Live
                </div>
            </div>

            {/* 2. Main Content (Flex Column - No Scroll) */}
            <div className="flex-1 flex flex-col p-2 min-h-0 space-y-2">

                {/* Hero Section (Horizontal Squash - Max 20% Height) */}
                <div className="bg-trust-navy rounded-lg p-3 text-white shadow-md relative overflow-hidden shrink-0 flex flex-row items-center gap-3">
                    <div className="absolute top-0 right-0 w-24 h-24 bg-white/5 rounded-full -mr-10 -mt-10 blur-xl"></div>
                    <div className="flex-1 relative z-10">
                        <div className="inline-flex items-center gap-1 bg-white/10 px-1.5 py-0.5 rounded-full text-[8px] uppercase tracking-wide font-bold mb-1 border border-white/20 text-accent-gold">
                            <ShieldCheck className="w-2 h-2" /> Official
                        </div>
                        <h2 className="text-sm font-extrabold leading-tight text-white">
                            Start Application
                        </h2>
                        <p className="text-white/70 text-[10px] leading-tight">
                            AI-Powered Guidance
                        </p>
                    </div>
                    <Link href="/services" className="shrink-0">
                        <Button className="bg-white text-trust-navy hover:bg-white/90 font-bold h-8 px-4 rounded-md text-xs shadow-sm whitespace-nowrap">
                            Start <ArrowRight className="w-3 h-3 ml-1" />
                        </Button>
                    </Link>
                </div>

                {/* Services Section (Takes ALL remaining space, distributes 3 items) */}
                <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden flex-1 flex flex-col min-h-0">
                    {/* Header */}
                    <div className="px-3 py-1.5 border-b border-gray-100 bg-gray-50/50 shrink-0 flex justify-between items-center">
                        <h3 className="font-extrabold text-[9px] text-gray-400 uppercase tracking-widest">Select Packet</h3>
                        <span className="text-[9px] text-accent-gold font-bold">Most Applicants choose #01</span>
                    </div>

                    {/* The 3 Cards - Force Fit */}
                    <div className="flex-1 flex flex-col">
                        {/* Card 1 */}
                        <Link href="/services?plan=full" className="flex-1 flex items-center justify-between px-3 border-b border-gray-50 hover:bg-blue-50/30 active:bg-blue-50 transition-colors group">
                            <div className="flex items-center gap-3">
                                <div className="w-8 h-8 bg-trust-navy/10 group-hover:bg-trust-navy rounded-md flex items-center justify-center text-trust-navy group-hover:text-white font-black text-xs transition-colors">01</div>
                                <div>
                                    <h4 className="font-bold text-xs text-gray-900 leading-none mb-0.5">Full Concierge</h4>
                                    <p className="text-[9px] text-gray-500 font-medium leading-none">We file everything for you</p>
                                </div>
                            </div>
                            <div className="text-right">
                                <span className="font-black text-trust-navy text-sm block">$99</span>
                                <span className="text-[8px] text-green-600 font-bold">Best Value</span>
                            </div>
                        </Link>

                        {/* Card 2 */}
                        <Link href="/services?plan=diy" className="flex-1 flex items-center justify-between px-3 border-b border-gray-50 hover:bg-blue-50/30 active:bg-blue-50 transition-colors group">
                            <div className="flex items-center gap-3">
                                <div className="w-8 h-8 bg-gray-100 group-hover:bg-gray-200 rounded-md flex items-center justify-center text-gray-500 font-bold text-xs transition-colors">02</div>
                                <div>
                                    <h4 className="font-bold text-xs text-gray-900 leading-none mb-0.5">DIY Audit</h4>
                                    <p className="text-[9px] text-gray-500 font-medium leading-none">AI reviews your answers</p>
                                </div>
                            </div>
                            <span className="font-bold text-trust-navy text-sm bg-gray-100 px-1.5 py-0.5 rounded">$39</span>
                        </Link>

                        {/* Card 3 */}
                        <Link href="/services?plan=simulator" className="flex-1 flex items-center justify-between px-3 hover:bg-blue-50/30 active:bg-blue-50 transition-colors group">
                            <div className="flex items-center gap-3">
                                <div className="w-8 h-8 bg-gray-100 group-hover:bg-gray-200 rounded-md flex items-center justify-center text-gray-500 font-bold text-xs transition-colors">03</div>
                                <div>
                                    <h4 className="font-bold text-xs text-gray-900 leading-none mb-0.5">Simulator</h4>
                                    <p className="text-[9px] text-gray-500 font-medium leading-none">Mock Interview Practice</p>
                                </div>
                            </div>
                            <span className="font-bold text-trust-navy text-sm bg-gray-100 px-1.5 py-0.5 rounded">$29</span>
                        </Link>
                    </div>
                </div>

                {/* 3. Footer / Status (Ultra Compact) */}
                <div className="flex items-center justify-between text-[8px] text-gray-400 px-1 shrink-0 h-6">
                    <div className="flex gap-2">
                        <span className="flex items-center gap-1"><ShieldCheck className="w-2.5 h-2.5" /> Secure 256-bit</span>
                    </div>
                    <span className="font-mono text-[9px] font-bold text-accent-gold">v1.5.4</span>
                </div>
            </div>
        </div>
    );
}
```
