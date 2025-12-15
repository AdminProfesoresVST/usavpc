"use client";

import React, { useState, useRef, useEffect } from "react";
import { createWorker } from "tesseract.js";
import {
    Camera,
    Upload,
    Loader2,
    Check,
    AlertTriangle,
    RefreshCw,
    ScanFace,
    Lock,
} from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";
import { useLocale } from "next-intl";

interface PassportData {
    rawText?: string;
    passportNumber?: string;
    surname?: string;
    givenNames?: string;
    dob?: string;
    expiry?: string;
    sex?: string;
    country?: string; // Issuing Country
    nationality?: string; // Citizenship
    personalIdNumber?: string; // Common in LatAm (Cédula, CURP)
    maritalStatus?: string; // Common in LatAm (Estado Civil)
    dateOfIssue?: string; // Not in MRZ
    authority?: string; // Not in MRZ
    placeOfBirth?: string; // Not in MRZ
    photoUrl?: string;
}

export default function ScanPage() {
    const router = useRouter();
    const locale = useLocale();
    const searchParams = useSearchParams();
    const plan = searchParams.get("plan");

    const [isScanning, setIsScanning] = useState(false);
    const [scannedData, setScannedData] = useState<PassportData | null>(null);
    const [status, setStatus] = useState("Esperando imagen...");

    const cameraInputRef = useRef<HTMLInputElement>(null);
    const uploadInputRef = useRef<HTMLInputElement>(null);

    const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
        if (!e.target.files || e.target.files.length === 0) return;

        const file = e.target.files[0];
        setIsScanning(true);
        setStatus("Inicializando IA...");

        try {
            const worker = await createWorker('eng');

            // 1. Pre-process Image for better OCR
            setStatus("Optimizando imagen...");
            const optimizedImageUrl = await preprocessImage(file);

            // 2. Recognize Text
            setStatus("Leyendo Pasaporte...");
            worker.reinitialize('eng');

            // Use optimized image for OCR
            const ret = await worker.recognize(optimizedImageUrl);

            setStatus("Extrayendo Datos...");
            // Use module-level function
            const extracted = parsePassportData(ret.data.text);
            const photoUrl = URL.createObjectURL(file); // Keep original for display

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
                        {/* Image Preview - WHITE Background as requested */}
                        {scannedData.photoUrl && (
                            <div className="w-full h-32 bg-white flex items-center justify-center relative overflow-hidden border-b border-gray-100">
                                <img
                                    src={scannedData.photoUrl}
                                    alt="Passport"
                                    className="h-full object-contain"
                                />
                                <div className="absolute top-2 right-2 bg-gray-100/80 text-gray-600 text-[10px] px-2 py-0.5 rounded backdrop-blur-sm border border-gray-200">
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
                                    placeholder="Nombre Combero"
                                />
                            </div>

                            {/* Passport Number & Nationality */}
                            <div className="flex divide-x divide-gray-50 bg-gray-50/30">
                                <div className="p-3 flex-1 flex flex-col gap-0.5">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">No. Pasaporte</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.passportNumber}
                                        className="font-mono font-bold text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm tracking-wide"
                                        placeholder="Número"
                                    />
                                </div>
                                <div className="p-3 w-1/3 flex flex-col gap-0.5 text-right">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Nacionalidad</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.nationality}
                                        className="font-bold text-[#003366] bg-transparent border-none p-0 focus:ring-0 w-full text-sm text-right"
                                        placeholder="---"
                                    />
                                </div>
                            </div>

                            {/* Personal ID (Cédula) & Marital Status - NEW LATAM FIELDS */}
                            <div className="flex divide-x divide-gray-50">
                                <div className="p-3 flex-1 flex flex-col gap-0.5">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Cédula / ID Personal</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.personalIdNumber}
                                        className="font-bold text-[#003366] bg-transparent border-none p-0 focus:ring-0 w-full text-sm"
                                        placeholder="---"
                                    />
                                </div>
                                <div className="p-3 w-1/3 flex flex-col gap-0.5 text-right">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Estado Civil</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.maritalStatus}
                                        className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm text-right"
                                        placeholder="---"
                                    />
                                </div>
                            </div>

                            {/* Dates Row 1 */}
                            <div className="flex divide-x divide-gray-50">
                                <div className="p-3 flex-1 flex flex-col gap-0.5">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase">Nacimiento (DOB)</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.dob}
                                        className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm"
                                        placeholder="YYYY-MM-DD"
                                    />
                                </div>
                                <div className="p-3 w-1/3 flex flex-col gap-0.5 text-right">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase">Sexo</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.sex}
                                        className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm text-right"
                                        placeholder="M/F"
                                    />
                                </div>
                            </div>

                            {/* Dates Row 2 */}
                            <div className="flex divide-x divide-gray-50">
                                <div className="p-3 flex-1 flex flex-col gap-0.5">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase">Emisión (Issue)</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.dateOfIssue}
                                        className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm"
                                        placeholder="YYYY-MM-DD"
                                    />
                                </div>
                                <div className="p-3 flex-1 flex flex-col gap-0.5 text-right">
                                    <span className="text-[10px] font-semibold text-gray-400 uppercase">Vencimiento</span>
                                    <input
                                        type="text"
                                        defaultValue={scannedData.expiry}
                                        className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm text-right"
                                        placeholder="YYYY-MM-DD"
                                    />
                                </div>
                            </div>

                            {/* Extra Info */}
                            <div className="p-3 flex flex-col gap-0.5">
                                <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Lugar de Nacimiento</span>
                                <input
                                    type="text"
                                    defaultValue={scannedData.placeOfBirth}
                                    className="font-medium text-[#1F2937] bg-transparent border-none p-0 focus:ring-0 w-full text-sm"
                                    placeholder="Ciudad, País"
                                />
                            </div>
                            <div className="p-3 flex flex-col gap-0.5 border-t border-gray-50">
                                <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">Autoridad (Authority)</span>
                                <input
                                    type="text"
                                    defaultValue={scannedData.authority}
                                    className="font-medium text-[#003366] bg-transparent border-none p-0 focus:ring-0 w-full text-sm"
                                    placeholder="Ej: Dept of State"
                                />
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

                {/* Hidden Inputs */}
                <input
                    type="file"
                    accept="image/*"
                    capture="environment"
                    ref={cameraInputRef}
                    className="hidden"
                    onChange={handleFileChange}
                />
                <input
                    type="file"
                    accept="image/*"
                    ref={uploadInputRef}
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
                        : "Elija cómo desea cargar la imagen de su pasaporte."}
                </p>

                {/* Actions */}
                <div className="flex flex-col gap-3 w-full max-w-xs transition-all">
                    {isScanning ? (
                        <div className="w-full bg-[#003366] text-white h-12 rounded-lg font-bold shadow-xl shadow-[#003366]/20 flex items-center justify-center gap-2 opacity-90 cursor-wait">
                            <Loader2 className="w-4 h-4 animate-spin" />
                            <span>{status}</span>
                        </div>
                    ) : (
                        <>
                            <button
                                onClick={() => cameraInputRef.current?.click()}
                                className="w-full bg-[#003366] text-white h-12 rounded-lg font-bold shadow-lg shadow-[#003366]/20 active:scale-[0.98] transition-all flex items-center justify-center gap-2 text-sm"
                            >
                                <Camera className="w-4 h-4" />
                                <span className="uppercase tracking-wide">Usar Cámara</span>
                            </button>

                            <button
                                onClick={() => uploadInputRef.current?.click()}
                                className="w-full bg-white text-[#003366] border border-gray-200 h-12 rounded-lg font-bold shadow-sm active:scale-[0.98] transition-all flex items-center justify-center gap-2 text-sm hover:bg-gray-50"
                            >
                                <Upload className="w-4 h-4" />
                                <span className="uppercase tracking-wide">Subir Archivo</span>
                            </button>
                        </>
                    )}
                </div>

                {/* Footer formats */}
                {!isScanning && (
                    <div className="mt-8 flex flex-col gap-4">
                        <div className="flex items-center gap-1.5 justify-center text-[10px] uppercase font-bold text-gray-400 tracking-wider">
                            <Check size={12} className="text-green-500" />
                            <span>JPG • PNG • HEIC</span>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}

// ----------------------------------------------------------------------
// HELPER FUNCTIONS (Outside Component to fix hoisting & scoping)
// ----------------------------------------------------------------------

function parsePassportData(text: string): PassportData {
    // Sanitize common OCR errors
    const cleanText = text.replace(/\$/g, 'S').replace(/\(/g, '<'); // '(' sometimes read as '<'

    const lines = cleanText.split('\n').map(l => l.trim()).filter(l => l.length > 0);
    // console.log("OCR Lines:", lines);

    let mrzLine2 = "";
    let mrzLine1 = "";

    // Find MRZ Lines
    for (const line of lines) {
        const cleanLine = line.replace(/\s/g, '').toUpperCase();
        // Line 1: P<DOM... or P<USA... 
        if (cleanLine.startsWith('P') && cleanLine.includes('<<') && cleanLine.length > 30) {
            mrzLine1 = cleanLine;
        }
        // Line 2: Number + DOB + Expiry + Digits
        if (cleanLine.length >= 30 && /[0-9]{6}/.test(cleanLine) && /<+/.test(cleanLine) && !cleanLine.startsWith('P')) {
            mrzLine2 = cleanLine;
        }
    }

    let passportNumber = "";
    let dob = "";
    let expiry = "";
    let sex = "";
    let country = "";
    let nationality = "";
    let personalIdNumber = "";
    let surname = "";
    let givenNames = "";

    // MRZ EXTRACTION
    if (mrzLine2 && mrzLine2.length >= 28) {
        passportNumber = mrzLine2.substring(0, 9).replace(/</g, '');
        nationality = mrzLine2.substring(10, 13).replace(/</g, '');

        const rawDob = mrzLine2.substring(13, 19);
        dob = formatDate(rawDob);

        sex = mrzLine2.substring(20, 21).replace(/</g, '');

        const rawExpiry = mrzLine2.substring(21, 27);
        expiry = formatDate(rawExpiry);

        // Optional Data (Chars 28-42)
        if (mrzLine2.length >= 42) {
            const optData = mrzLine2.substring(28, 42).replace(/</g, '');
            if (optData.length > 3) personalIdNumber = optData;
        }

        country = nationality;
    }

    if (mrzLine1) {
        const clean = mrzLine1.replace(/\s/g, '').toUpperCase();
        const content = clean.substring(5);
        const parts = content.split('<<');
        surname = parts[0]?.replace(/</g, ' ').trim() || "";
        givenNames = parts[1]?.replace(/</g, ' ').trim() || "";

        // CLEANING: Fix common "L" artifact prefix (e.g. "L VILLACAMPA")
        if (surname.match(/^[A-Z]\s+[A-Z]+$/)) {
            // If single letter followed by space and more letters, remove single letter
            surname = surname.replace(/^[A-Z]\s+/, '');
        }
        // Specifically "L"
        if (surname.startsWith("L ")) {
            surname = surname.substring(2);
        }
    }

    // VIZ EXTRACTION
    // 1. Issue Date: Allow spaces like 'ENE / JAN' + handle O/0 typos
    // Pattern: 09 ENE... or O9 ENE...
    const dateIssuePattern = /\b[0-9O]{2}\s+[A-Z]{3,4}\s*\/?[A-Z]{0,4}\s+[0-9O]{4}\b/gi;

    let dateOfIssue = "";

    // Scan specific lines first
    const issueLine = extractVIZField(lines, ["FECHA DE EXPEDICION", "DATE OF ISSUE", "EMISION"]);
    if (issueLine) {
        const match = issueLine.match(dateIssuePattern);
        if (match) dateOfIssue = parseSpanishDate(match[0]);
        else dateOfIssue = parseSpanishDate(issueLine);
    }

    // Fallback search
    if (!dateOfIssue) {
        const allDates = cleanText.match(dateIssuePattern);
        if (allDates && allDates.length > 0) {
            dateOfIssue = parseSpanishDate(allDates[0]);
        }
    }

    // 2. Authority
    let authority = extractVIZField(lines, ["AUTORIDAD", "AUTHORITY", "EXPEDIDO POR", "ISSUING AUTHORITY"]);

    // Fallback for RD ("SEDE CENTRAL")
    if (!authority && cleanText.toUpperCase().includes("SEDE CENTRAL")) {
        authority = "SEDE CENTRAL";
    }
    if (authority && authority.length < 3) authority = "";

    // 3. Place of Birth
    let placeOfBirth = extractVIZField(lines, ["LUGAR DE NACIMIENTO", "PLACE OF BIRTH", "NACIMIENTO"]);

    // Critical Fix: Block "SEXO" or "SEX" from being POB
    if (placeOfBirth.includes("SEX") || placeOfBirth.includes("FEM") || placeOfBirth.includes("MASC") || placeOfBirth.length < 3) {
        placeOfBirth = "";
    }

    // Heuristic: "SANTO DOMINGO" fallback (Looser check)
    if (!placeOfBirth) {
        if (cleanText.toUpperCase().includes("SANTO DOMINGO") || cleanText.toUpperCase().includes("SANTO DOM")) {
            placeOfBirth = "SANTO DOMINGO";
            if (cleanText.toUpperCase().includes("RD")) placeOfBirth += ", RD";
        }
    }

    // 4. Marital Status
    const maritalStatus = /SOLTERO|SINGLE/i.test(cleanText) ? "SOLTERO/A"
        : /CASADO|MARRIED/i.test(cleanText) ? "CASADO/A"
            : "";

    return {
        rawText: cleanText,
        passportNumber: passportNumber || "",
        surname: surname || extractNameFallback(lines, 0),
        givenNames: givenNames || extractNameFallback(lines, 1),
        dob: dob || "",
        expiry: expiry || "",
        sex: sex || "-",
        country: country || "USA",
        nationality: nationality || "USA",
        personalIdNumber: personalIdNumber,
        maritalStatus: maritalStatus,
        dateOfIssue: dateOfIssue,
        authority: authority,
        placeOfBirth: placeOfBirth
    };
}

function extractVIZField(lines: string[], keywords: string[]): string {
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].toUpperCase();
        if (keywords.some(k => line.includes(k))) {
            // Check Same Line first
            let value = line;
            keywords.forEach(k => value = value.replace(k, ''));

            // Remove keywords that are often near
            value = value.replace(/SEXO.*/, '').replace(/SEX.*/, '');
            value = value.replace(/[:\.\/]/g, '').trim();

            if (value.length > 2 && !value.includes("SEX")) return value;

            // If empty or bad, check Next Lines (Lookahead 2 lines)
            for (let offset = 1; offset <= 2; offset++) {
                if (lines[i + offset]) {
                    let nextVal = lines[i + offset].toUpperCase().replace(/[:\.\/]/g, '').trim();

                    // Skip if it looks like another label or noise
                    if (keywords.some(k => nextVal.includes(k))) continue;
                    if (nextVal.includes("SEXO") || nextVal.includes("FEM") || nextVal.includes("MASC")) continue;
                    if (nextVal.length < 3) continue;

                    return nextVal;
                }
            }
        }
    }
    return "";
}

function parseSpanishDate(raw: string): string {
    // Fix common OCR typos: O -> 0
    const clean = raw.replace(/O/g, '0').replace(/o/g, '0');

    const parts = clean.match(/(\d{2})\s+([A-Z]+).*\s+(\d{4})/i);
    if (!parts) return "";

    const day = parts[1];
    const monthRaw = parts[2].toUpperCase().substring(0, 3);
    const year = parts[3];

    const months: Record<string, string> = {
        'ENE': '01', 'JAN': '01', 'FEB': '02', 'MAR': '03',
        'ABR': '04', 'APR': '04', 'MAY': '05', 'JUN': '06',
        'JUL': '07', 'AGO': '08', 'AUG': '08', 'SEP': '09',
        'OCT': '10', 'NOV': '11', 'DIC': '12', 'DEC': '12'
    };

    const mm = months[monthRaw] || "00";
    if (mm === "00") return "";

    return `${year}-${mm}-${day}`;
}

function formatDate(yymmdd: string): string {
    if (!yymmdd || yymmdd.length !== 6 || isNaN(Number(yymmdd))) return "";
    const yy = yymmdd.substring(0, 2);
    const mm = yymmdd.substring(2, 4);
    const dd = yymmdd.substring(4, 6);

    const currentYear = new Date().getFullYear() % 100;
    const century = Number(yy) > currentYear + 10 ? "19" : "20";

    return `${century}${yy}-${mm}-${dd}`;
}

function extractNameFallback(lines: string[], priority: number): string {
    const potential = lines.filter(l => l.length > 3 && /^[A-Z\s]+$/.test(l.trim()) && !l.includes('<'));
    return potential[priority] ? potential[priority].trim() : "";
}

// IMAGE PRE-PROCESSING ENGINE
async function preprocessImage(file: File): Promise<string> {
    return new Promise((resolve, reject) => {
        const img = new Image();
        const url = URL.createObjectURL(file);

        img.onload = () => {
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            if (!ctx) {
                resolve(url); // Fallback to original
                return;
            }

            // Resize if too huge (cap at 2000px width to speed up)
            let width = img.width;
            let height = img.height;
            if (width > 2000) {
                height = Math.round(height * (2000 / width));
                width = 2000;
            }

            canvas.width = width;
            canvas.height = height;

            ctx.drawImage(img, 0, 0, width, height);

            // Pixel Manipulation (Binarization + Contrast)
            const imageData = ctx.getImageData(0, 0, width, height);
            const data = imageData.data;

            // Threshold for binarization (128 is standard mid-point)
            // We can try adaptive or simple high-contrast greyscale
            for (let i = 0; i < data.length; i += 4) {
                // Grayscale (Luminance)
                const gray = 0.299 * data[i] + 0.587 * data[i + 1] + 0.114 * data[i + 2];

                // Binarization (Black or White)
                // Threshold 150 helps remove light patterns (security background)
                const newValue = gray > 145 ? 255 : 0;

                data[i] = newValue;     // R
                data[i + 1] = newValue; // G
                data[i + 2] = newValue; // B
                // Alpha (data[i+3]) remains 255
            }

            ctx.putImageData(imageData, 0, 0);

            // Return high-quality JPEG
            const dataUrl = canvas.toDataURL('image/jpeg', 0.9);
            resolve(dataUrl);

            // Cleanup
            URL.revokeObjectURL(url);
        };

        img.onerror = (err) => {
            console.error("Image load error", err);
            resolve(url);
        };

        img.src = url;
    });
}
