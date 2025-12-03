"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { UpsellModal } from "./UpsellModal";
import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';
import { cn } from "@/lib/utils";

interface ServiceCheckoutButtonProps {
    label: string;
    price: string; // Display price string (e.g. "$39")
    basePriceNumeric: number; // Numeric price for calculation (e.g. 39)
    plan: 'diy' | 'full' | 'simulator';
    className?: string;
    variant?: 'default' | 'featured' | 'outline';
}

export function ServiceCheckoutButton({
    label,
    price,
    basePriceNumeric,
    plan,
    className,
    variant = 'default'
}: ServiceCheckoutButtonProps) {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const router = useRouter();
    const locale = useLocale();

    const handleProceed = async (addons: string[]) => {
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
                    addons
                }),
            });

            const { url } = await response.json();
            if (url) {
                window.location.href = url;
            } else {
                // Fallback if no URL returned (e.g. free plan or error)
                router.push(`/${locale}/assessment?plan=${plan}`);
            }
        } catch (error) {
            console.error("Checkout error:", error);
            setIsLoading(false);
            // Fallback on error
            router.push(`/${locale}/assessment?plan=${plan}`);
        }
    };

    return (
        <>
            <Button
                onClick={() => setIsModalOpen(true)}
                className={cn(
                    "w-full font-bold shadow-md py-6 text-lg",
                    variant === 'featured'
                        ? "bg-accent-gold hover:bg-accent-gold/90 text-trust-navy border-none"
                        : variant === 'outline'
                            ? "bg-white hover:bg-gray-50 text-trust-navy border border-input"
                            : "bg-primary text-white hover:bg-primary/90",
                    className
                )}
                disabled={isLoading}
            >
                {isLoading ? "Processing..." : label}
            </Button>

            <UpsellModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                onProceed={handleProceed}
                basePrice={basePriceNumeric}
                currentPlan={plan}
            />
        </>
    );
}
