"use client";

import { useTranslations } from 'next-intl';
import Image from "next/image";
import { Smartphone, Tablet } from "lucide-react";

export function DesktopBlocker() {
    return (
        <div className="min-h-screen w-full bg-trust-navy flex flex-col items-center justify-center p-8 text-center">

            {/* Logo */}
            <div className="relative w-24 h-24 mb-6 animate-fade-in">
                <Image
                    src="/logo.png"
                    alt="US Visa Processing Center"
                    fill
                    className="object-contain"
                    priority
                />
            </div>

            {/* Title */}
            <h1 className="text-3xl font-serif font-bold text-white mb-2 tracking-tight">
                US Visa Processing Center
            </h1>

            {/* Divider */}
            <div className="w-16 h-1 bg-accent-gold rounded-full mb-8"></div>

            {/* Message Box */}
            <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-8 max-w-md w-full shadow-2xl">
                <div className="flex justify-center gap-4 text-accent-gold mb-4">
                    <Smartphone className="w-8 h-8" />
                    <Tablet className="w-8 h-8" />
                </div>

                <h2 className="text-xl font-bold text-white mb-3">
                    Dispositivo No Compatible
                </h2>

                <p className="text-white/80 leading-relaxed">
                    Esta aplicación está optimizada exclusivamente para teléfonos y tabletas.
                    <br /><br />
                    Por favor, ingrese desde su dispositivo móvil para continuar con su solicitud de forma segura.
                </p>
            </div>

            <p className="fixed bottom-8 text-white/40 text-[10px] font-mono tracking-widest uppercase">
                Mobile First Experience • v1.5.5
            </p>
        </div>
    );
}
