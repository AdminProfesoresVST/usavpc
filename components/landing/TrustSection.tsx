"use client";

import { useTranslations } from 'next-intl';
import { ShieldCheck, Zap, BrainCircuit } from "lucide-react";

export function TrustSection() {
    const t = useTranslations('HomePage.Trust');

    const features = [
        {
            key: 'encryption',
            icon: ShieldCheck,
            color: "text-trust-navy",
            bg: "bg-blue-50",
            border: "group-hover:border-trust-navy/20"
        },
        {
            key: 'speed',
            icon: Zap, // Changed from Clock to Zap for "Speed"
            color: "text-accent-gold",
            bg: "bg-amber-50",
            border: "group-hover:border-accent-gold/20"
        },
        {
            key: 'ai',
            icon: BrainCircuit, // Changed from FileCheck to Brain for "AI"
            color: "text-success-green",
            bg: "bg-green-50",
            border: "group-hover:border-success-green/20"
        }
    ];

    return (
        <section className="py-8 bg-gradient-to-b from-white to-slate-50/50">
            <div className="container mx-auto px-4">
                <div className="text-center mb-6 max-w-2xl mx-auto">
                    <h2 className="text-2xl md:text-3xl font-sans font-bold text-trust-navy mb-2">
                        {t('title')}
                    </h2>
                    <div className="h-1 w-12 bg-accent-gold mx-auto rounded-full"></div>
                </div>

                <div className="grid md:grid-cols-3 gap-4">
                    {features.map((feature) => {
                        const Icon = feature.icon;
                        return (
                            <div
                                key={feature.key}
                                className={`group relative bg-white p-5 rounded-xl shadow-sm hover:shadow-md transition-all duration-300 border border-slate-100 ${feature.border}`}
                            >
                                <div className="flex items-center gap-4 mb-3">
                                    <div className={`w-10 h-10 ${feature.bg} rounded-lg flex items-center justify-center group-hover:scale-110 transition-transform duration-300`}>
                                        <Icon className={`w-5 h-5 ${feature.color}`} />
                                    </div>
                                    <h3 className="text-lg font-bold text-gray-900">
                                        {t(`${feature.key}.title`)}
                                    </h3>
                                </div>

                                <p className="text-sm text-gray-600 leading-snug">
                                    {t(`${feature.key}.desc`)}
                                </p>
                            </div>
                        );
                    })}
                </div>
            </div>
        </section>
    );
}
