"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';
import { Check, FileCheck, AlertTriangle, RefreshCw } from "lucide-react";
import { Header } from "@/components/layout/Header";

interface PassportData {
    rawText?: string;
    passportNumber?: string;
    surname?: string;
    givenNames?: string;
    dob?: string;
    expiry?: string;
    sex?: string;
    country?: string;
    photoUrl?: string; // We stored the object URL
}

export default function VerifyPage() {
    const router = useRouter();
    const locale = useLocale();
    const [data, setData] = useState<PassportData | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const stored = localStorage.getItem('passportData');
        if (stored) {
            try {
                const parsed = JSON.parse(stored);
                setData(parsed);
            } catch (e) {
                console.error("Failed to parse passport data", e);
            }
        }
        setLoading(false);
    }, []);

    if (loading) return (
        <div className="h-full flex items-center justify-center bg-[#F0F2F5]">
            <span className="text-gray-400 text-sm animate-pulse">Cargando datos...</span>
        </div>
    );

    // Default or Extracted Data
    const displayData = {
        name: `${data?.givenNames || ''} ${data?.surname || ''}`.trim() || "NO DETECTADO",
        number: data?.passportNumber || "NO DETECTADO",
        dob: data?.dob || "----/--/--",
        sex: data?.sex || "-",
        expiry: data?.expiry || "----/--/--",
        country: data?.country || "---"
    };

    const hasMissingData = !data?.passportNumber || !data?.surname;

    return (
        <div className="flex flex-col h-full bg-[#F0F2F5]">
            <div className="fade-enter h-full flex flex-col p-6 overflow-y-auto">
                <div className="flex flex-col items-center mb-6">
                    <div className={`w-16 h-16 rounded-full flex items-center justify-center mb-3 ${hasMissingData ? 'bg-amber-100' : 'bg-green-100'}`}>
                        {hasMissingData ? (
                            <AlertTriangle className="w-8 h-8 text-amber-600" />
                        ) : (
                            <Check className="w-8 h-8 text-green-600" />
                        )}
                    </div>
                    <h2 className="text-xl font-bold text-[#003366]">
                        {hasMissingData ? "Revisión Necesaria" : "Identidad Verificada"}
                    </h2>
                    <p className="text-gray-500 text-sm text-center">
                        {hasMissingData
                            ? "Algunos datos no se leyeron bien. Por favor corríjalos."
                            : "Confirme que la información extraída es correcta."}
                    </p>
                </div>

                {/* Passport Preview (Small) */}
                {data?.photoUrl && (
                    <div className="mb-4 flex justify-center">
                        <img
                            src={data.photoUrl}
                            alt="Passport Preview"
                            className="h-32 object-contain rounded-lg border border-gray-200 shadow-sm"
                        />
                    </div>
                )}

                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden flex-1 mb-4 h-fit">
                    <div className="p-4 border-b border-gray-50 flex items-center justify-between bg-gray-50/50">
                        <span className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Datos del Pasaporte</span>
                        <FileCheck className="w-4 h-4 text-[#003366]" />
                    </div>
                    <div className="divide-y divide-gray-50">
                        <div className="p-4 flex flex-col gap-1">
                            <span className="text-xs text-gray-400">Nombre Completo</span>
                            <input
                                type="text"
                                defaultValue={displayData.name}
                                className="font-semibold text-[#003366] bg-transparent border-none p-0 focus:ring-0 w-full"
                            />
                        </div>
                        <div className="p-4 flex flex-col gap-1">
                            <span className="text-xs text-gray-400">Número de Pasaporte</span>
                            <input
                                type="text"
                                defaultValue={displayData.number}
                                className="font-bold text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full"
                            />
                        </div>
                        <div className="p-4 flex justify-between">
                            <div className="flex flex-col gap-1">
                                <span className="text-xs text-gray-400">Nacimiento</span>
                                <input
                                    type="text"
                                    defaultValue={displayData.dob}
                                    className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-24"
                                />
                            </div>
                            <div className="flex flex-col gap-1 text-right">
                                <span className="text-xs text-gray-400">Sexo</span>
                                <input
                                    type="text"
                                    defaultValue={displayData.sex}
                                    className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-8 text-right"
                                />
                            </div>
                        </div>
                        <div className="p-4 flex justify-between">
                            <div className="flex flex-col gap-1">
                                <span className="text-xs text-gray-400">Vencimiento</span>
                                <input
                                    type="text"
                                    defaultValue={displayData.expiry}
                                    className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-24"
                                />
                            </div>
                            <div className="flex flex-col gap-1 text-right">
                                <span className="text-xs text-gray-400">País</span>
                                <input
                                    type="text"
                                    defaultValue={displayData.country}
                                    className="font-bold text-[#003366] bg-transparent border-none p-0 focus:ring-0 w-12 text-right"
                                />
                            </div>
                        </div>
                    </div>
                </div>

                <button
                    onClick={() => router.push(`/${locale}/success`)}
                    className="w-full bg-[#003366] text-white py-4 rounded-xl font-bold shadow-lg shadow-blue-900/20 active:scale-95 transition-all mt-auto mb-3"
                >
                    Confirmar y Continuar
                </button>
                <button
                    onClick={() => router.push(`/${locale}/scan`)}
                    className="w-full text-gray-400 text-sm font-medium pb-4 flex items-center justify-center gap-2"
                >
                    <RefreshCw size={14} /> Volver a Escanear
                </button>
            </div>
        </div>
    );
}
