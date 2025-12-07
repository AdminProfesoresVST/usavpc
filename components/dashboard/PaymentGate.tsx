"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { useLocale, useTranslations } from 'next-intl';
import { Lock, ShieldCheck, ArrowRight, Star } from "lucide-react";
import { useRouter } from "next/navigation";

interface PaymentGateProps {
    applicationId: string;
    plan: string;
    price: string;
}

export function PaymentGate({ applicationId, plan, price }: PaymentGateProps) {
    const [isLoading, setIsLoading] = useState(false);
    const locale = useLocale();
    const router = useRouter();
    const t = useTranslations('Dashboard');

    const handlePayment = async () => {
        setIsLoading(true);
        try {
            const response = await fetch('/api/checkout', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    plan,
                    locale,
                    applicationId // Link payment to this specific application
                }),
            });

            const { url } = await response.json();
            if (url) {
                window.location.href = url;
            } else {
                // Fallback or error
                console.error("No URL returned from checkout");
                setIsLoading(false);
            }
        } catch (error) {
            console.error("Payment Error:", error);
            setIsLoading(false);
        }
    };

    return (
        <Card className="w-full bg-gradient-to-br from-trust-navy to-blue-900 text-white overflow-hidden shadow-xl border-0">
            <div className="p-8 md:p-12 text-center relative">
                {/* Background Decorations */}
                <div className="absolute top-0 right-0 p-12 opacity-5 pointer-events-none">
                    <ShieldCheck size={200} />
                </div>

                <div className="relative z-10 flex flex-col items-center">
                    <div className="bg-white/10 p-4 rounded-full mb-6 backdrop-blur-sm">
                        <Lock className="w-10 h-10 text-accent-gold" />
                    </div>

                    <h2 className="text-3xl md:text-4xl font-serif font-bold mb-4">
                        {t('paymentGate.title', { defaultMessage: 'Unlock Your Application' })}
                    </h2>

                    <p className="text-white/80 text-lg max-w-xl mx-auto mb-8 leading-relaxed">
                        {t('paymentGate.description', { defaultMessage: 'Your application data is complete and analyzing is finished. Proceed with payment to unlock your personalized strategy and download your documents.' })}
                    </p>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 w-full max-w-lg mb-8 text-left">
                        <div className="bg-white/5 p-4 rounded border border-white/10 flex items-center gap-3">
                            <Star className="text-accent-gold shrink-0" size={20} />
                            <span className="font-medium text-sm">Full VisaScore™ Report</span>
                        </div>
                        <div className="bg-white/5 p-4 rounded border border-white/10 flex items-center gap-3">
                            <Star className="text-accent-gold shrink-0" size={20} />
                            <span className="font-medium text-sm">DS-160 Validated PDF</span>
                        </div>
                    </div>

                    <Button
                        size="lg"
                        onClick={handlePayment}
                        disabled={isLoading}
                        className="bg-accent-gold hover:bg-yellow-500 text-trust-navy font-bold text-xl px-12 py-8 rounded-lg shadow-lg transform transition hover:scale-105"
                    >
                        {isLoading ? "Processing..." : t('paymentGate.button', { price: price, defaultMessage: `Pay ${price} to Unlock` })}
                        {!isLoading && <ArrowRight className="ml-2 w-6 h-6" />}
                    </Button>

                    <p className="mt-6 text-xs text-white/50 flex items-center gap-1">
                        <ShieldCheck size={12} /> Secure SSL Payment via Stripe
                    </p>
                </div>
            </div>
        </Card>
    );
}
