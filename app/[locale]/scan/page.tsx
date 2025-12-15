"use client";

import { useState, useRef } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { useLocale } from 'next-intl';
import { ScanFace, Lock, Camera, Loader2, Upload, Check, AlertTriangle, FileCheck, RefreshCw } from "lucide-react";
import { createWorker } from 'tesseract.js';

interface PassportData {
    rawText?: string;
    passportNumber?: string;
    surname?: string;
    givenNames?: string;
    dob?: string;
    expiry?: string;
    sex?: string;
    country?: string;
    photoUrl?: string;
}

export default function ScanPage() {
    const router = useRouter();
    const locale = useLocale();
    const searchParams = useSearchParams();
    const plan = searchParams.get('plan');

    // State
    const [isScanning, setIsScanning] = useState(false);
    const [status, setStatus] = useState("Esperando imagen...");
    const [scannedData, setScannedData] = useState<PassportData | null>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
        if (!e.target.files || e.target.files.length === 0) return;

        const file = e.target.files[0];
        setIsScanning(true);
        setStatus("Inicializando IA...");

        try {
            const worker = await createWorker('eng');

            setStatus("Leyendo Pasaporte...");
            worker.reinitialize('eng');

            const ret = await worker.recognize(file);
            /* console.log(ret.data.text); */

            setStatus("Extrayendo Datos...");
            const extracted = parsePassportData(ret.data.text);
            const photoUrl = URL.createObjectURL(file);

            setScannedData({
                ...extracted,
                photoUrl
            });

            await worker.terminate();
            setIsScanning(false);

        } catch (error) {
            console.error("OCR Error:", error);
            setStatus("Error al leer. Intente de nuevo.");
            setIsScanning(false);
        }
    };

    const parsePassportData = (text: string) => {
        const lines = text.split('\n');
        let mrzLine2 = "";

        // Find MRZ Line 2 (contains dates and numbers)
        // Look for line starting with Passport Number pattern or just containing many digits and <<
        for (const line of lines) {
            const cleanLine = line.replace(/\s/g, '').toUpperCase();
            // Standard TD3 MRZ Line 2 is 44 chars, starts with Passport Number, contains dates
            // Heuristic: Look for structure with numbers and <
            if (cleanLine.length >= 30 && /[0-9]{6}/.test(cleanLine) && /<+/.test(cleanLine)) {
                // Try to identify if this is the second line
                // Line 2 usually has DOB (6 digits) and Expiry (6 digits)
                mrzLine2 = cleanLine;
                // If we found a likely candidate, we use it. 
                // In a perfect world we verify Check Digits, but for now we just extract.
            }
        }

        let passportNumber = "";
        let dob = "";
        let expiry = "";
        let sex = "";
        let country = "";

        if (mrzLine2 && mrzLine2.length >= 28) {
            // TD3 MRZ Line 2 Format:
            // 0-8:   Passport No
            // 9:     Check
            // 10-12: Nationality
            // 13-18: DOB (YYMMDD)
            // 19:    Check
            // 20:    Sex
            // 21-26: Expiry (YYMMDD)

            passportNumber = mrzLine2.substring(0, 9).replace(/</g, '');
            country = mrzLine2.substring(10, 13).replace(/</g, '');

            const rawDob = mrzLine2.substring(13, 19);
            dob = formatDate(rawDob);

            sex = mrzLine2.substring(20, 21).replace(/</g, '');

            const rawExpiry = mrzLine2.substring(21, 27);
            expiry = formatDate(rawExpiry);
        }

        return {
            rawText: text,
            passportNumber: passportNumber || "NO NUM",
            surname: extractName(lines, 0),
            givenNames: extractName(lines, 1),
            dob: dob || "YY-MM-DD",
            expiry: expiry || "YY-MM-DD",
            sex: sex || "-",
            country: country || "USA"
        };
    };

    const formatDate = (yymmdd: string) => {
        if (!yymmdd || yymmdd.length !== 6 || isNaN(Number(yymmdd))) return "";
        const yy = yymmdd.substring(0, 2);
        const mm = yymmdd.substring(2, 4);
        const dd = yymmdd.substring(4, 6);

        // Basic century logic
        const currentYear = new Date().getFullYear() % 100;
        const century = Number(yy) > currentYear + 10 ? "19" : "20";

        return `${century}${yy}-${mm}-${dd}`;
    };

    const extractName = (lines: string[], priority: number) => {
        // Try to find Line 1 of MRZ: P<USA...
        const mrzLine1 = lines.find(l => l.replace(/\s/g, '').startsWith('P<'));

        if (mrzLine1) {
            const clean = mrzLine1.replace(/\s/g, '').toUpperCase();
            // Format: P<CCC Surname<<Given<Names
            // Strip P<CCC
            const namePart = clean.substring(5);
            const parts = namePart.split('<<');

            if (priority === 0) return parts[0]?.replace(/</g, ' ').trim() || "";
            if (priority === 1) return parts[1]?.replace(/</g, ' ').trim() || "";
        }

        // Fallback: Generic uppercase lines
        const potential = lines.filter(l => l.length > 3 && /^[A-Z\s]+$/.test(l.trim()) && !l.includes('<'));
        return potential[priority] ? potential[priority].trim() : "";
    };

    const handleConfirm = () => {
        // Here we would save to Global Store
        localStorage.setItem('passportData', JSON.stringify({ ...scannedData, plan }));
        router.push(`/${locale}/success`);
    };

    const handleRetry = () => {
        setScannedData(null);
        setIsScanning(false);
        setStatus("Esperando imagen...");
    };

    // --- RENDER: FORM (IF DATA EXISTS) ---
    if (scannedData) {
        const hasMissingData = !scannedData.passportNumber || !scannedData.surname;

        return (
            <div className="flex flex-col h-full bg-[#F0F2F5]">
                {/* Compact Output Container */}
                <div className="flex-1 overflow-y-auto px-4 py-6">

                    {/* Header Status */}
                    <div className="flex items-center gap-3 mb-6 bg-white p-4 rounded-xl shadow-sm border border-gray-100">
                        <div className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 ${hasMissingData ? 'bg-amber-100' : 'bg-green-100'}`}>
                            {hasMissingData ? (
                                <AlertTriangle className="w-5 h-5 text-amber-600" />
                            ) : (
                                <Check className="w-5 h-5 text-green-600" />
                            )}
                        </div>
                        <div>
                            <h2 className="text-base font-bold text-[#003366] leading-tight">
                                {hasMissingData ? "Datos Incompletos" : "Datos Extraídos"}
                            </h2>
                            <p className="text-xs text-gray-500">
                                {hasMissingData ? "Por favor corrija manualmente." : "Valide abajo y continúe."}
                            </p>
                        </div>
                    </div>

                    {/* Passport Preview & Form Grid */}
                    <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                        {/* Image Preview - Compact */}
                        {scannedData.photoUrl && (
                            <div className="w-full h-32 bg-gray-900 flex items-center justify-center relative overflow-hidden">
                                <img
                                    src={scannedData.photoUrl}
                                    alt="Passport"
                                    className="h-full object-contain opacity-90"
                                />
                                <div className="absolute top-2 right-2 bg-black/50 text-white text-[10px] px-2 py-0.5 rounded backdrop-blur-sm">
                                    Original
                                </div>
                            </div>
                        )}

                        {/* Fields */}
                        <div className="divide-y divide-gray-50">
                            {/* Name */}
                            <div className="p-3 flex flex-col gap-0.5">
                                <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Nombre Completo</span>
                                <input
                                    type="text"
                                    defaultValue={`${scannedData.givenNames || ''} ${scannedData.surname || ''}`}
                                    className="font-bold text-[#003366] bg-transparent border-none p-0 focus:ring-0 w-full text-sm"
                                    placeholder="Ingrese nombre..."
                                />
                            </div>

                            {/* Passport Number */}
                            <div className="p-3 flex flex-col gap-0.5 bg-gray-50/30">
                                <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">No. Pasaporte</span>
                                <input
                                    type="text"
                                    defaultValue={scannedData.passportNumber}
                                    className="font-mono font-bold text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm tracking-wide"
                                    placeholder="Ej: A12345678"
                                />
                            </div>

                            {/* Two Col Row */}
                            <div className="flex divide-x divide-gray-50">
                                <div className="p-3 flex-1 flex flex-col gap-0.5">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase">Nacimiento</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.dob}
                                        className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm"
                                    />
                                </div>
                                <div className="p-3 w-1/3 flex flex-col gap-0.5">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase text-right">Sexo</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.sex}
                                        className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm text-right"
                                    />
                                </div>
                            </div>

                            {/* Two Col Row */}
                            <div className="flex divide-x divide-gray-50">
                                <div className="p-3 flex-1 flex flex-col gap-0.5">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase">Vencimiento</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.expiry}
                                        className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm"
                                    />
                                </div>
                                <div className="p-3 w-1/3 flex flex-col gap-0.5">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase text-right">País</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.country}
                                        className="font-bold text-[#003366] bg-transparent border-none p-0 focus:ring-0 w-full text-sm text-right"
                                    />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Footer Actions */}
                <div className="p-4 bg-white border-t border-gray-100 shadow-[0_-4px_20px_rgb(0,0,0,0.05)]">
                    <button
                        onClick={handleConfirm}
                        className="w-full bg-[#003366] text-white h-12 rounded-lg font-bold shadow-lg active:scale-[0.98] transition-all flex items-center justify-center gap-2 mb-3 text-sm"
                    >
                        Confirmar y Continuar
                    </button>
                    <button
                        onClick={handleRetry}
                        className="w-full text-gray-500 h-8 text-xs font-semibold flex items-center justify-center gap-2 hover:text-[#003366]"
                    >
                        <RefreshCw size={12} /> Escanear de nuevo
                    </button>
                </div>
            </div>
        );
    }

    // --- RENDER: SCANNER UI (DEFAULT) ---
    return (
        <div className="flex flex-col h-full bg-[#F0F2F5]">
            <div className="flex flex-col items-center text-center h-full justify-center fade-enter px-6 relative">

                {/* Hidden Input */}
                <input
                    type="file"
                    accept="image/*"
                    capture="environment"
                    ref={fileInputRef}
                    className="hidden"
                    onChange={handleFileChange}
                />

                {/* Compact Brand Icon */}
                <div className="mb-6 relative">
                    <div className="w-16 h-16 rounded-2xl bg-white shadow-sm flex items-center justify-center border border-gray-100">
                        <ScanFace className={`w-8 h-8 text-[#003366] ${isScanning ? 'animate-pulse' : ''}`} strokeWidth={1.5} />
                    </div>
                    {!isScanning && (
                        <div className="absolute -bottom-2 -right-2 bg-[#003366] text-white p-1.5 rounded-lg shadow-md border-2 border-[#F0F2F5]">
                            <Lock size={10} strokeWidth={2.5} />
                        </div>
                    )}
                </div>

                <h2 className="text-xl font-bold text-[#003366] mb-2 tracking-tight">
                    {isScanning ? "Procesando Pasaporte..." : "Escanear Pasaporte"}
                </h2>
                <p className="text-sm text-gray-500 mb-8 max-w-[280px] leading-relaxed mx-auto">
                    {isScanning
                        ? status
                        : "Use su cámara para extraer datos automáticamente. Rápido y seguro."}
                </p>

                {/* Main Action */}
                <button
                    onClick={() => fileInputRef.current?.click()}
                    disabled={isScanning}
                    className="w-full max-w-xs bg-[#003366] text-white h-12 rounded-lg font-bold shadow-xl shadow-[#003366]/20 active:scale-[0.98] transition-all flex items-center justify-center gap-2 disabled:opacity-80 text-sm"
                >
                    {isScanning ? (
                        <>
                            <Loader2 className="w-4 h-4 animate-spin" />
                            <span>{status}</span>
                        </>
                    ) : (
                        <>
                            <Camera className="w-4 h-4" />
                            <span>Abrir Cámara</span>
                        </>
                    )}
                </button>

                {/* Footer formats */}
                {!isScanning && (
                    <div className="mt-8 flex flex-col gap-4">
                        <div className="flex items-center gap-1.5 justify-center text-[10px] uppercase font-bold text-gray-400 tracking-wider">
                            <Upload size={10} />
                            <span>JPG • PNG • HEIC</span>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
