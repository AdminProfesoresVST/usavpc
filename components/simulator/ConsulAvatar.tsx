"use client";

import { motion } from "framer-motion";
import { User, UserCheck, UserX, AlertTriangle, ShieldAlert, BadgeCheck } from "lucide-react";
import { cn } from "@/lib/utils";

interface ConsulAvatarProps {
    sentiment: "neutral" | "skeptical" | "angry" | "positive";
    isSpeaking?: boolean;
    className?: string;
}

export function ConsulAvatar({ sentiment, isSpeaking, className }: ConsulAvatarProps) {

    const getIcon = () => {
        switch (sentiment) {
            case "positive": return <BadgeCheck className="w-8 h-8 text-white" />;
            case "skeptical": return <AlertTriangle className="w-8 h-8 text-white" />;
            case "angry": return <ShieldAlert className="w-8 h-8 text-white" />;
            default: return <User className="w-8 h-8 text-white" />;
        }
    };

    const getBgColor = () => {
        switch (sentiment) {
            case "positive": return "bg-green-600";
            case "skeptical": return "bg-amber-600";
            case "angry": return "bg-red-600";
            default: return "bg-slate-700";
        }
    };

    return (
        <div className={cn("relative", className)}>
            {/* Pulse when speaking */}
            {isSpeaking && (
                <motion.div
                    className={cn("absolute inset-0 rounded-full opacity-50", getBgColor())}
                    animate={{ scale: [1, 1.2, 1] }}
                    transition={{ repeat: Infinity, duration: 1.5 }}
                />
            )}

            {/* Main Avatar Circle */}
            <motion.div
                className={cn(
                    "relative z-10 w-14 h-14 rounded-full flex items-center justify-center shadow-lg transition-colors duration-500",
                    getBgColor()
                )}
                initial={false}
                animate={{ scale: isSpeaking ? 1.05 : 1 }}
            >
                {getIcon()}
            </motion.div>

            {/* Status Indicator Dot */}
            <div className={cn(
                "absolute bottom-0 right-0 w-4 h-4 rounded-full border-2 border-white z-20",
                sentiment === "neutral" ? "bg-gray-400" :
                    sentiment === "positive" ? "bg-green-400" :
                        sentiment === "skeptical" ? "bg-amber-400" : "bg-red-500"
            )} />
        </div>
    );
}
