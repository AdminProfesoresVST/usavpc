"use client";

import { PDFDownloadLink } from "@react-pdf/renderer";
import { StrategyReportPDF } from "./StrategyReport";
import { Button } from "@/components/ui/button";
import { FileDown } from "lucide-react";
import { useTranslations } from 'next-intl';

export function DownloadReportButton() {
    const t = useTranslations('Common');
    const dummyData = {
        applicantName: "John Doe",
        nationality: "Mexico",
        visaScore: 85,
        riskFactors: ["First time applicant", "Young single male"],
        strengths: ["Stable employment", "Previous travel history"],
        interviewGuide: "Focus on your strong ties to your home country. Bring proof of property ownership and your employment contract. Be concise and truthful.",
    };

    return (
        <div className="mt-4 flex justify-center">
            <PDFDownloadLink
                document={<StrategyReportPDF data={dummyData} />}
                fileName="VisaStrategyReport.pdf"
            >
                {({ blob, url, loading, error }) => (
                    <Button disabled={loading} className="gap-2">
                        <FileDown size={16} />
                        {loading ? t('generating') : t('downloadReport')}
                    </Button>
                )}
            </PDFDownloadLink>
        </div>
    );
}
