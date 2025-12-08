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
    plan: 'diy' | 'full' | 'simulator' | 'appointment';
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
        console.log("ServiceCheckoutButton: Starting checkout process", { plan, addons });
        try {
            // New Flow: Service First. Create Draft Application.
            console.log("ServiceCheckoutButton: Calling /api/applications/draft");
            const response = await fetch('/api/applications/draft', {
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

            console.log("ServiceCheckoutButton: API Response status:", response.status);

            if (response.status === 401) {
                // Not logged in -> Redirect to Register
                console.log("ServiceCheckoutButton: Unauthorized. Redirecting to register.");
                // Use window.location.href to force a full page load and ensure redirect happens
                window.location.href = `/${locale}/register?next=/${locale}/assessment?plan=${plan}`;
                return;
            }

            const data = await response.json();
            console.log("ServiceCheckoutButton: API Response data:", data);

            if (data.success) {
                // Success -> Go to Assessment
                console.log("ServiceCheckoutButton: Success. Redirecting to assessment.");
                router.push(`/${locale}/assessment`);
            } else {
                // Error
                console.error("Draft Creation Error:", data.error);
                alert(`Error creating application: ${data.error}`);
            }

        } catch (error) {
            console.error("Application Start Error:", error);
            alert("An unexpected error occurred. Please try again.");
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <>
            <Button
                onClick={() => setIsModalOpen(true)}
                variant="ghost"
                className={cn(
                    "w-full font-bold shadow-md py-6 text-lg transition-all duration-200",
                    // Base styles based on variant prop
                    variant === 'featured'
                        ? "bg-accent-gold hover:bg-accent-gold/90 text-trust-navy border-none shadow-xl transform hover:scale-105"
                        : variant === 'outline'
                            ? "bg-white hover:bg-gray-50 text-trust-navy border-2 border-trust-navy"
                            : "bg-trust-navy text-white hover:bg-trust-navy/90",
                    // Allow overrides
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
