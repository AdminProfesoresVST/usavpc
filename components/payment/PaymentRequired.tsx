"use client";

import { useEffect, useState } from "react";
import { Loader2 } from "lucide-react";
import { useTranslations } from "next-intl";

export function PaymentRequired({ plan }: { plan: string }) {
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const initiateCheckout = async () => {
            try {
                const response = await fetch('/api/checkout', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        locale: 'en', // Should get from params or context
                        plan: plan
                    })
                });
                const data = await response.json();
                if (data.url) {
                    window.location.href = data.url;
                }
            } catch (error) {
                console.error("Checkout Error:", error);
                setLoading(false);
            }
        };

        initiateCheckout();
    }, [plan]);

    return (
        <div className="min-h-screen flex flex-col items-center justify-center bg-official-grey">
            <div className="bg-white p-8 rounded-lg shadow-lg text-center max-w-md">
                <Loader2 className="w-12 h-12 text-trust-navy animate-spin mx-auto mb-4" />
                <h2 className="text-xl font-serif font-bold text-trust-navy mb-2">
                    Initiating Secure Payment...
                </h2>
                <p className="text-gray-500">
                    Please wait while we redirect you to our secure payment processor.
                </p>
                {!loading && (
                    <p className="text-red-500 mt-4">
                        Error connecting to payment provider. Please try again.
                    </p>
                )}
            </div>
        </div>
    );
}
