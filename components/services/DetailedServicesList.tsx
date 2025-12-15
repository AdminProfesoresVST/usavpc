"use client";

/**
 * [CRITICAL COMPONENT] DetailedServicesList
 * Date: 2025-12-15
 * Context: Detailed selection page for services.
 * Enforcement: Strict Brand Palette (#003366 Navy, #C5A065 Gold).
 * Design: Premium App Aesthetic (Depth, Typography, Whitespace).
 */

import { useTranslations } from 'next-intl';
import { ShieldCheck, BrainCircuit, CheckCircle2, ChevronRight, Star, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';
import { useState } from "react";

export function DetailedServicesList() {
    const t = useTranslations('Services');
    const tCommon = useTranslations('Common');
    const router = useRouter();
    const locale = useLocale();
    const [isProcessing, setIsProcessing] = useState<string | null>(null);

    const handleSelect = async (plan: string) => {
        setIsProcessing(plan);
        // Simulate navigation delay for feeling of "processing"
        setTimeout(() => {
            // Updated Flow: Services -> Scan (OCR) -> Verify
            router.push(`/${locale}/scan?plan=${plan}`);
        }, 150);
    };

    return (
        <div className="w-full flex flex-col gap-8 pb-12 max-w-xl mx-auto px-1">
            {/* Header / Intro - Left Aligned & Professional */}
            <div className="space-y-1 text-left mb-2 pl-1 flex justify-between items-end">
                <div>
                    <h1 className="text-2xl font-bold text-[#003366] tracking-tight">{t('pageTitle')}</h1>
                    <p className="text-sm text-gray-500 font-medium">{t('pageSubtitle')}</p>
                </div>
            </div>

            <div className="flex flex-col gap-6">
                {/* 1. FULL SERVICE (Main Conversion Driver) */}
                <div
                    onClick={() => handleSelect('full')}
                    className="relative group bg-white rounded-xl shadow-[0_4px_20px_rgb(0,0,0,0.08)] border border-[#003366]/20 overflow-hidden active:scale-[0.99] transition-all hover:shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:border-[#003366]"
                >
                    {/* Top Accent Line */}
                    <div className="absolute top-0 inset-x-0 h-1.5 bg-[#003366]" />

                    {/* Badge - Professional Tag using NAVY only (No Gold) */}
                    <div className="absolute top-4 right-4 z-10">
                        <div className="bg-[#003366] text-white text-[10px] font-bold px-3 py-1 rounded-full flex items-center gap-1.5 shadow-sm">
                            <Star size={10} className="text-white fill-white" />
                            <span className="tracking-wide">RECOMMENDED</span>
                        </div>
                    </div>

                    <div className="p-6 pt-8">
                        {/* Header Section - Added padding-right to avoid badge overlap */}
                        <div className="flex items-start gap-4 mb-5 pr-28">
                            {/* Brand Blue Outline/Background */}
                            <div className="h-12 w-12 bg-[#003366]/5 rounded-lg flex items-center justify-center text-[#003366] border border-[#003366]/10 shrink-0">
                                <ShieldCheck size={24} strokeWidth={1.5} />
                            </div>
                            <div>
                                <h3 className="font-bold text-xl text-[#003366] leading-tight mb-1">{t('OptionB.title')}</h3>
                                <div className="text-[#003366] text-[11px] font-bold tracking-widest uppercase flex items-center gap-1 opacity-80">
                                    <Sparkles size={11} /> All Inclusive Service
                                </div>
                            </div>
                        </div>

                        <p className="text-sm text-gray-600 mb-6 leading-relaxed border-l-2 border-gray-100 pl-4 py-1">
                            {t('OptionB.desc')}
                        </p>

                        {/* Price & CTA Row */}
                        <div className="flex items-center justify-between mb-6">
                            <div>
                                <span className="text-3xl font-bold text-[#003366] tracking-tight">{t('OptionB.price')}</span>
                                <span className="text-xs text-gray-400 font-medium ml-1">/ one-time</span>
                            </div>
                        </div>

                        {/* Features List - Structured */}
                        <div className="space-y-3 mb-6 bg-gray-50 rounded-lg p-4 border border-gray-100/50">
                            {[1, 2, 3].map(i => (
                                <div key={i} className="flex items-center gap-3">
                                    <CheckCircle2 className="w-4 h-4 text-[#003366] shrink-0" strokeWidth={2.5} />
                                    <span className="text-sm font-medium text-gray-700">{t(`OptionB.feature${i}`)}</span>
                                </div>
                            ))}
                        </div>

                        <Button className="w-full bg-[#003366] hover:bg-[#002244] text-white font-bold h-11 text-sm rounded-lg shadow-md transition-all flex justify-between px-6 group-hover:pl-5 group-hover:pr-7">
                            <span>{t('OptionB.cta')}</span>
                            <ChevronRight className="w-4 h-4 opacity-70 group-hover:translate-x-1 transition-transform" />
                        </Button>
                    </div>
                </div>

                {/* Secondary Plans Container - Grid on larger screens if needed, Stack on mobile */}
                <div className="flex flex-col gap-4">
                    {/* 2. SIMULATOR */}
                    <div
                        onClick={() => handleSelect('simulator')}
                        className="bg-white rounded-xl p-5 border border-gray-200 active:scale-[0.99] transition-all hover:border-[#003366]/50 hover:bg-[#003366]/5"
                    >
                        <div className="flex justify-between items-start mb-3">
                            <div className="flex items-center gap-3">
                                <div className="h-10 w-10 bg-white border border-gray-100 rounded-lg flex items-center justify-center text-gray-600 shadow-sm shrink-0">
                                    <BrainCircuit size={20} strokeWidth={1.5} />
                                </div>
                                <div>
                                    <h3 className="font-bold text-base text-gray-900 leading-tight">{t('OptionC.title')}</h3>
                                </div>
                            </div>
                            <span className="text-xl font-bold text-[#003366]">{t('OptionC.price')}</span>
                        </div>

                        <div className="space-y-2 mb-4 pl-1">
                            {[1, 2, 3].map(i => (
                                <div key={i} className="flex items-start gap-2">
                                    {/* Removed Gold Check -> Now Navy */}
                                    <CheckCircle2 className="w-3.5 h-3.5 text-[#003366] shrink-0 mt-0.5" />
                                    <span className="text-xs font-medium text-gray-600">{t(`OptionC.feature${i}`)}</span>
                                </div>
                            ))}
                        </div>

                        <Button variant="ghost" className="w-full text-[#003366] font-semibold h-9 hover:bg-[#003366]/10 text-xs justify-start px-0 hover:px-2 transition-all">
                            {t('OptionC.cta')} <ChevronRight className="w-3 h-3 ml-1" />
                        </Button>
                    </div>

                    {/* 3. DIY / AUDIT */}
                    <div
                        onClick={() => handleSelect('diy')}
                        className="bg-white rounded-xl p-5 border border-gray-200 active:scale-[0.99] transition-all hover:border-[#003366]/50 hover:bg-[#003366]/5 opacity-90"
                    >
                        <div className="flex justify-between items-start mb-3">
                            <div className="flex items-center gap-3">
                                <div className="h-10 w-10 bg-white border border-gray-100 rounded-lg flex items-center justify-center text-gray-400 shadow-sm shrink-0">
                                    <CheckCircle2 size={20} strokeWidth={1.5} />
                                </div>
                                <div>
                                    <h3 className="font-bold text-base text-gray-700 leading-tight">{t('OptionA.title')}</h3>
                                </div>
                            </div>
                            <span className="text-xl font-bold text-gray-600">{t('OptionA.price')}</span>
                        </div>

                        <div className="space-y-2 mb-4 pl-1">
                            {[1, 2, 3].map(i => (
                                <div key={i} className="flex items-start gap-2">
                                    <CheckCircle2 className="w-3.5 h-3.5 text-gray-400 shrink-0 mt-0.5" />
                                    <span className="text-xs font-medium text-gray-500">{t(`OptionA.feature${i}`)}</span>
                                </div>
                            ))}
                        </div>

                        <Button variant="ghost" className="w-full text-gray-500 font-semibold h-9 hover:bg-gray-100 hover:text-[#003366] text-xs justify-start px-0 hover:px-2 transition-all">
                            {t('OptionA.cta')} <ChevronRight className="w-3 h-3 ml-1" />
                        </Button>
                    </div>
                </div>
            </div>

            <div className="mt-4 border-t border-gray-100 pt-6">
                <p className="text-[10px] text-gray-400 text-left leading-relaxed">
                    {tCommon('pricing.subtitle') || 'Secure payment via Stripe. AES-256 Encryption enabled. 100% Satisfaction Guarantee on all services.'}
                </p>
            </div>
        </div>
    );
}
