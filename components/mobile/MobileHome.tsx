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
        <div className="min-h-screen w-full bg-[#F0F2F5] text-gray-900 flex flex-col font-sans">
            {/* 1. Main Content */}
            <main className="flex-1 p-4 flex flex-col gap-5">

                {/* Header (Logo Area) */}
                <div className="flex justify-between items-center px-1">
                    <div className="flex items-center gap-2">
                        <div className="h-8 w-8 bg-blue-600 rounded-lg flex items-center justify-center text-white font-bold">
                            US
                        </div>
                        <span className="font-bold text-lg tracking-tight text-gray-900">Visa Center</span>
                    </div>
                    <div className="bg-green-100 text-green-700 text-[10px] font-bold px-2 py-1 rounded-full flex items-center gap-1">
                        <span className="h-1.5 w-1.5 bg-green-500 rounded-full animate-pulse" />
                        Online
                    </div>
                </div>

                {/* A. Hero: Modern Gradient Card */}
                <section className="bg-gradient-to-br from-blue-600 to-blue-700 rounded-[2rem] p-6 text-white shadow-xl relative overflow-hidden min-h-[220px] flex flex-col justify-between">
                    {/* Background Pattern */}
                    <div className="absolute inset-0 opacity-10 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] mix-blend-overlay"></div>
                    <div className="absolute -right-10 -top-10 h-40 w-40 bg-blue-400 rounded-full blur-3xl opacity-30"></div>

                    <div className="relative z-10">
                        <div className="inline-flex items-center gap-1.5 bg-white/20 backdrop-blur-md px-3 py-1 rounded-full text-[10px] uppercase tracking-wide font-bold mb-3 border border-white/20">
                            <ShieldCheck className="w-3 h-3 text-white" /> {t('Common.Mobile.officialService') || 'Official Service'}
                        </div>
                        <h2 className="text-3xl font-black leading-tight mb-2 tracking-tight">
                            {t('Common.Mobile.heroTitle')}
                        </h2>
                        <p className="text-blue-100 text-sm font-medium leading-relaxed max-w-[90%]">
                            {t('Common.Mobile.heroSubtitle')}
                        </p>
                    </div>

                    <div className="relative z-10 mt-4">
                        <Button
                            onClick={() => {
                                const servicesSection = document.getElementById('services');
                                if (servicesSection) servicesSection.scrollIntoView({ behavior: 'smooth' });
                            }}
                            className="w-full bg-white text-blue-700 hover:bg-gray-50 font-bold h-12 rounded-2xl text-sm shadow-lg transition-all active:scale-95 flex items-center justify-between px-5"
                        >
                            <span>{t('Common.Mobile.startApplication')}</span>
                            <div className="bg-blue-50 rounded-full p-1.5">
                                <ArrowRight className="w-4 h-4 text-blue-600" />
                            </div>
                        </Button>
                    </div>
                </section>

                {/* Trust Indicators */}
                <div className="flex justify-center gap-6 text-gray-400">
                    <div className="flex items-center gap-1.5 grayscale opacity-70">
                        <div className="flex text-yellow-500"><Star size={12} fill="currentColor" /><Star size={12} fill="currentColor" /><Star size={12} fill="currentColor" /><Star size={12} fill="currentColor" /><Star size={12} fill="currentColor" /></div>
                        <span className="text-[10px] font-semibold">4.9/5 TrustScore</span>
                    </div>
                </div>

                {/* B. Services Grid */}
                <section id="services" className="space-y-4">
                    <div className="flex justify-between items-end px-2">
                        <h3 className="font-bold text-lg text-gray-900">{t('Common.Mobile.selectPacket') || 'Select Plan'}</h3>
                    </div>

                    <div className="grid gap-3">
                        {/* Card 01 - Full Service (Highlighted) */}
                        <div onClick={() => handlePlanSelect('full')} className="bg-white rounded-[1.5rem] p-5 shadow-sm border border-blue-100 relative overflow-hidden active:scale-[0.98] transition-transform">
                            <div className="absolute top-0 right-0 bg-blue-600 text-white text-[10px] font-bold px-3 py-1 rounded-bl-xl">
                                RECOMMENDED
                            </div>
                            <div className="flex justify-between items-start mb-2">
                                <div className="h-10 w-10 bg-blue-50 rounded-full flex items-center justify-center text-blue-600">
                                    <ShieldCheck size={20} />
                                </div>
                                <div className="text-right">
                                    <span className="block text-2xl font-black text-gray-900">$99</span>
                                    <span className="text-[10px] text-gray-400 font-medium">ONE TIME</span>
                                </div>
                            </div>
                            <h4 className="font-bold text-base text-gray-900 mb-1">{t('Common.Mobile.Plans.full.title')}</h4>
                            <p className="text-xs text-gray-500 leading-relaxed">{t('Common.Mobile.Plans.full.desc')}</p>
                            {isProcessing === 'full' && (
                                <div className="absolute inset-0 bg-white/80 backdrop-blur-sm z-20 flex items-center justify-center">
                                    <div className="w-6 h-6 border-2 border-blue-600 border-t-transparent rounded-full animate-spin" />
                                </div>
                            )}
                        </div>

                        {/* Card 02 - Simulator */}
                        <div onClick={() => handlePlanSelect('simulator')} className="bg-white rounded-[1.5rem] p-5 shadow-sm border border-transparent active:scale-[0.98] transition-transform">
                            <div className="flex justify-between items-start mb-2">
                                <div className="h-10 w-10 bg-purple-50 rounded-full flex items-center justify-center text-purple-600">
                                    <BrainCircuit size={20} />
                                </div>
                                <div className="text-right">
                                    <span className="block text-2xl font-black text-gray-900">$29</span>
                                </div>
                            </div>
                            <h4 className="font-bold text-base text-gray-900 mb-1">{t('Common.Mobile.Plans.simulator.title')}</h4>
                            <p className="text-xs text-gray-500 leading-relaxed">{t('Common.Mobile.Plans.simulator.desc')}</p>
                            {isProcessing === 'simulator' && (
                                <div className="absolute inset-0 bg-white/80 backdrop-blur-sm z-20 flex items-center justify-center">
                                    <div className="w-6 h-6 border-2 border-purple-600 border-t-transparent rounded-full animate-spin" />
                                </div>
                            )}
                        </div>

                        {/* Card 03 - DIY */}
                        <div onClick={() => handlePlanSelect('diy')} className="bg-white rounded-[1.5rem] p-5 shadow-sm border border-transparent active:scale-[0.98] transition-transform opacity-80 hover:opacity-100">
                            <div className="flex justify-between items-start mb-2">
                                <div className="h-10 w-10 bg-green-50 rounded-full flex items-center justify-center text-green-600">
                                    <CheckCircle2 size={20} />
                                </div>
                                <div className="text-right">
                                    <span className="block text-2xl font-black text-gray-900">$39</span>
                                </div>
                            </div>
                            <h4 className="font-bold text-base text-gray-900 mb-1">{t('Common.Mobile.Plans.diy.title')}</h4>
                            <p className="text-xs text-gray-500 leading-relaxed">{t('Common.Mobile.Plans.diy.desc')}</p>
                            {isProcessing === 'diy' && (
                                <div className="absolute inset-0 bg-white/80 backdrop-blur-sm z-20 flex items-center justify-center">
                                    <div className="w-6 h-6 border-2 border-green-600 border-t-transparent rounded-full animate-spin" />
                                </div>
                            )}
                        </div>
                    </div>
                </section>
            </main>

            {/* Footer */}
            <footer className="py-6 text-center text-[10px] text-gray-300">
                <p>US Visa Center • Secure Processing</p>
                <div className="flex justify-center gap-2 mt-1 opacity-50">
                    <span className="flex items-center gap-1"><ShieldCheck size={8} /> 256-bit SSL</span>
                </div>
            </footer>
        </div>
    );
}
