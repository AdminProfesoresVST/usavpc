import { useState, useEffect } from "react";
import { PDFDownloadLink } from "@react-pdf/renderer";
import { StrategyReportDocument } from "./StrategyReportDocument";
import { DS160Document } from "./DS160Document";
import { Button } from "@/components/ui/button";
import { FileDown } from "lucide-react";
import { useTranslations } from 'next-intl';

export function DownloadReportButton({ data }: { data: any }) {
    const t = useTranslations('Common');
    const [isClient, setIsClient] = useState(false);

    useEffect(() => {
        setIsClient(true);
    }, []);

    if (!isClient) {
        return null;
    }

    // Determine which document to download
    // If it's a Strategy Audit (has_strategy_check) but NOT full service (status != 'completed_delivered' maybe?), show Strategy Report.
    // Or if the user wants the DS-160, we might need a separate button.
    // For the Dashboard "Strategy Review" card, we want the Strategy Report.

    const isStrategyReportAvailable = data?.has_strategy_check;
    const isDS160Available = data?.status === 'completed_delivered';

    return (
        <div className="mt-4 flex flex-col gap-2 justify-center items-center">
            {isStrategyReportAvailable && (
                <PDFDownloadLink
                    document={<StrategyReportDocument data={data} />}
                    fileName={`VisaStrategy_${(data?.ds160_payload?.ds160_data?.personal?.surnames || 'Applicant').replace(/\s+/g, '_')}.pdf`}
                >
                    {({ blob, url, loading, error }) => (
                        <Button disabled={loading} className="gap-2 w-full">
                            <FileDown size={16} />
                            {loading ? t('generating') : "Download Strategy Report"}
                        </Button>
                    )}
                </PDFDownloadLink>
            )}

            {isDS160Available && (
                <PDFDownloadLink
                    document={<DS160Document data={data?.ds160_payload} />}
                    fileName={`DS160_Application.pdf`}
                >
                    {({ blob, url, loading, error }) => (
                        <Button disabled={loading} variant="outline" className="gap-2 w-full">
                            <FileDown size={16} />
                            {loading ? t('generating') : "Download Official DS-160"}
                        </Button>
                    )}
                </PDFDownloadLink>
            )}
        </div>
    );
}
