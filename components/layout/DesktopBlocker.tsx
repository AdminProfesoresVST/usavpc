"use client";

import { useTranslations } from 'next-intl';
import Image from "next/image";
import { Smartphone, Tablet } from "lucide-react";

export function DesktopBlocker() {
    return (
        <div className="min-h-screen w-full bg-white flex flex-col items-center justify-center p-8 text-center font-sans">

            {/* Logo & Brand */}
            <div className="flex flex-col items-center gap-4 mb-8">
                <div className="relative w-20 h-20">
                    <Image
                        src="/logo.png"
                        alt="US Visa Processing Center"
                        fill
                        className="object-contain"
                        priority
                    />
                </div>
                <h1 className="text-2xl font-black tracking-tight text-trust-navy">
                    US Visa Processing Center
                </h1>
            </div>

            {/* Discrete Message */}
            <div className="max-w-xs flex flex-col items-center gap-4">
                <div className="flex gap-3 text-gray-300">
                    <Smartphone className="w-6 h-6 stroke-1" />
                    <Tablet className="w-6 h-6 stroke-1" />
                </div>

                <p className="text-sm font-medium text-gray-500 leading-relaxed">
                    Esta aplicación está diseñada exclusivamente para dispositivos móviles y tabletas.
                </p>
            </div>
        </div>
    );
}
