"use client";

import { useTranslations } from "next-intl";
import { CheckCircle2, FileText, ShieldCheck, Clock, Send } from "lucide-react";
import { cn } from "@/lib/utils";

interface StatusTrackerProps {
    currentStep: 1 | 2 | 3 | 4;
}

export function StatusTracker({ currentStep }: StatusTrackerProps) {
    const t = useTranslations('Dashboard.Status');

    const steps = [
        { id: 1, key: 'received', icon: FileText },
        { id: 2, key: 'validated', icon: ShieldCheck },
        { id: 3, key: 'queue', icon: Clock },
        { id: 4, key: 'ready', icon: Send },
    ];

    return (
        <div className="w-full py-8">
            <div className="relative flex justify-between items-center max-w-3xl mx-auto">
                {/* Progress Bar Background */}
                <div className="absolute top-1/2 left-0 w-full h-1 bg-gray-200 -z-10 transform -translate-y-1/2 rounded-full" />

                {/* Active Progress Bar */}
                <div
                    className="absolute top-1/2 left-0 h-1 bg-success-green -z-10 transform -translate-y-1/2 rounded-full transition-all duration-1000 ease-out"
                    style={{ width: `${((currentStep - 1) / (steps.length - 1)) * 100}%` }}
                />

                {steps.map((step) => {
                    const isActive = step.id <= currentStep;
                    const isCurrent = step.id === currentStep;
                    const Icon = step.icon;

                    return (
                        <div key={step.id} className="flex flex-col items-center gap-3 relative group">
                            <div
                                className={cn(
                                    "w-12 h-12 rounded-full flex items-center justify-center border-4 transition-all duration-500 z-10 bg-white",
                                    isActive
                                        ? "border-success-green text-success-green shadow-lg scale-110"
                                        : "border-gray-200 text-gray-300"
                                )}
                            >
                                {isActive ? (
                                    <CheckCircle2 className="w-6 h-6" />
                                ) : (
                                    <Icon className="w-5 h-5" />
                                )}
                            </div>

                            <div className="absolute top-14 w-32 text-center">
                                <span
                                    className={cn(
                                        "text-xs font-bold uppercase tracking-wider transition-colors duration-300",
                                        isActive ? "text-trust-navy" : "text-gray-400",
                                        isCurrent && "text-success-green scale-105"
                                    )}
                                >
                                    {t(step.key)}
                                </span>
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
}
