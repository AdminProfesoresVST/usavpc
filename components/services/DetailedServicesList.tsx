"use client";

/**
 * [CRITICAL COMPONENT] DetailedServicesList
 * Date: 2025-12-15
 * Context: Detailed selection page for services.
 * Enforcement: Uses global keys from Services.OptionA/B/C.
 * Netlify Impact: Pricing/Service Selection Page.
 */

import { useTranslations } from 'next-intl';
import { ShieldCheck, BrainCircuit, CheckCircle2, ChevronRight, Star } from "lucide-react";
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
        // Navigate or process logic - matching Home behavior but for detailed view
        // For now, redirect to assessment with plan parameter
        router.push(`/${locale}/assessment?plan=${plan}`);
    };

    return (
        <div className="w-full flex flex-col gap-6 pb-8">
            {/* Header / Intro */}
            <div className="space-y-2">
                <h1 className="text-2xl font-bold text-[#003366]">{t('pageTitle')}</h1>
                <p className="text-sm text-gray-500">{t('pageSubtitle')}</p>
            </div>

            {/* OPTION B: FULL SERVICE (Recommended) - First per business logic usually, or maintain order */}
            {/* User asked for "3 cards". Let's stick to the visual hierarchy: Full -> Simulator -> DIY or Full -> DIY -> Simulator */}
            {/* Based on MobileHome, Full is main. */}

            <div className="flex flex-col gap-4">
                {/* 1. Full Service (OptionB) */}
                <div onClick={() => handleSelect('full')} className="bg-white rounded-xl p-5 shadow-sm border-2 border-[#003366] relative overflow-hidden active:scale-[0.99] transition-all">
                    <div className="absolute top-0 right-0 bg-[#003366] text-white text-[10px] font-bold px-3 py-1 rounded-bl-lg tracking-wider">
                        {t('OptionB.recommended') || 'RECOMMENDED'}
                    </div>

                    <div className="flex justify-between items-start mb-3">
                        <div className="flex items-center gap-3">
                            <div className="h-10 w-10 bg-blue-50 rounded-lg flex items-center justify-center text-[#003366]">
                                <ShieldCheck size={20} />
                            </div>
                            <div>
                                <h3 className="font-bold text-lg text-[#003366] leading-tight">{t('OptionB.title')}</h3>
                                <div className="text-[#C5A065] flex text-[10px] items-center gap-1">
                                    <Star size={8} fill="currentColor" /> <span className="font-bold">ALL INCLUSIVE</span>
                                </div>
                            </div>
                        </div>
                        <div className="text-right">
                            <span className="block text-2xl font-bold text-gray-900">{t('OptionB.price')}</span>
                        </div>
                    </div>

                    <p className="text-sm text-gray-600 mb-4 leading-relaxed">{t('OptionB.desc')}</p>

                    <div className="space-y-2 mb-4">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="flex items-start gap-2">
                                <CheckCircle2 className="w-4 h-4 text-[#003366] shrink-0 mt-0.5" />
                                <span className="text-xs font-medium text-gray-700">{t(`OptionB.feature${i}`)}</span>
                            </div>
                        ))}
                    </div>

                    <Button className="w-full bg-[#003366] hover:bg-[#002244] text-white font-bold h-11">
                        {t('OptionB.cta')} <ChevronRight className="w-4 h-4 ml-2" />
                    </Button>
                </div>

                {/* 2. Simulator (OptionC) */}
                <div onClick={() => handleSelect('simulator')} className="bg-white rounded-xl p-5 shadow-sm border border-gray-200 relative overflow-hidden active:scale-[0.99] transition-all">
                    <div className="flex justify-between items-start mb-3">
                        <div className="flex items-center gap-3">
                            <div className="h-10 w-10 bg-gray-50 rounded-lg flex items-center justify-center text-[#003366]">
                                <BrainCircuit size={20} />
                            </div>
                            <div>
                                <h3 className="font-bold text-lg text-gray-900 leading-tight">{t('OptionC.title')}</h3>
                            </div>
                        </div>
                        <div className="text-right">
                            <span className="block text-2xl font-bold text-gray-900">{t('OptionC.price')}</span>
                        </div>
                    </div>

                    <p className="text-sm text-gray-600 mb-4 leading-relaxed">{t('OptionC.desc')}</p>

                    <div className="space-y-2 mb-4">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="flex items-start gap-2">
                                <CheckCircle2 className="w-4 h-4 text-[#C5A065] shrink-0 mt-0.5" />
                                <span className="text-xs font-medium text-gray-700">{t(`OptionC.feature${i}`)}</span>
                            </div>
                        ))}
                    </div>

                    <Button variant="outline" className="w-full border-gray-200 text-[#003366] hover:bg-gray-50 font-bold h-11">
                        {t('OptionC.cta')}
                    </Button>
                </div>

                {/* 3. DIY / Audit (OptionA) */}
                <div onClick={() => handleSelect('diy')} className="bg-white rounded-xl p-5 shadow-sm border border-gray-200 relative overflow-hidden active:scale-[0.99] transition-all opacity-90 hover:opacity-100">
                    <div className="flex justify-between items-start mb-3">
                        <div className="flex items-center gap-3">
                            <div className="h-10 w-10 bg-gray-50 rounded-lg flex items-center justify-center text-[#003366]">
                                <CheckCircle2 size={20} />
                            </div>
                            <div>
                                <h3 className="font-bold text-lg text-gray-900 leading-tight">{t('OptionA.title')}</h3>
                            </div>
                        </div>
                        <div className="text-right">
                            <span className="block text-2xl font-bold text-gray-900">{t('OptionA.price')}</span>
                        </div>
                    </div>

                    <p className="text-sm text-gray-600 mb-4 leading-relaxed">{t('OptionA.desc')}</p>

                    <div className="space-y-2 mb-4">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="flex items-start gap-2">
                                <CheckCircle2 className="w-4 h-4 text-gray-400 shrink-0 mt-0.5" />
                                <span className="text-xs font-medium text-gray-700">{t(`OptionA.feature${i}`)}</span>
                            </div>
                        ))}
                    </div>

                    <Button variant="outline" className="w-full border-gray-200 text-gray-700 hover:bg-gray-50 font-bold h-11">
                        {t('OptionA.cta')}
                    </Button>
                </div>
            </div>
        </div>
    );
}
