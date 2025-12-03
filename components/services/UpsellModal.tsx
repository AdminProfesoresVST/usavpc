"use client";

import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Shield, Radar, Mic, CheckCircle2 } from "lucide-react";
import { useTranslations } from 'next-intl';

interface UpsellModalProps {
    isOpen: boolean;
    onClose: () => void;
    onProceed: (addons: string[]) => void;
    basePrice: number;
    currentPlan?: string;
}

export function UpsellModal({ isOpen, onClose, onProceed, basePrice, currentPlan }: UpsellModalProps) {
    const t = useTranslations('Upsell');
    // Default selection: Radar and Insurance. Exclude Simulator if currentPlan is simulator.
    const defaultAddons = ['radar', 'insurance'];
    if (currentPlan !== 'simulator') {
        defaultAddons.push('simulator');
    }

    const [selectedAddons, setSelectedAddons] = useState<string[]>(defaultAddons);

    const allAddons = [
        {
            id: 'radar',
            title: t('radar.title'),
            price: 29,
            icon: Radar,
            desc: t('radar.desc')
        },
        {
            id: 'insurance',
            title: t('insurance.title'),
            price: 15,
            icon: Shield,
            desc: t('insurance.desc')
        },
        {
            id: 'simulator',
            title: t('simulator.title'),
            price: 19, // Discounted from 29
            originalPrice: 29,
            icon: Mic,
            desc: t('simulator.desc')
        }
    ];

    // Filter out addons that are already part of the main plan
    const addons = allAddons.filter(addon => {
        if (currentPlan === 'simulator' && addon.id === 'simulator') return false;
        return true;
    });

    // Track Modal Open
    useEffect(() => {
        if (isOpen) {
            fetch('/api/analytics', {
                method: 'POST',
                body: JSON.stringify({ event_type: 'upsell_modal_opened', metadata: { base_price: basePrice } })
            }).catch(console.error);
        }
    }, [isOpen, basePrice]);

    const toggleAddon = (id: string) => {
        const isSelecting = !selectedAddons.includes(id);
        setSelectedAddons(prev =>
            prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]
        );

        // Track Interaction
        fetch('/api/analytics', {
            method: 'POST',
            body: JSON.stringify({
                event_type: 'upsell_interaction',
                metadata: { addon_id: id, action: isSelecting ? 'select' : 'deselect' }
            })
        }).catch(console.error);
    };

    const totalAddons = addons
        .filter(a => selectedAddons.includes(a.id))
        .reduce((sum, a) => sum + a.price, 0);

    const totalPrice = basePrice + totalAddons;

    const handleProceed = () => {
        fetch('/api/analytics', {
            method: 'POST',
            body: JSON.stringify({
                event_type: 'checkout_initiated',
                metadata: { total_price: totalPrice, addons: selectedAddons }
            })
        }).catch(console.error);
        onProceed(selectedAddons);
    };

    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent className="sm:max-w-[500px]">
                <DialogHeader>
                    <DialogTitle className="text-2xl font-serif text-trust-navy">{t('title')}</DialogTitle>
                    <DialogDescription>
                        {t('subtitle')}
                    </DialogDescription>
                </DialogHeader>

                <div className="space-y-4 py-4">
                    {addons.map((addon) => (
                        <div
                            key={addon.id}
                            className={`flex items-start space-x-4 p-4 rounded-lg border-2 cursor-pointer transition-all ${selectedAddons.includes(addon.id) ? 'border-accent-gold bg-blue-50' : 'border-gray-100 hover:border-gray-200'}`}
                            onClick={() => toggleAddon(addon.id)}
                        >
                            <Checkbox
                                checked={selectedAddons.includes(addon.id)}
                                className="mt-1"
                            />
                            <div className="flex-1">
                                <div className="flex justify-between items-center mb-1">
                                    <h4 className="font-bold text-trust-navy flex items-center gap-2">
                                        <addon.icon size={16} />
                                        {addon.title}
                                    </h4>
                                    <div className="text-right">
                                        {addon.originalPrice && (
                                            <span className="text-xs text-gray-400 line-through mr-2">${addon.originalPrice}</span>
                                        )}
                                        <span className="font-bold text-green-600">+${addon.price}</span>
                                    </div>
                                </div>
                                <p className="text-sm text-gray-600 leading-tight">{addon.desc}</p>
                            </div>
                        </div>
                    ))}
                </div>

                <DialogFooter className="flex-col sm:flex-col gap-3">
                    <Button
                        onClick={handleProceed}
                        className="w-full py-6 text-lg font-bold bg-trust-navy hover:bg-blue-900"
                    >
                        {t('cta')} (${totalPrice})
                    </Button>
                    <p className="text-xs text-center text-gray-400">
                        {t('secure')}
                    </p>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}
