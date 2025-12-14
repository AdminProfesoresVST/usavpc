"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';
import { ScanFace, Lock, Camera, Loader2 } from "lucide-react";
import { Header } from "@/components/layout/Header";

export default function ScanPage() {
    const router = useRouter();
    const locale = useLocale();
    const [isScanning, setIsScanning] = useState(false);

    const handleScan = () => {
        setIsScanning(true);
        // Simulate scanning process
        setTimeout(() => {
            router.push(`/${locale}/verify`);
        }, 1500);
    };

    return (
        <div className="flex flex-col h-full bg-[#F0F2F5]">
            <Header />

            <div className="flex flex-col items-center text-center h-full justify-center fade-enter pb-6 px-6">
                <div className="w-20 h-20 rounded-full bg-blue-50 flex items-center justify-center mb-6 relative">
                    <ScanFace className="w-10 h-10 text-[#2672DE]" />
                    <div className="absolute -top-1 -right-1 w-6 h-6 bg-[#003366] rounded-full flex items-center justify-center border-2 border-white">
                        <Lock className="w-3 h-3 text-white" />
                    </div>
                </div>

                <h2 className="text-2xl font-bold text-[#1F2937] mb-3">Validación de Identidad</h2>
                <p className="text-gray-500 mb-8 max-w-[80%] leading-relaxed">
                    Por favor escanee su pasaporte para verificar su identidad y autocompletar sus datos.
                </p>

                <button
                    onClick={handleScan}
                    disabled={isScanning}
                    className="w-full bg-[#003366] text-white py-4 rounded-xl font-semibold shadow-lg shadow-blue-900/20 active:scale-95 transition-all flex items-center justify-center gap-2 disabled:opacity-80"
                >
                    {isScanning ? (
                        <>
                            <Loader2 className="w-5 h-5 animate-spin" />
                            Procesando...
                        </>
                    ) : (
                        <>
                            <Camera className="w-5 h-5" />
                            Escanear Pasaporte
                        </>
                    )}
                </button>

                <button onClick={() => router.push(`/${locale}/verify`)} className="mt-4 text-[#2672DE] text-sm font-medium p-2">
                    Introducir datos manualmente
                </button>
            </div>
        </div>
    );
}
