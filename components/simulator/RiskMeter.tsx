"use client";

import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

interface RiskMeterProps {
    score: number; // 0-100
    delta?: number;
    className?: string;
}

export function RiskMeter({ score, delta, className }: RiskMeterProps) {
    // Determine Color Zone
    const getColor = (s: number) => {
        if (s < 30) return "bg-red-500";
        if (s < 70) return "bg-yellow-500";
        return "bg-green-500";
    };

    return (
        <div className={cn("flex flex-col gap-1 w-full max-w-xs", className)}>
            <div className="flex justify-between items-end mb-1">
                <span className="text-xs font-bold uppercase tracking-wider text-gray-500">
                    Probabilidad de Visa
                </span>
                <div className="flex items-center gap-2">
                    {delta !== undefined && delta !== 0 && (
                        <motion.span
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            key={delta} // Re-animate on change
                            className={cn(
                                "text-xs font-bold",
                                delta > 0 ? "text-green-600" : "text-red-600"
                            )}
                        >
                            {delta > 0 ? "+" : ""}{delta}%
                        </motion.span>
                    )}
                    <span className={cn("text-lg font-black",
                        score < 30 ? "text-red-600" :
                            score < 70 ? "text-yellow-600" : "text-green-600"
                    )}>
                        {score}%
                    </span>
                </div>
            </div>

            {/* Meter Bar */}
            <div className="h-3 w-full bg-gray-200 rounded-full overflow-hidden relative">
                {/* Background Zones (Optional, simplistic version here) */}
                <div className="absolute left-0 top-0 bottom-0 w-[30%] bg-red-100/50" />
                <div className="absolute left-[30%] top-0 bottom-0 w-[40%] bg-yellow-100/50" />
                <div className="absolute right-0 top-0 bottom-0 w-[30%] bg-green-100/50" />

                {/* Fill */}
                <motion.div
                    className={cn("h-full rounded-full transition-colors duration-500", getColor(score))}
                    initial={{ width: "50%" }}
                    animate={{ width: `${Math.max(5, Math.min(100, score))}%` }}
                    transition={{ type: "spring", stiffness: 50, damping: 10 }}
                />
            </div>
        </div>
    );
}
