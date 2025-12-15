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
                {/* 1. FULL SERVICE (THE HERO CARD - High Contrast Navy) */}
                <div
                    onClick={() => handleSelect('full')}
                    className="relative group bg-[#003366] rounded-2xl p-6 shadow-2xl shadow-blue-900/40 border border-[#004080] overflow-hidden active:scale-[0.98] transition-all duration-300 ease-out hover:shadow-blue-900/60 hover:-translate-y-1"
                >
                    {/* Background Texture/Gradient */}
                    <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-10 mix-blend-overlay" />
                    <div className="absolute inset-0 bg-gradient-to-br from-white/5 via-transparent to-black/20" />

                    {/* Recommended Badge - Gold Metallic */}
                    <div className="absolute top-0 right-0 z-20">
                        <div className="bg-gradient-to-r from-[#C5A065] to-[#E5C085] text-[#003366] text-[10px] font-black px-4 py-1.5 rounded-bl-xl shadow-lg flex items-center gap-1.5 tracking-wider">
                            <Star size={10} fill="currentColor" /> {t('OptionB.recommended') || 'MOST POPULAR'}
                        </div>
                    </div>

                    <div className="relative z-10 text-white">
                        {/* Header Section */}
                        <div className="flex justify-between items-start mb-6">
                            <div className="flex items-start gap-4">
                                <div className="h-14 w-14 bg-white/10 rounded-2xl flex items-center justify-center text-white backdrop-blur-sm border border-white/10 shadow-inner">
                                    <ShieldCheck size={28} strokeWidth={1.5} />
                                </div>
                                <div>
                                    <h3 className="font-bold text-xl text-white leading-none mb-2">{t('OptionB.title')}</h3>
                                    <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#C5A065]/20 border border-[#C5A065]/30 text-[#E5C085] text-[10px] font-bold tracking-widest uppercase">
                                        <Sparkles size={10} /> All Inclusive
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Price Tag - Gold Emphasis */}
                        <div className="mb-6">
                            <div className="flex items-baseline gap-1">
                                <span className="text-5xl font-black text-white tracking-tight drop-shadow-sm">{t('OptionB.price')}</span>
                                <span className="text-sm font-medium text-blue-200">/ application</span>
                            </div>
                            <p className="text-sm text-blue-100 mt-3 font-medium leading-relaxed border-l-2 border-[#C5A065] pl-3">
                                {t('OptionB.desc')}
                            </p>
                        </div>

                        {/* Features List - Dark Theme */}
                        <div className="space-y-3 mb-8">
                            {[1, 2, 3].map(i => (
                                <div key={i} className="flex items-center gap-3">
                                    <div className="w-6 h-6 rounded-full bg-[#C5A065] flex items-center justify-center shrink-0 shadow-md shadow-amber-900/20">
                                        <CheckCircle2 className="w-3.5 h-3.5 text-[#003366]" strokeWidth={3} />
                                    </div>
                                    <span className="text-sm font-semibold text-white/90">{t(`OptionB.feature${i}`)}</span>
                                </div>
                            ))}
                        </div>

                        {/* CTA Button - Gold/White Contrast */}
                        <Button className="w-full bg-white hover:bg-gray-50 text-[#003366] font-extrabold h-14 text-sm shadow-xl rounded-xl transition-all transform hover:scale-[1.02]">
                            {t('OptionB.cta')} <ChevronRight className="w-4 h-4 ml-1" />
                        </Button>
                    </div>
                </div>

                {/* 2. SIMULATOR (Secondary - Clean but Strong) */}
                <div
                    onClick={() => handleSelect('simulator')}
                    className="relative group bg-white rounded-2xl p-6 shadow-sm border-2 border-gray-100 overflow-hidden active:scale-[0.98] transition-all duration-300 hover:border-[#003366] hover:shadow-lg"
                >
                    <div className="flex justify-between items-start mb-4">
                        <div className="flex items-center gap-4">
                            <div className="h-12 w-12 bg-[#F0F4F8] rounded-xl flex items-center justify-center text-[#003366]">
                                <BrainCircuit size={24} strokeWidth={1.5} />
                            </div>
                            <div>
                                <h3 className="font-bold text-lg text-[#003366] leading-tight">{t('OptionC.title')}</h3>
                                <div className="text-gray-400 text-xs font-bold uppercase tracking-wide">Practice</div>
                            </div>
                        </div>
                        <div className="text-right">
                            <span className="block text-2xl font-black text-[#003366]">{t('OptionC.price')}</span>
                        </div>
                    </div>

                    <p className="text-sm text-gray-500 mb-5 leading-relaxed font-medium">{t('OptionC.desc')}</p>

                    <div className="space-y-2 mb-6 pl-1">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="flex items-start gap-2.5">
                                <CheckCircle2 className="w-4 h-4 text-[#C5A065] shrink-0 mt-0.5" />
                                <span className="text-xs font-semibold text-gray-600 group-hover:text-[#003366] transition-colors">{t(`OptionC.feature${i}`)}</span>
                            </div>
                        ))}
                    </div>

                    <Button variant="outline" className="w-full border-2 border-gray-100 text-[#003366] hover:border-[#003366] hover:bg-[#003366]/5 font-bold h-12 rounded-xl">
                        {t('OptionC.cta')}
                    </Button>
                </div>

                {/* 3. DIY / AUDIT (Tertiary) */}
                <div
                    onClick={() => handleSelect('diy')}
                    className="relative group bg-white rounded-2xl p-6 shadow-sm border-2 border-gray-100 overflow-hidden active:scale-[0.98] transition-all duration-300 hover:border-gray-300 opacity-90 hover:opacity-100"
                >
                    <div className="flex justify-between items-start mb-4">
                        <div className="flex items-center gap-4">
                            <div className="h-12 w-12 bg-gray-50 rounded-xl flex items-center justify-center text-gray-400 group-hover:text-gray-600 transition-colors">
                                <CheckCircle2 size={24} strokeWidth={1.5} />
                            </div>
                            <div>
                                <h3 className="font-bold text-lg text-gray-700 group-hover:text-gray-900 leading-tight transition-colors">{t('OptionA.title')}</h3>
                                <div className="text-gray-400 text-xs font-bold uppercase tracking-wide">Self Service</div>
                            </div>
                        </div>
                        <div className="text-right">
                            <span className="block text-2xl font-black text-gray-400 group-hover:text-gray-600 transition-colors">{t('OptionA.price')}</span>
                        </div>
                    </div>

                    <p className="text-sm text-gray-400 mb-5 leading-relaxed font-medium group-hover:text-gray-500">{t('OptionA.desc')}</p>

                    <div className="space-y-2 mb-6 pl-1">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="flex items-start gap-2.5">
                                <CheckCircle2 className="w-4 h-4 text-gray-300 group-hover:text-gray-400 shrink-0 mt-0.5 transition-colors" />
                                <span className="text-xs font-medium text-gray-400 group-hover:text-gray-600 transition-colors">{t(`OptionA.feature${i}`)}</span>
                            </div>
                        ))}
                    </div>

                    <Button variant="outline" className="w-full border-2 border-gray-100 text-gray-400 hover:text-gray-600 hover:border-gray-300 font-bold h-12 rounded-xl">
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
