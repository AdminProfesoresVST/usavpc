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
                {/* 1. Eligibility Check (Option A) */}
                <div className="bg-white rounded-[2rem] p-6 shadow-lg shadow-gray-100/50 border border-gray-100/50">
                    <div className="flex items-start justify-between mb-4">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 bg-gray-50 rounded-2xl flex items-center justify-center">
                                <BrainCircuit className="w-6 h-6 text-trust-navy" />
                            </div>
                            <div>
                                <h2 className="text-lg font-bold text-gray-900">{t('OptionA.title')}</h2>
                                <div className="text-2xl font-bold text-gray-900 mt-1">{t('OptionA.price')}</div>
                            </div>
                        </div>
                    </div>

                    <p className="text-gray-500 text-sm mb-6 leading-relaxed">{t('OptionA.subtitle')}</p>

                    <ServiceCheckoutButton
                        label={t('OptionA.cta')}
                        price={t('OptionA.price')}
                        basePriceNumeric={39}
                        plan="diy"
                        variant="outline"
                        className="w-full btn-secondary h-12 rounded-xl text-base font-bold transition-colors"
                    />
                </div>

                {/* 2. Form Filling (Option B - Featured) */}
                <div className="bg-trust-navy rounded-[2rem] p-6 text-white shadow-xl shadow-trust-navy/20 relative overflow-hidden">
                    <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl"></div>

                    <div className="relative z-10">
                        <div className="flex justify-between items-start mb-4">
                            <div className="bg-white/10 text-white text-[10px] font-bold px-3 py-1 rounded-full uppercase tracking-wide">
                                {t('OptionB.recommended')}
                            </div>
                            <ShieldCheck className="w-6 h-6 text-white" />
                        </div>

                        <h2 className="text-2xl font-bold mb-2 text-white">{t('OptionB.title')}</h2>
                        <p className="text-white/80 text-sm mb-6 leading-relaxed">{t('OptionB.subtitle')}</p>

                        <div className="flex items-center justify-between mt-4">
                            <div className="text-3xl font-bold text-white">{t('OptionB.price')}</div>
                            <ServiceCheckoutButton
                                label={t('OptionB.cta')}
                                price={t('OptionB.price')}
                                basePriceNumeric={99}
                                plan="full"
                                variant="featured"
                                className="btn-secondary px-8 h-12 rounded-xl text-base font-bold shadow-lg transform active:scale-95 transition-all w-auto min-w-[140px]"
                            />
                        </div>
                    </div>
                </div>

                {/* 3. Appointment (Option D - New) */}
                <div className="bg-white rounded-[2rem] p-6 shadow-lg shadow-gray-100/50 border border-gray-100/50">
                    <div className="flex items-start justify-between mb-4">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 bg-gray-50 rounded-2xl flex items-center justify-center">
                                <Zap className="w-6 h-6 text-trust-navy" />
                            </div>
                            <div>
                                <h2 className="text-lg font-bold text-gray-900">{t('OptionD.title')}</h2>
                                <div className="text-2xl font-bold text-gray-900 mt-1">{t('OptionD.price')}</div>
                            </div>
                        </div>
                    </div>

                    <p className="text-gray-500 text-sm mb-6 leading-relaxed">{t('OptionD.subtitle')}</p>

                    <ServiceCheckoutButton
                        label={t('OptionD.cta')}
                        price={t('OptionD.price')}
                        basePriceNumeric={49}
                        plan="appointment"
                        variant="outline"
                        className="w-full btn-secondary h-12 rounded-xl text-base font-bold transition-colors"
                    />
                </div>

                {/* 4. Interview Prep (Option C) */}
                <div className="bg-white rounded-[2rem] p-6 shadow-lg shadow-gray-100/50 border border-gray-100/50">
                    <div className="flex items-start justify-between mb-4">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 bg-gray-50 rounded-2xl flex items-center justify-center">
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
                        label={t('OptionC.cta')}
                        price={t('OptionC.price')}
                        basePriceNumeric={29}
                        plan="simulator"
                        variant="outline"
                        className="w-full btn-secondary h-12 rounded-xl text-base font-bold transition-colors"
                    />
                </div>
            </div>
        </div>

    );
}
