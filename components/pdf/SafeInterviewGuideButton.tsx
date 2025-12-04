"use client";

import dynamic from "next/dynamic";
import { Button } from "@/components/ui/button";
import { Loader2 } from "lucide-react";

const InterviewGuideDownloadButton = dynamic(
    () => import("./InterviewGuideDownloadButton").then((mod) => mod.InterviewGuideDownloadButton),
    {
        ssr: false,
        loading: () => (
            <Button variant="outline" disabled className="w-full sm:w-auto gap-2">
                <Loader2 className="w-4 h-4 animate-spin" />
                Cargando...
            </Button>
        )
    }
);

export function SafeInterviewGuideButton() {
    return <InterviewGuideDownloadButton />;
}
