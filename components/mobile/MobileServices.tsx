"use client";

import { useTranslations } from 'next-intl';
import { ServiceCheckoutButton } from "@/components/services/ServiceCheckoutButton";
import { CheckCircle2, ShieldCheck, Zap, BrainCircuit, PlayCircle } from "lucide-react";

export function MobileServices() {
    const t = useTranslations('Services');

    return (
        <div className="flex flex-col min-h-screen bg-gray-50 pb-24">
            {/* App Header */}
            <div className="bg-white px-6 pt-12 pb-6 border-b border-gray-100 sticky top-0 z-10">
                <h1 className="text-2xl font-bold text-trust-navy">
                    Select Plan
                </h1>
                <p className="text-sm text-gray-500 mt-1">
                    Choose the right assistance for you
                </p>
            </div>

            <div className="p-6 space-y-6">
                {/* Full Service - Featured */}
                <div className="bg-trust-navy rounded-[2rem] p-6 text-white shadow-xl shadow-trust-navy/20 relative overflow-hidden">
                    <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl"></div>

                    <div className="relative z-10">
                        <div className="flex justify-between items-start mb-4">
                            <div className="bg-accent-gold text-trust-navy text-[10px] font-bold px-3 py-1 rounded-full uppercase tracking-wide">
                                Recommended
                            </div>
                            <ShieldCheck className="w-6 h-6 text-accent-gold" />
                        </div>

                        <h2 className="text-2xl font-bold mb-2">{t('OptionB.title')}</h2>
                        <p className="text-white/80 text-sm mb-6 leading-relaxed">{t('OptionB.subtitle')}</p>

                        <div className="flex items-center justify-between mt-4">
                            <div className="text-3xl font-bold text-white">{t('OptionB.price')}</div>
                            <ServiceCheckoutButton
                                label="Select Plan"
                                price={t('OptionB.price')}
                                basePriceNumeric={99}
                                plan="full"
                                variant="featured"
                                className="bg-white text-trust-navy hover:bg-white/90 px-8 h-12 rounded-full text-base font-bold shadow-lg transform active:scale-95 transition-all w-auto min-w-[140px]"
                            />
                        </div>
                    </div>
                </div>

                {/* DIY Option - Compact App Card */}
                <div className="bg-white rounded-[2rem] p-6 shadow-lg shadow-gray-100/50 border border-gray-100/50">
                    <div className="flex items-start justify-between mb-4">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 bg-green-50 rounded-2xl flex items-center justify-center">
                                <BrainCircuit className="w-6 h-6 text-success-green" />
                            </div>
                            <div>
                                <h2 className="text-lg font-bold text-gray-900">{t('OptionA.title')}</h2>
                                <div className="text-2xl font-bold text-gray-900 mt-1">{t('OptionA.price')}</div>
                            </div>
                        </div>
                    </div>

                    <p className="text-gray-500 text-sm mb-6 leading-relaxed">{t('OptionA.subtitle')}</p>

                    <ServiceCheckoutButton
                        label="Select Plan"
                        price={t('OptionA.price')}
                        basePriceNumeric={39}
                        plan="diy"
                        variant="outline"
                        className="w-full border-2 border-trust-navy text-trust-navy bg-white hover:bg-gray-50 h-12 rounded-full text-base font-bold transition-colors"
                    />
                </div>

                {/* Simulator Option - Compact App Card */}
                <div className="bg-white rounded-[2rem] p-6 shadow-lg shadow-gray-100/50 border border-gray-100/50">
                    <div className="flex items-start justify-between mb-4">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 bg-purple-50 rounded-2xl flex items-center justify-center">
                                <PlayCircle className="w-6 h-6 text-trust-navy" />
                            </div>
                            <div>
                                <h2 className="text-lg font-bold text-gray-900">{t('OptionC.title')}</h2>
                                <div className="text-2xl font-bold text-gray-900 mt-1">{t('OptionC.price')}</div>
                            </div>
                        </div>
                    </div>

                    <p className="text-gray-500 text-sm mb-6 leading-relaxed">{t('OptionC.subtitle')}</p>

                    <ServiceCheckoutButton
                        label="Select Plan"
                        price={t('OptionC.price')}
                        basePriceNumeric={29}
                        plan="simulator"
                        variant="outline"
                        className="w-full border-2 border-trust-navy text-trust-navy bg-white hover:bg-gray-50 h-12 rounded-full text-base font-bold transition-colors"
                    />
                </div>
            </div>
        </div>

    );
}
