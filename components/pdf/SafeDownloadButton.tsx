"use client";
import dynamic from "next/dynamic";

const DownloadReportButton = dynamic(
    () => import("./DownloadButton").then((mod) => mod.DownloadReportButton),
    { ssr: false }
);

export function SafeDownloadButton({ data }: { data: any }) {
    return <DownloadReportButton data={data} />;
}
