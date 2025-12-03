"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { UpsellModal } from "./UpsellModal";
import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';

interface FullServiceCheckoutButtonProps {
    label: string;
    price: string;
}

export function FullServiceCheckoutButton({ label, price }: FullServiceCheckoutButtonProps) {
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
                    plan: 'full',
                    locale,
                    addons
                }),
            });

            const { url } = await response.json();
            if (url) {
                window.location.href = url;
            }
        } catch (error) {
            console.error("Checkout error:", error);
            setIsLoading(false);
        }
    };

    return (
        <>
            <Button
                onClick={() => setIsModalOpen(true)}
                className="w-full bg-white text-[#003366] hover:bg-gray-100 font-bold border-none shadow-lg py-6 text-lg"
            >
                {label}
            </Button>

            <UpsellModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                onProceed={handleProceed}
                basePrice={99}
            />
        </>
    );
}
