"use client";

import { PDFDownloadLink } from "@react-pdf/renderer";
import { InterviewGuidePDF } from "./InterviewGuidePDF";
import { Button } from "@/components/ui/button";
import { Download, Loader2 } from "lucide-react";
import { useEffect, useState } from "react";

export function InterviewGuideDownloadButton() {
    const [isClient, setIsClient] = useState(false);

    useEffect(() => {
        setIsClient(true);
    }, []);

    if (!isClient) {
        return (
            <Button variant="outline" disabled className="w-full sm:w-auto gap-2">
                <Loader2 className="w-4 h-4 animate-spin" />
                Cargando Guía...
            </Button>
        );
    }

    return (
        <PDFDownloadLink
            document={<InterviewGuidePDF />}
            fileName="Guia_Entrevista_Consular_USAVPC.pdf"
            className="w-full sm:w-auto"
        >
            {({ blob, url, loading, error }) => (
                <Button
                    variant="outline"
                    className="w-full sm:w-auto gap-2 border-trust-navy text-trust-navy hover:bg-trust-navy hover:text-white transition-colors"
                    disabled={loading}
                >
                    {loading ? (
                        <Loader2 className="w-4 h-4 animate-spin" />
                    ) : (
                        <Download className="w-4 h-4" />
                    )}
                    {loading ? "Generando PDF..." : "Descargar Guía de Entrevista (Gratis)"}
                </Button>
            )}
        </PDFDownloadLink>
    );
}
