"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { useTranslations } from "next-intl";
import { CheckCircle2, AlertTriangle, Star, Shield, FileText } from "lucide-react";

interface DecisionProps {
    answers: any;
    onComplete: () => void;
}

export function Decision({ answers, onComplete }: DecisionProps) {
    const t = useTranslations('HomePage.Decision');
    const [analyzing, setAnalyzing] = useState(true);
    const [loading, setLoading] = useState(false);

    // Determine if complex case (refusals = yes)
    const isComplex = answers.q2 === 'yes';

    useEffect(() => {
        const timer = setTimeout(() => {
            setAnalyzing(false);
        }, 2000);
        return () => clearTimeout(timer);
    }, []);

    if (analyzing) {
        return (
            <Card className="w-full max-w-md mx-auto p-12 bg-white shadow-lg border-border flex flex-col items-center justify-center min-h-[400px]">
                <div className="relative w-24 h-24 mb-6">
                    <div className="absolute inset-0 border-4 border-gray-100 rounded-full"></div>
                    <div className="absolute inset-0 border-4 border-trust-navy rounded-full border-t-transparent animate-spin"></div>
                    <Shield className="absolute inset-0 m-auto w-10 h-10 text-trust-navy" />
                </div>
                <h2 className="text-xl font-serif font-bold text-trust-navy animate-pulse">
                    {t('analyzing')}
                </h2>
            </Card>
        );
    }

    return (
        <Card className="w-full max-w-md mx-auto overflow-hidden shadow-xl border-0 bg-trust-navy text-white">
            <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                className="p-8 text-center"
            >
                {/* Result Header */}
                <div className="mb-8">
                    {isComplex ? (
                        <div className="inline-flex items-center gap-2 bg-accent-gold/20 text-accent-gold px-4 py-2 rounded-full mb-4 border border-accent-gold/30">
                            <AlertTriangle className="w-5 h-5" />
                            <span className="font-bold uppercase tracking-wider text-sm">Attention Needed</span>
                        </div>
                    ) : (
                        <div className="inline-flex items-center gap-2 bg-success-green/20 text-success-green px-4 py-2 rounded-full mb-4 border border-success-green/30">
                            <CheckCircle2 className="w-5 h-5" />
                            <span className="font-bold uppercase tracking-wider text-sm">Great Profile</span>
                        </div>
                    )}

                    <h2 className="text-3xl font-serif font-bold mb-2">
                        {isComplex ? t('result.complex') : t('result.good')}
                    </h2>
                </div>

                {/* Upsell Content */}
                <div className="bg-white/5 rounded-lg p-6 mb-8 border border-white/10 backdrop-blur-sm">
                    <h3 className="text-accent-gold font-bold mb-4 uppercase tracking-widest text-xs">
                        {t('upsell.title')}
                    </h3>
                    <p className="text-white/90 mb-6 leading-relaxed">
                        {t('upsell.desc')}
                    </p>

                    <div className="grid grid-cols-2 gap-4 text-left">
                        <div className="flex items-center gap-2 text-sm">
                            <Star className="w-4 h-4 text-accent-gold" />
                            <span>{t('upsell.benefit1')}</span>
                        </div>
                        <div className="flex items-center gap-2 text-sm">
                            <FileText className="w-4 h-4 text-accent-gold" />
                            <span>{t('upsell.benefit2')}</span>
                        </div>
                    </div>
                </div>

                {/* High Contrast CTA */}
                <Button
                    size="lg"
                    className="w-full bg-white text-[#003366] hover:bg-gray-100 font-bold text-lg py-6 shadow-lg transform transition hover:scale-105"
                    disabled={analyzing || loading}
                    onClick={async () => {
                        setLoading(true);

                        // Trigger Stripe Checkout
                        try {
                            const response = await fetch('/api/checkout', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({
                                    locale: 'en',
                                    plan: isComplex ? 'full' : 'diy'
                                })
                            });
                            const data = await response.json();
                            if (data.url) {
                                window.location.href = data.url;
                            } else {
                                console.error("Checkout Failed", data.error);
                                onComplete(); // Fallback
                            }
                        } catch (error) {
                            console.error("Checkout Error:", error);
                            onComplete(); // Fallback
                        } finally {
                            // setLoading(false); // Don't reset if redirecting
                        }
                    }}
                >
                    {loading ? (
                        <span className="flex items-center">
                            <span className="animate-spin mr-2">⏳</span> Processing...
                        </span>
                    ) : (
                        t('upsell.cta')
                    )}
                </Button>
            </motion.div>
        </Card >
    );
}
