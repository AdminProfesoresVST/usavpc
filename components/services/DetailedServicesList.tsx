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
            router.push(`/${locale}/assessment?plan=${plan}`);
        }, 150);
    };

    return (
        <div className="w-full flex flex-col gap-6 pb-12 max-w-xl mx-auto">
            {/* Header / Intro - Clean & Modern Typography */}
            <div className="space-y-1 text-center mb-2">
                <h1 className="text-3xl font-extrabold text-[#003366] tracking-tight">{t('pageTitle')}</h1>
                <p className="text-sm text-gray-500 font-medium tracking-wide uppercase opacity-80">{t('pageSubtitle')}</p>
            </div>

            <div className="flex flex-col gap-5">
                {/* 1. FULL SERVICE (THE HERO CARD) */}
                <div
                    onClick={() => handleSelect('full')}
                    className="relative group bg-white rounded-2xl p-6 shadow-[0_8px_30px_rgb(0,0,0,0.06)] border-2 border-[#003366] overflow-hidden active:scale-[0.98] transition-all duration-300 ease-out hover:shadow-xl"
                >
                    {/* Premium Gradient Overlay/Sheen */}
                    <div className="absolute inset-0 bg-gradient-to-br from-blue-50/50 via-transparent to-transparent opacity-50" />

                    {/* Recommended Badge - Floating Effect */}
                    <div className="absolute top-0 right-0">
                        <div className="bg-[#C5A065] text-white text-[10px] font-bold px-4 py-1.5 rounded-bl-xl shadow-sm flex items-center gap-1">
                            <Star size={10} fill="currentColor" /> {t('OptionB.recommended') || 'MOST POPULAR'}
                        </div>
                    </div>

                    <div className="relative z-10">
                        {/* Header Section */}
                        <div className="flex justify-between items-start mb-6">
                            <div className="flex items-start gap-4">
                                <div className="h-14 w-14 bg-[#003366] rounded-2xl flex items-center justify-center text-white shadow-lg shadow-blue-900/20 ring-4 ring-blue-50">
                                    <ShieldCheck size={28} strokeWidth={1.5} />
                                </div>
                                <div>
                                    <h3 className="font-bold text-xl text-[#003366] leading-none mb-1.5">{t('OptionB.title')}</h3>
                                    <div className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-[#003366]/5 text-[#003366] text-[10px] font-bold tracking-wider">
                                        <Sparkles size={10} /> ALL INCLUSIVE
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Price Tag - Statement Piece */}
                        <div className="mb-6">
                            <div className="flex items-baseline gap-1">
                                <span className="text-4xl font-black text-[#003366] tracking-tight">{t('OptionB.price')}</span>
                                <span className="text-sm font-medium text-gray-400">/ application</span>
                            </div>
                            <p className="text-sm text-gray-600 mt-2 font-medium leading-relaxed border-l-2 border-[#C5A065]/50 pl-3">
                                {t('OptionB.desc')}
                            </p>
                        </div>

                        {/* Features List - Clean & Spaced */}
                        <div className="space-y-3 mb-6 bg-gray-50/80 rounded-xl p-4 border border-gray-100">
                            {[1, 2, 3].map(i => (
                                <div key={i} className="flex items-center gap-3">
                                    <div className="w-5 h-5 rounded-full bg-[#003366]/10 flex items-center justify-center shrink-0">
                                        <CheckCircle2 className="w-3.5 h-3.5 text-[#003366]" strokeWidth={3} />
                                    </div>
                                    <span className="text-sm font-semibold text-gray-700">{t(`OptionB.feature${i}`)}</span>
                                </div>
                            ))}
                        </div>

                        <Button className="w-full bg-[#003366] hover:bg-[#002244] text-white font-bold h-12 text-sm shadow-lg shadow-blue-900/20 rounded-xl transition-all hover:translate-y-[-1px]">
                            {t('OptionB.cta')} <ChevronRight className="w-4 h-4 ml-1 opacity-70" />
                        </Button>
                    </div>
                </div>

                {/* 2. SIMULATOR (SECONDARY) */}
                <div
                    onClick={() => handleSelect('simulator')}
                    className="relative group bg-white rounded-2xl p-5 shadow-sm border border-gray-200 overflow-hidden active:scale-[0.98] transition-all duration-300 hover:border-[#003366]/30 hover:shadow-md"
                >
                    <div className="flex justify-between items-start mb-4">
                        <div className="flex items-center gap-4">
                            <div className="h-12 w-12 bg-gray-50 rounded-xl flex items-center justify-center text-[#003366]">
                                <BrainCircuit size={24} strokeWidth={1.5} />
                            </div>
                            <div>
                                <h3 className="font-bold text-lg text-gray-900 leading-tight">{t('OptionC.title')}</h3>
                                <div className="text-gray-400 text-xs font-medium">Practice Interview</div>
                            </div>
                        </div>
                        <div className="text-right">
                            <span className="block text-2xl font-black text-[#003366]">{t('OptionC.price')}</span>
                        </div>
                    </div>

                    <p className="text-sm text-gray-500 mb-4 leading-relaxed">{t('OptionC.desc')}</p>

                    <div className="space-y-2 mb-5 pl-1">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="flex items-start gap-2.5">
                                <CheckCircle2 className="w-4 h-4 text-[#C5A065] shrink-0 mt-0.5" />
                                <span className="text-xs font-medium text-gray-600 group-hover:text-gray-800 transition-colors">{t(`OptionC.feature${i}`)}</span>
                            </div>
                        ))}
                    </div>

                    <Button variant="outline" className="w-full border-gray-200 text-[#003366] hover:bg-[#003366]/5 hover:border-[#003366]/20 font-bold h-11 rounded-xl">
                        {t('OptionC.cta')}
                    </Button>
                </div>

                {/* 3. DIY / AUDIT (TERTIARY) */}
                <div
                    onClick={() => handleSelect('diy')}
                    className="relative group bg-white rounded-2xl p-5 shadow-sm border border-gray-200 overflow-hidden active:scale-[0.98] transition-all duration-300 hover:border-[#003366]/30 hover:shadow-md opacity-90 hover:opacity-100"
                >
                    <div className="flex justify-between items-start mb-4">
                        <div className="flex items-center gap-4">
                            <div className="h-12 w-12 bg-gray-50 rounded-xl flex items-center justify-center text-gray-600 group-hover:text-[#003366] transition-colors">
                                <CheckCircle2 size={24} strokeWidth={1.5} />
                            </div>
                            <div>
                                <h3 className="font-bold text-lg text-gray-900 leading-tight">{t('OptionA.title')}</h3>
                                <div className="text-gray-400 text-xs font-medium">Self-Service Tool</div>
                            </div>
                        </div>
                        <div className="text-right">
                            <span className="block text-2xl font-black text-gray-800 group-hover:text-[#003366] transition-colors">{t('OptionA.price')}</span>
                        </div>
                    </div>

                    <p className="text-sm text-gray-500 mb-4 leading-relaxed">{t('OptionA.desc')}</p>

                    <div className="space-y-2 mb-5 pl-1">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="flex items-start gap-2.5">
                                <CheckCircle2 className="w-4 h-4 text-gray-300 group-hover:text-[#C5A065] shrink-0 mt-0.5 transition-colors" />
                                <span className="text-xs font-medium text-gray-600 group-hover:text-gray-800 transition-colors">{t(`OptionA.feature${i}`)}</span>
                            </div>
                        ))}
                    </div>

                    <Button variant="outline" className="w-full border-gray-200 text-gray-600 hover:text-[#003366] hover:bg-gray-50 font-bold h-11 rounded-xl">
                        {t('OptionA.cta')}
                    </Button>
                </div>
            </div>

            <div className="mt-8 text-center">
                <p className="text-[10px] text-gray-400 max-w-xs mx-auto text-center leading-normal">
                    {tCommon('pricing.subtitle') || 'Secure payment via Stripe. AES-256 Encryption enabled.'}
                </p>
            </div>
        </div>
    );
}
