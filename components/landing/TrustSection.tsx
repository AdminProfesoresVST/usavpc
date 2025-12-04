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
        <section className="py-24 bg-gradient-to-b from-white to-slate-50/50">
            <div className="container mx-auto px-4">
                <div className="text-center mb-16 max-w-2xl mx-auto">
                    <h2 className="text-3xl md:text-4xl font-sans font-bold text-trust-navy mb-4">
                        {t('title')}
                    </h2>
                    <div className="h-1 w-20 bg-accent-gold mx-auto rounded-full"></div>
                </div>

                <div className="grid md:grid-cols-3 gap-8">
                    {features.map((feature) => {
                        const Icon = feature.icon;
                        return (
                            <div
                                key={feature.key}
                                className={`group relative bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 border border-slate-100 ${feature.border} top-0 hover:-top-2`}
                            >
                                <div className={`w-16 h-16 ${feature.bg} rounded-2xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300`}>
                                    <Icon className={`w-8 h-8 ${feature.color}`} />
                                </div>

                                <h3 className="text-xl font-bold text-gray-900 mb-3">
                                    {t(`${feature.key}.title`)}
                                </h3>

                                <p className="text-gray-600 leading-relaxed">
                                    {t(`${feature.key}.desc`)}
                                </p>

                                {/* Decorative background element */}
                                <div className="absolute top-0 right-0 w-24 h-24 bg-gradient-to-bl from-slate-50 to-transparent rounded-tr-2xl -z-10 opacity-0 group-hover:opacity-100 transition-opacity" />
                            </div>
                        );
                    })}
                </div>
            </div>
        </section>
    );
}
