"use client";

import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';
import { Check, FileCheck } from "lucide-react";
import { Header } from "@/components/layout/Header";

export default function VerifyPage() {
    const router = useRouter();
    const locale = useLocale();

    return (
        <div className="flex flex-col h-full bg-[#F0F2F5]">
            <Header />

            <div className="fade-enter h-full flex flex-col p-6">
                <div className="flex flex-col items-center mb-6">
                    <div className="w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mb-3">
                        <Check className="w-8 h-8 text-green-600" />
                    </div>
                    <h2 className="text-xl font-bold text-[#1F2937]">Identidad Verificada</h2>
                    <p className="text-gray-500 text-sm">Confirme que la información es correcta</p>
                </div>

                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden flex-1 mb-4">
                    <div className="p-4 border-b border-gray-50 flex items-center justify-between bg-gray-50/50">
                        <span className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Datos Extraídos</span>
                        <FileCheck className="w-4 h-4 text-[#2672DE]" />
                    </div>
                    <div className="divide-y divide-gray-50">
                        <div className="p-4 flex flex-col gap-1">
                            <span className="text-xs text-gray-400">Nombre Completo</span>
                            <span className="font-semibold text-[#003366]">OSIRIS VILLACAMPA RECIO</span>
                        </div>
                        <div className="p-4 flex flex-col gap-1">
                            <span className="text-xs text-gray-400">Número de Pasaporte</span>
                            <span className="font-semibold text-[#1F2937]">SC4260875</span>
                        </div>
                        <div className="p-4 flex justify-between">
                            <div className="flex flex-col gap-1">
                                <span className="text-xs text-gray-400">Nacimiento</span>
                                <span className="font-medium text-[#1F2937]">1976-05-17</span>
                            </div>
                            <div className="flex flex-col gap-1 text-right">
                                <span className="text-xs text-gray-400">Sexo</span>
                                <span className="font-medium text-[#1F2937]">M</span>
                            </div>
                        </div>
                        <div className="p-4 flex justify-between">
                            <div className="flex flex-col gap-1">
                                <span className="text-xs text-gray-400">Vencimiento</span>
                                <span className="font-medium text-[#1F2937]">2026-01-09</span>
                            </div>
                            <div className="flex flex-col gap-1 text-right">
                                <span className="text-xs text-gray-400">País</span>
                                <span className="font-bold text-[#003366]">DOM</span>
                            </div>
                        </div>
                    </div>
                </div>

                <button
                    onClick={() => router.push(`/${locale}/success`)}
                    className="w-full bg-[#2672DE] text-white py-4 rounded-xl font-semibold shadow-lg active:scale-95 transition-all mt-auto mb-4"
                >
                    Confirmar y Continuar
                </button>
                <button className="w-full text-gray-400 text-sm font-medium pb-2">Hay un error, reintentar</button>
            </div>
        </div>
    );
}
