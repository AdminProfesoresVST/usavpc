"use client";

/**
 * [CRITICAL COMPONENT] MobileHome
 * Date: 2025-12-15
 * Context: Home page implementation with strict viewport fitting.
 * Enforcement: flex layout, overflow-hidden, 100dvh.
 * Netlify Impact: Main landing page for mobile users.
 * Source of Truth: API /api/applications/draft
 */

import { useTranslations } from 'next-intl';
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import Image from "next/image";
import {
    ArrowRight,
    ShieldCheck,
    BrainCircuit,
    ChevronRight,
    Star,
    CheckCircle2
} from "lucide-react";
import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';
import { useState } from "react";

export function MobileHome() {
    const t = useTranslations();
    const router = useRouter();
    const locale = useLocale();
    const [isProcessing, setIsProcessing] = useState<string | null>(null);

    const handlePlanSelect = async (plan: string) => {
        setIsProcessing(plan);
        try {
            const timeoutId = setTimeout(() => setIsProcessing(null), 10000);
            const response = await fetch('/api/applications/draft', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ plan, locale }),
            });
            clearTimeout(timeoutId);

            if (response.status === 401) {
                window.location.href = `/${locale}/login?next=/${locale}/assessment?plan=${plan}`;
                return;
            }

            const data = await response.json();
            if (data.success) {
                window.location.href = `/${locale}/assessment`;
            } else {
                alert("Error: " + (data.error || "Unknown error"));
                setIsProcessing(null);
            }
        } catch (e) {
            alert("Connection error. Please try again.");
            setIsProcessing(null);
        }
    };

    return (
        <div className="h-full w-full bg-[#F0F2F5] text-[#1F2937] flex flex-col font-sans overflow-hidden">

            {/* 2. Main Content - Flex Layout to fit, NO SCROLL */}
            <main className="flex-1 flex flex-col p-3 gap-3 overflow-hidden">

                {/* A. Hero: Fixed Height 150px */}
                <section className="bg-[#003366] rounded-xl p-4 text-white shadow-lg relative overflow-hidden flex flex-col justify-between shrink-0 h-[150px]">
                    {/* Background Pattern */}
                    <div className="absolute inset-0 opacity-5 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] mix-blend-overlay"></div>

                    <div className="relative z-10 space-y-2">
                        <div className="inline-flex items-center gap-1.5 bg-white/10 px-2 py-0.5 rounded text-[9px] uppercase tracking-wider font-bold border border-white/10">
                            <ShieldCheck className="w-3 h-3 text-white" /> {t('Common.Mobile.officialService') || 'Secure App'}
                        </div>
                        <h2 className="text-xl font-bold leading-tight tracking-tight">
                            {t('Common.Mobile.heroTitle')}
                        </h2>
                        {/* Hide subtitle on very small screens if needed, or truncate */}
                        <p className="text-gray-300 text-xs font-medium leading-snug line-clamp-2">
                            {t('Common.Mobile.heroSubtitle')}
                        </p>
                    </div>

                    <div className="relative z-10 mt-2">
                        <Button
                            onClick={() => {
                                const servicesSection = document.getElementById('services');
                                if (servicesSection) servicesSection.scrollIntoView({ behavior: 'smooth' });
                            }}
                            className="w-full bg-white text-[#003366] hover:bg-gray-100 font-bold h-10 rounded-lg text-xs shadow-md transition-all active:scale-95 flex items-center justify-between px-4"
                        >
                            <span>{t('Common.Mobile.startApplication')}</span>
                            <div className="bg-[#003366]/10 rounded-full p-1">
                                <ArrowRight className="w-3 h-3 text-[#003366]" />
                            </div>
                        </Button>
                    </div>
                </section>

                {/* Trust Indicators - Compact */}
                <div className="shrink-0 flex justify-center gap-4 text-gray-400 py-0">
                    <div className="flex items-center gap-1.5 opacity-80">
                        <div className="flex text-[#C5A065]"><Star size={10} fill="currentColor" /><Star size={10} fill="currentColor" /><Star size={10} fill="currentColor" /><Star size={10} fill="currentColor" /><Star size={10} fill="currentColor" /></div>
                        <span className="text-[9px] font-semibold tracking-wide uppercase">50k+ Trusted</span>
                    </div>
                </div>

                {/* B. Services Grid - Flexible, takes remaining space */}
                <section id="services" className="flex-1 flex flex-col min-h-0">
                    <div className="flex justify-between items-end px-1 border-b border-gray-200 pb-1 mb-2 shrink-0">
                        <h3 className="font-bold text-xs text-[#003366] uppercase tracking-widest">{t('Common.Mobile.selectPacket') || 'Services'}</h3>
                    </div>

                    <div className="flex-1 flex flex-col gap-2 min-h-0">
                        {/* Card 01 - Full Service (Main Option) - Takes more space */}
                        <div onClick={() => handlePlanSelect('full')} className="group flex-1 bg-white rounded-xl p-4 shadow-sm border border-gray-100 relative overflow-hidden active:scale-[0.99] transition-all flex flex-col justify-between">
                            <div className="absolute top-0 right-0 bg-[#003366] text-white text-[8px] font-bold px-2 py-0.5 rounded-bl-md tracking-wider">
                                POPULAR
                            </div>

                            {/* Top Section: Title & Icon */}
                            <div>
                                <div className="flex justify-between items-start mb-2">
                                    <div className="h-9 w-9 bg-blue-50 rounded-lg flex items-center justify-center text-[#003366]">
                                        <ShieldCheck size={18} />
                                    </div>
                                    <div className="text-right">
                                        <span className="block text-2xl font-bold text-gray-900">$99</span>
                                    </div>
                                </div>
                                <h4 className="font-bold text-base text-gray-900 leading-tight mb-1">{t('Common.Mobile.Plans.full.title')}</h4>
                            </div>

                            {/* Bottom Section: Description */}
                            <p className="text-xs text-gray-500 leading-relaxed pl-1">{t('Common.Mobile.Plans.full.desc')}</p>

                            {isProcessing === 'full' && (
                                <div className="absolute inset-0 bg-white/90 backdrop-blur-[1px] z-20 flex items-center justify-center">
                                    <div className="w-5 h-5 border-2 border-[#003366] border-t-transparent rounded-full animate-spin" />
                                </div>
                            )}
                        </div>

                        {/* Lower Cards Container - Side by Side to save vertical space */}
                        <div className="shrink-0 flex gap-2 h-24">
                            {/* Card 02 - Simulator */}
                            <div onClick={() => handlePlanSelect('simulator')} className="flex-1 bg-white rounded-xl p-3 shadow-sm border border-transparent active:scale-[0.98] transition-all flex flex-col justify-center">
                                <div className="flex justify-between items-center mb-1">
                                    <div className="h-7 w-7 bg-purple-50 rounded-md flex items-center justify-center text-purple-700">
                                        <BrainCircuit size={14} />
                                    </div>
                                    <span className="block text-sm font-bold text-gray-900">$29</span>
                                </div>
                                <h4 className="font-bold text-xs text-gray-900 leading-tight truncate">{t('Common.Mobile.Plans.simulator.title')}</h4>
                                {isProcessing === 'simulator' && (
                                    <div className="absolute inset-0 bg-white/90 backdrop-blur-[1px] z-20 flex items-center justify-center">
                                        <div className="w-4 h-4 border-2 border-purple-700 border-t-transparent rounded-full animate-spin" />
                                    </div>
                                )}
                            </div>

                            {/* Card 03 - DIY */}
                            <div onClick={() => handlePlanSelect('diy')} className="flex-1 bg-white rounded-xl p-3 shadow-sm border border-transparent active:scale-[0.98] transition-all flex flex-col justify-center opacity-80 hover:opacity-100">
                                <div className="flex justify-between items-center mb-1">
                                    <div className="h-7 w-7 bg-green-50 rounded-md flex items-center justify-center text-green-700">
                                        <CheckCircle2 size={14} />
                                    </div>
                                    <span className="block text-sm font-bold text-gray-900">$39</span>
                                </div>
                                <h4 className="font-bold text-xs text-gray-900 leading-tight truncate">{t('Common.Mobile.Plans.diy.title')}</h4>
                                {isProcessing === 'diy' && (
                                    <div className="absolute inset-0 bg-white/90 backdrop-blur-[1px] z-20 flex items-center justify-center">
                                        <div className="w-4 h-4 border-2 border-green-700 border-t-transparent rounded-full animate-spin" />
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                </section>

                {/* Footer Safe Area */}
                <div className="shrink-0 h-safe-bottom" />
            </main>
        </div>
    );
}
