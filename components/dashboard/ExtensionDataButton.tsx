"use client";

import { Button } from "@/components/ui/button";
import { Copy, Check } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

interface ExtensionDataButtonProps {
    data: any;
}

export function ExtensionDataButton({ data }: ExtensionDataButtonProps) {
    const [copied, setCopied] = useState(false);

    const handleCopy = () => {
        // Map application data to extension format
        // Assuming form_data contains the relevant fields or we map from root
        const extensionData = {
            surname: data.form_data?.lastName || data.last_name || "",
            givenName: data.form_data?.firstName || data.first_name || "",
            fullNameNative: `${data.form_data?.firstName || ""} ${data.form_data?.lastName || ""}`.trim(),
            passportNumber: data.form_data?.passportNumber || "",
            // Add more fields as needed based on DS-160 requirements
        };

        const jsonString = JSON.stringify(extensionData, null, 2);

        navigator.clipboard.writeText(jsonString).then(() => {
            setCopied(true);
            toast.success("Data copied! Paste it into the USVPC Extension.");
            setTimeout(() => setCopied(false), 2000);
        });
    };

    return (
        <div className="mt-4 p-4 bg-blue-50 border border-blue-100 rounded-lg">
            <h3 className="text-sm font-semibold text-blue-900 mb-2">
                Chrome Extension Integration
            </h3>
            <p className="text-xs text-blue-700 mb-3">
                Copy your data here and paste it into the USVPC Chrome Extension to autofill your DS-160 form.
            </p>
            <Button
                onClick={handleCopy}
                variant="outline"
                className="w-full border-blue-200 text-blue-700 hover:bg-blue-100 hover:text-blue-800"
            >
                {copied ? (
                    <>
                        <Check className="w-4 h-4 mr-2" />
                        Copied to Clipboard
                    </>
                ) : (
                    <>
                        <Copy className="w-4 h-4 mr-2" />
                        Copy Data for Extension
                    </>
                )}
            </Button>
        </div>
    );
}
