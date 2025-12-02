"use client";

import { Button } from "@/components/ui/button";
import { CreditCard } from "lucide-react";
import { useLocale } from 'next-intl';
import { useState } from "react";

export function CheckoutButton() {
    const [loading, setLoading] = useState(false);
    const locale = useLocale();

    const handleCheckout = async () => {
        setLoading(true);
        try {
            const response = await fetch("/api/checkout", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ locale }),
            });

            const data = await response.json();
            if (data.url) {
                window.location.href = data.url;
            } else {
                console.error("No URL returned");
            }
        } catch (error) {
            console.error("Checkout Error:", error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <Button
            onClick={handleCheckout}
            disabled={loading}
            className="bg-success-green hover:bg-success-green/90 text-white font-bold py-6 px-8 text-lg shadow-lg hover:shadow-xl transition-all uppercase tracking-wider"
        >
            {loading ? (
                "Processing..."
            ) : (
                <span className="flex items-center gap-2">
                    <CreditCard className="w-6 h-6" />
                    Start Eligibility Review ($39)
                </span>
            )}
        </Button>
    );
}
