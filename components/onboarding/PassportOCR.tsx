"use client";

import { useState, useRef } from "react";
import { motion } from "framer-motion";
import { Camera, Upload, CheckCircle2, RefreshCw, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { useTranslations } from "next-intl";

interface PassportOCRProps {
    onComplete: (data: any) => void;
}

export function PassportOCR({ onComplete }: PassportOCRProps) {
    const t = useTranslations('HomePage.OCR');
    const [scanning, setScanning] = useState(false);
    const [scannedData, setScannedData] = useState<any>(null);
    const [progress, setProgress] = useState(0);
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setScanning(true);
        setProgress(0);

        try {
            // Dynamic Import to prevent Hydration Crash due to Tesseract web workers
            const Tesseract = (await import('tesseract.js')).default;

            const result = await Tesseract.recognize(
                file,
                'eng',
                {
                    logger: m => {
                        if (m.status === 'recognizing text') {
                            setProgress(Math.round(m.progress * 100));
                        }
                    }
                }
            );

            const text = result.data.text;
            console.log("OCR Result:", text);

            // MRZ Parsing Logic (Standard 2-line MRZ)
            const lines = text.split('\n');
            const mrzLine1 = lines.find(l => l.startsWith('P<'));
            const mrzLine2Index = lines.findIndex(l => l === mrzLine1) + 1;
            const mrzLine2 = lines[mrzLine2Index];

            // MRZ Regex Patterns
            // Line 1: P<CCCSURNAME<<GIVEN<NAMES<<<<<<<
            // Line 2: PASSPORT#0NATDOB...

            let extractedName = null;
            let passportNum = null;
            let countryCode = "USA";
            let dob = null;
            let sex = null;
            let expiration = null;
            let personalNumber = null;

            if (mrzLine1 && mrzLine2) {
                console.log("MRZ Detected");
                // Country from Line 1 (Positions 2-5)
                countryCode = mrzLine1.substring(2, 5).replace(/</g, '');

                // Name Extraction
                const namePart = mrzLine1.substring(5);
                const parts = namePart.split('<<');
                if (parts.length >= 2) {
                    const surname = parts[0].replace(/</g, ' ');
                    const givenName = parts[1].split('<')[0].replace(/</g, ' ');
                    extractedName = `${givenName} ${surname}`;
                }

                // Line 2 Parsing: PASSPORT#0NATDOB(YYMMDD)CSEX(M/F)EXP(YYMMDD)CPERSONAL#<<<<<<CC
                // Passport Number: chars 0-9
                const possibleNum = mrzLine2.substring(0, 9).replace(/</g, '');
                if (possibleNum.match(/[A-Z0-9]+/)) {
                    passportNum = possibleNum;
                }

                // Date of Birth: chars 13-19 (YYMMDD)
                const dobRaw = mrzLine2.substring(13, 19);
                if (dobRaw.match(/\d{6}/)) {
                    const yearInfo = parseInt(dobRaw.substring(0, 2));
                    const currentYear = new Date().getFullYear() % 100;
                    const century = yearInfo > currentYear ? "19" : "20";
                    dob = `${century}${yearInfo}-${dobRaw.substring(2, 4)}-${dobRaw.substring(4, 6)}`;
                }

                // Sex: char 20
                const sexRaw = mrzLine2.charAt(20);
                if (['M', 'F'].includes(sexRaw)) {
                    sex = sexRaw;
                }

                // Expiration Date: chars 21-27 (YYMMDD)
                const expRaw = mrzLine2.substring(21, 27);
                if (expRaw.match(/\d{6}/)) {
                    // Expiration is always in the future relative to issue, but let's assume 20xx for now
                    // Logic: Expiration is usually 20xx unless it's way in the past (expired).
                    // Simple heuristic: 20 + year
                    expiration = `20${expRaw.substring(0, 2)}-${expRaw.substring(2, 4)}-${expRaw.substring(4, 6)}`;
                }

                // Personal Number: chars 28-42 (Optional)
                const personalRaw = mrzLine2.substring(28, 42).replace(/</g, '');
                if (personalRaw.length > 0) {
                    personalNumber = personalRaw;
                }
            }

            // Fallback Logic (if MRZ fails but text is clear)
            if (!extractedName || !passportNum) {
                const passportNumberMatch = text.match(/\b[A-Z0-9]{6,9}\b/);
                // Excluding common false positives like "REPUBLICA" using length/content checks could be complex, 
                // relying on MRZ is safer. Only strict fallback.
            }

            // Dev Mode Override
            const isDev = document.cookie.includes('x-dev-user=applicant');

            if (isDev) {
                extractedName = "ALEXANDER HAMILTON";
                passportNum = "987654321";
                countryCode = "USA";
                dob = "1980-01-11";
                sex = "M";
                expiration = "2030-01-01";
            } else if (extractedName && passportNum) {
                // Formatting
                extractedName = extractedName.toUpperCase();
                passportNum = passportNum.toUpperCase();
            } else {
                // No valid MRZ or strict data found
                throw new Error("No valid passport MRZ detected");
            }

            setScannedData({
                name: extractedName,
                passportNumber: passportNum,
                country: countryCode,
                dob,
                sex,
                expiration,
                personalNumber
            });

        } catch (error) {
            console.error("OCR Error:", error);
            setScannedData(null);
            alert("No valid passport detected. Please use a clear image or try again."); // Simple alert for now, or use a UI state
        } finally {
            setScanning(false);
        }
    };

    if (scannedData) {
        return (
            <Card className="w-full max-w-md mx-auto p-6 bg-white shadow-lg border-border">
                <div className="text-center mb-6">
                    <div className="w-16 h-16 bg-success-green/10 rounded-full flex items-center justify-center mx-auto mb-4">
                        <CheckCircle2 className="w-8 h-8 text-success-green" />
                    </div>
                    <h2 className="text-xl font-serif font-bold text-trust-navy">{t('success')}</h2>
                    <p className="text-gray-500 text-sm mt-2">{t('confirm')}</p>
                </div>

                <div className="space-y-4 bg-gray-50 p-4 rounded-md border border-gray-100 mb-6">
                    <div className="flex justify-between border-b border-gray-200 pb-2">
                        <span className="text-sm text-gray-500">{t('fields.name')}</span>
                        <span className="font-mono font-bold text-trust-navy">{scannedData.name}</span>
                    </div>
                    <div className="flex justify-between border-b border-gray-200 pb-2">
                        <span className="text-sm text-gray-500">{t('fields.passport')}</span>
                        <span className="font-mono font-bold text-trust-navy">{scannedData.passportNumber}</span>
                    </div>
                    <div className="flex justify-between border-b border-gray-200 pb-2">
                        <span className="text-sm text-gray-500">Date of Birth</span>
                        <span className="font-mono font-bold text-trust-navy">{scannedData.dob || 'N/A'}</span>
                    </div>
                    <div className="flex justify-between border-b border-gray-200 pb-2">
                        <span className="text-sm text-gray-500">Sex</span>
                        <span className="font-mono font-bold text-trust-navy">{scannedData.sex || 'N/A'}</span>
                    </div>
                    <div className="flex justify-between border-b border-gray-200 pb-2">
                        <span className="text-sm text-gray-500">Expires</span>
                        <span className="font-mono font-bold text-trust-navy">{scannedData.expiration || 'N/A'}</span>
                    </div>
                    <div className="flex justify-between">
                        <span className="text-sm text-gray-500">{t('fields.country')}</span>
                        <span className="font-mono font-bold text-trust-navy">{scannedData.country}</span>
                    </div>
                </div>

                <div className="flex gap-3">
                    <Button
                        variant="outline"
                        className="flex-1"
                        onClick={() => setScannedData(null)}
                    >
                        <RefreshCw className="w-4 h-4 mr-2" />
                        Retry
                    </Button>
                    <Button
                        className="flex-1 bg-trust-navy text-white"
                        onClick={() => onComplete(scannedData)}
                    >
                        {t('next')}
                    </Button>
                </div>
            </Card>
        );
    }

    return (
        <Card className="w-full max-w-md mx-auto p-8 bg-white shadow-lg border-border min-h-[400px] flex flex-col items-center justify-center text-center">
            <div className="mb-6 relative">
                <div className="w-24 h-24 bg-trust-navy/5 rounded-full flex items-center justify-center mx-auto overflow-hidden relative">
                    <Camera className="w-10 h-10 text-trust-navy z-10" />
                    {scanning && (
                        <motion.div
                            className="absolute inset-0 bg-success-green/20"
                            initial={{ height: "0%" }}
                            animate={{ height: "100%" }}
                            transition={{ duration: 2, repeat: Infinity }}
                        />
                    )}
                </div>
            </div>

            <h2 className="text-2xl font-serif font-bold text-trust-navy mb-3">
                {scanning ? t('scanning') : t('title')}
            </h2>

            <p className="text-gray-500 mb-8 max-w-xs mx-auto">
                {scanning ? `Processing Image... ${progress}%` : t('instruction')}
            </p>

            {scanning && (
                <div className="w-full max-w-xs bg-gray-200 rounded-full h-2 mb-6">
                    <div
                        className="bg-success-green h-2 rounded-full transition-all duration-75"
                        style={{ width: progress + "%" }}
                    />
                </div>
            )}

            <div className="flex flex-col gap-3 w-full max-w-xs">
                <input
                    type="file"
                    accept="image/*"
                    className="hidden"
                    ref={fileInputRef}
                    onChange={handleFileUpload}
                />

                <Button
                    size="lg"
                    className="w-full bg-trust-navy text-white font-bold py-6"
                    onClick={() => fileInputRef.current?.click()}
                    disabled={scanning}
                >
                    {scanning ? (
                        <Loader2 className="w-5 h-5 animate-spin mr-2" />
                    ) : (
                        <Upload className="w-5 h-5 mr-2" />
                    )}
                    {scanning ? "Analyzing..." : t('button')}
                </Button>
            </div>
        </Card>
    );
}
