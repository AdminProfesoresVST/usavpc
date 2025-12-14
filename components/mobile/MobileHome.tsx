"use client";

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
        <div className="h-[100dvh] w-full bg-[#F0F2F5] text-[#1F2937] flex flex-col font-sans overflow-hidden">

            {/* 1. Fixed Header (App Shell) */}
            <header className="shrink-0 bg-white shadow-sm px-4 py-3 flex justify-between items-center z-10 h-16 border-b border-gray-100">
                <div className="flex items-center gap-2">
                    <div className="h-9 w-9 bg-[#003366] rounded-lg flex items-center justify-center text-white font-bold shadow-md">
                        US
                    </div>
                    <div>
                        <span className="block font-bold text-sm tracking-tight text-[#003366]">Visa Center</span>
                        <span className="block text-[9px] text-gray-400 font-medium tracking-wider uppercase">Official Processing</span>
                    </div>
                </div>
                <div className="bg-green-50 text-green-800 text-[10px] font-bold px-2 py-1 rounded border border-green-100 flex items-center gap-1.5">
                    <span className="h-1.5 w-1.5 bg-green-600 rounded-full animate-pulse" />
                    SYSTEM ONLINE
                </div>
            </header>

            {/* 2. Scrollable Main Content */}
            <main className="flex-1 overflow-y-auto p-4 space-y-5 pb-8 scroll-smooth">

                {/* A. Hero: Corporate Navy Style */}
                <section className="bg-[#003366] rounded-2xl p-6 text-white shadow-lg relative overflow-hidden flex flex-col justify-between min-h-[220px]">
                    {/* Background Pattern */}
                    <div className="absolute inset-0 opacity-5 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] mix-blend-overlay"></div>

                    <div className="relative z-10">
                        <div className="inline-flex items-center gap-1.5 bg-white/10 px-3 py-1 rounded text-[10px] uppercase tracking-wider font-bold mb-4 border border-white/10">
                            <ShieldCheck className="w-3 h-3 text-white" /> {t('Common.Mobile.officialService') || 'Secure Application'}
                        </div>
                        <h2 className="text-2xl font-bold leading-tight mb-2 tracking-tight">
                            {t('Common.Mobile.heroTitle')}
                        </h2>
                        <p className="text-gray-300 text-sm font-medium leading-relaxed max-w-[95%]">
                            {t('Common.Mobile.heroSubtitle')}
                        </p>
                    </div>

                    <div className="relative z-10 mt-6">
                        <Button
                            onClick={() => {
                                const servicesSection = document.getElementById('services');
                                if (servicesSection) servicesSection.scrollIntoView({ behavior: 'smooth' });
                            }}
                            className="w-full bg-white text-[#003366] hover:bg-gray-100 font-bold h-12 rounded-xl text-sm shadow-md transition-all active:scale-95 flex items-center justify-between px-5"
                        >
                            <span>{t('Common.Mobile.startApplication')}</span>
                            <div className="bg-[#003366]/10 rounded-full p-1.5">
                                <ArrowRight className="w-4 h-4 text-[#003366]" />
                            </div>
                        </Button>
                    </div>
                </section>

                {/* Trust Indicators */}
                <div className="flex justify-center gap-6 text-gray-400 py-1">
                    <div className="flex items-center gap-2 opacity-80">
                        <div className="flex text-[#C5A065]"><Star size={12} fill="currentColor" /><Star size={12} fill="currentColor" /><Star size={12} fill="currentColor" /><Star size={12} fill="currentColor" /><Star size={12} fill="currentColor" /></div>
                        <span className="text-[10px] font-semibold tracking-wide uppercase">Trusted by 50k+ Applicants</span>
                    </div>
                </div>

                {/* B. Services Grid */}
                <section id="services" className="space-y-4">
                    <div className="flex justify-between items-end px-1 border-b border-gray-200 pb-2">
                        <h3 className="font-bold text-sm text-[#003366] uppercase tracking-widest">{t('Common.Mobile.selectPacket') || 'Available Services'}</h3>
                    </div>

                    <div className="grid gap-3">
                        {/* Card 01 - Full Service (Highlighted) */}
                        <div onClick={() => handlePlanSelect('full')} className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100 relative overflow-hidden active:scale-[0.98] transition-transform">
                            <div className="absolute top-0 right-0 bg-[#003366] text-white text-[9px] font-bold px-3 py-1 rounded-bl-lg tracking-wider">
                                MOST POPULAR
                            </div>
                            <div className="flex justify-between items-start mb-3">
                                <div className="h-10 w-10 bg-blue-50 rounded-lg flex items-center justify-center text-[#003366]">
                                    <ShieldCheck size={20} />
                                </div>
                                <div className="text-right">
                                    <span className="block text-xl font-bold text-gray-900">$99</span>
                                    <span className="text-[9px] text-gray-400 font-bold uppercase tracking-wide">One Time Fee</span>
                                </div>
                            </div>
                            <h4 className="font-bold text-sm text-gray-900 mb-1">{t('Common.Mobile.Plans.full.title')}</h4>
                            <p className="text-xs text-gray-500 leading-relaxed">{t('Common.Mobile.Plans.full.desc')}</p>
                            {isProcessing === 'full' && (
                                <div className="absolute inset-0 bg-white/90 backdrop-blur-[1px] z-20 flex items-center justify-center">
                                    <div className="w-5 h-5 border-2 border-[#003366] border-t-transparent rounded-full animate-spin" />
                                </div>
                            )}
                        </div>

                        {/* Card 02 - Simulator */}
                        <div onClick={() => handlePlanSelect('simulator')} className="bg-white rounded-2xl p-5 shadow-sm border border-transparent active:scale-[0.98] transition-transform">
                            <div className="flex justify-between items-start mb-3">
                                <div className="h-10 w-10 bg-purple-50 rounded-lg flex items-center justify-center text-purple-700">
                                    <BrainCircuit size={20} />
                                </div>
                                <div className="text-right">
                                    <span className="block text-xl font-bold text-gray-900">$29</span>
                                </div>
                            </div>
                            <h4 className="font-bold text-sm text-gray-900 mb-1">{t('Common.Mobile.Plans.simulator.title')}</h4>
                            <p className="text-xs text-gray-500 leading-relaxed">{t('Common.Mobile.Plans.simulator.desc')}</p>
                            {isProcessing === 'simulator' && (
                                <div className="absolute inset-0 bg-white/90 backdrop-blur-[1px] z-20 flex items-center justify-center">
                                    <div className="w-5 h-5 border-2 border-purple-700 border-t-transparent rounded-full animate-spin" />
                                </div>
                            )}
                        </div>

                        {/* Card 03 - DIY */}
                        <div onClick={() => handlePlanSelect('diy')} className="bg-white rounded-2xl p-5 shadow-sm border border-transparent active:scale-[0.98] transition-transform opacity-75 hover:opacity-100">
                            <div className="flex justify-between items-start mb-3">
                                <div className="h-10 w-10 bg-green-50 rounded-lg flex items-center justify-center text-green-700">
                                    <CheckCircle2 size={20} />
                                </div>
                                <div className="text-right">
                                    <span className="block text-xl font-bold text-gray-900">$39</span>
                                </div>
                            </div>
                            <h4 className="font-bold text-sm text-gray-900 mb-1">{t('Common.Mobile.Plans.diy.title')}</h4>
                            <p className="text-xs text-gray-500 leading-relaxed">{t('Common.Mobile.Plans.diy.desc')}</p>
                            {isProcessing === 'diy' && (
                                <div className="absolute inset-0 bg-white/90 backdrop-blur-[1px] z-20 flex items-center justify-center">
                                    <div className="w-5 h-5 border-2 border-green-700 border-t-transparent rounded-full animate-spin" />
                                </div>
                            )}
                        </div>
                    </div>
                </section>

                {/* Footer Padding */}
                <div className="h-4"></div>
            </main>
        </div>
    );
}
