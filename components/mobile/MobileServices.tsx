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
                <div className="bg-trust-navy rounded-3xl p-6 text-white shadow-xl shadow-trust-navy/20 relative overflow-hidden">
                    <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl"></div>

                    <div className="relative z-10">
                        <div className="flex justify-between items-start mb-4">
                            <div className="bg-accent-gold text-trust-navy text-[10px] font-bold px-2 py-1 rounded-md uppercase tracking-wide">
                                Recommended
                            </div>
                            <ShieldCheck className="w-6 h-6 text-accent-gold" />
                        </div>

                        <h2 className="text-xl font-bold mb-1">{t('OptionB.title')}</h2>
                        <p className="text-white/80 text-xs mb-4">{t('OptionB.subtitle')}</p>

                        <div className="space-y-3 mb-6">
                            {[t('OptionB.feature1'), t('OptionB.feature2'), t('OptionB.feature3')].map((feature, i) => (
                                <div key={i} className="flex items-center gap-3">
                                    <CheckCircle2 className="w-5 h-5 text-success-green shrink-0" />
                                    <span className="text-sm font-medium text-white/90">{feature}</span>
                                </div>
                            ))}
                        </div>

                        <div className="flex items-center justify-between mt-6 pt-6 border-t border-white/10">
                            <div className="text-3xl font-bold text-white">{t('OptionB.price')}</div>
                            <ServiceCheckoutButton
                                label="Select Plan"
                                price={t('OptionB.price')}
                                basePriceNumeric={99}
                                plan="full"
                                variant="featured"
                                className="bg-white text-trust-navy hover:bg-white/90 px-8 h-12 rounded-xl text-base font-bold shadow-lg transform active:scale-95 transition-all"
                            />
                        </div>
                    </div>
                </div>

                {/* DIY Option */}
                <div className="bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
                    <div className="flex justify-between items-start mb-4">
                        <div className="w-10 h-10 bg-green-50 rounded-full flex items-center justify-center">
                            <BrainCircuit className="w-5 h-5 text-success-green" />
                        </div>
                    </div>

                    <h2 className="text-lg font-bold text-gray-900 mb-1">{t('OptionA.title')}</h2>
                    <p className="text-gray-500 text-xs mb-4">{t('OptionA.subtitle')}</p>

                    <div className="space-y-3 mb-6">
                        {[t('OptionA.feature1'), t('OptionA.feature2'), t('OptionA.feature3')].map((feature, i) => (
                            <div key={i} className="flex items-center gap-3">
                                <CheckCircle2 className="w-5 h-5 text-gray-400 shrink-0" />
                                <span className="text-sm font-medium text-gray-700">{feature}</span>
                            </div>
                        ))}
                    </div>

                    <div className="flex items-center justify-between mt-6 pt-6 border-t border-gray-100">
                        <div className="text-2xl font-bold text-gray-900">{t('OptionA.price')}</div>
                        <ServiceCheckoutButton
                            label="Select Plan"
                            price={t('OptionA.price')}
                            basePriceNumeric={39}
                            plan="diy"
                            variant="outline"
                            className="border-2 border-success-green text-success-green bg-green-50/50 hover:bg-green-50 px-8 h-12 rounded-xl text-base font-bold transition-colors"
                        />
                    </div>
                </div>

                {/* Simulator Option */}
                <div className="bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
                    <div className="flex justify-between items-start mb-4">
                        <div className="w-10 h-10 bg-purple-50 rounded-full flex items-center justify-center">
                            <PlayCircle className="w-5 h-5 text-purple-600" />
                        </div>
                    </div>

                    <h2 className="text-lg font-bold text-gray-900 mb-1">{t('OptionC.title')}</h2>
                    <p className="text-gray-500 text-xs mb-4">{t('OptionC.subtitle')}</p>

                    <div className="space-y-3 mb-6">
                        {[t('OptionC.feature1'), t('OptionC.feature2'), t('OptionC.feature3')].map((feature, i) => (
                            <div key={i} className="flex items-center gap-3">
                                <CheckCircle2 className="w-5 h-5 text-gray-400 shrink-0" />
                                <span className="text-sm font-medium text-gray-700">{feature}</span>
                            </div>
                        ))}
                    </div>

                    <div className="flex items-center justify-between mt-6 pt-6 border-t border-gray-100">
                        <div className="text-2xl font-bold text-gray-900">{t('OptionC.price')}</div>
                        <ServiceCheckoutButton
                            label="Select Plan"
                            price={t('OptionC.price')}
                            basePriceNumeric={29}
                            plan="simulator"
                            variant="outline"
                            className="border-2 border-purple-600 text-purple-600 bg-purple-50/50 hover:bg-purple-50 px-8 h-12 rounded-xl text-base font-bold transition-colors"
                        />
                    </div>
                </div>
            </div>
        </div>

    );
}
