"use client";

import { ApplicationStatus } from "@/types/ds160";
import { Button } from "@/components/ui/button";
import { X, Check, AlertTriangle, Copy } from "lucide-react";
import { ExtensionDataButton } from "@/components/dashboard/ExtensionDataButton";
import { DownloadReportButton } from "@/components/pdf/DownloadButton";

import { toast } from "sonner";

interface ApplicationDetailsProps {
    application: any;
    onClose: () => void;
    onStatusUpdate: (id: string, status: ApplicationStatus) => void;
}

export function ApplicationDetails({ application, onClose, onStatusUpdate }: ApplicationDetailsProps) {
    const copyToClipboard = () => {
        navigator.clipboard.writeText(JSON.stringify(application.ds160_payload, null, 2));
        toast.success("Payload copied to clipboard");
    };

    return (
        <div className="w-[400px] border-l border-gray-200 bg-white h-full flex flex-col shadow-xl absolute right-0 top-0 bottom-0 z-50">
            <div className="p-4 border-b border-gray-200 flex justify-between items-center bg-gray-50">
                <div>
                    <h3 className="font-bold text-lg">Application Details</h3>
                    <p className="text-xs text-gray-500 font-mono">{application.id}</p>
                </div>
                <Button variant="ghost" size="icon" onClick={onClose}>
                    <X size={18} />
                </Button>
            </div>

            <div className="flex-1 overflow-y-auto p-4">
                <div className="space-y-6">
                    {/* Status Actions */}
                    <div className="grid grid-cols-2 gap-2">
                        <Button
                            variant="outline"
                            className="bg-green-50 text-green-700 border-green-200 hover:bg-green-100"
                            onClick={() => onStatusUpdate(application.id, 'completed_delivered')}
                        >
                            <Check size={16} className="mr-2" /> Mark Completed
                        </Button>
                        <Button
                            variant="outline"
                            className="bg-red-50 text-red-700 border-red-200 hover:bg-red-100"
                            onClick={() => onStatusUpdate(application.id, 'on_hold_client_action')}
                        >
                            <AlertTriangle size={16} className="mr-2" /> Hold / Reject
                        </Button>
                    </div>

                    {/* Admin Tools */}
                    <div className="space-y-2">
                        <h4 className="font-semibold text-sm uppercase tracking-wider text-gray-500">Filing Tools</h4>
                        <div className="bg-gray-50 p-3 rounded-md space-y-2">
                            <ExtensionDataButton data={application} />
                            <DownloadReportButton data={application} />
                        </div>
                    </div>

                    {/* Personal Info Summary */}
                    <div className="space-y-2">
                        <h4 className="font-semibold text-sm uppercase tracking-wider text-gray-500">Personal Info</h4>
                        <div className="bg-gray-50 p-3 rounded-md text-sm space-y-1">
                            <p><span className="font-medium">Marital Status:</span> {application.ds160_payload?.ds160_data?.personal?.marital_status || 'N/A'}</p>
                            <p><span className="font-medium">Spouse:</span> {application.ds160_payload?.ds160_data?.personal?.spouse || 'N/A'}</p>
                        </div>
                    </div>

                    {/* Travel Info Summary */}
                    <div className="space-y-2">
                        <h4 className="font-semibold text-sm uppercase tracking-wider text-gray-500">Travel Info</h4>
                        <div className="bg-gray-50 p-3 rounded-md text-sm space-y-1">
                            <p><span className="font-medium">Purpose:</span> {application.ds160_payload?.ds160_data?.travel?.purpose_code || 'N/A'}</p>
                            <p><span className="font-medium">Payer:</span> {application.ds160_payload?.ds160_data?.travel?.paying_entity || 'N/A'}</p>
                        </div>
                    </div>

                    {/* JSON Payload Viewer */}
                    <div className="space-y-2">
                        <div className="flex justify-between items-center">
                            <h4 className="font-semibold text-sm uppercase tracking-wider text-gray-500">Raw Payload</h4>
                            <Button variant="ghost" size="sm" className="h-6 text-xs" onClick={copyToClipboard}>
                                <Copy size={12} className="mr-1" /> Copy
                            </Button>
                        </div>
                        <pre className="bg-gray-900 text-gray-100 p-3 rounded-md text-[10px] overflow-x-auto font-mono max-h-[300px]">
                            {JSON.stringify(application.ds160_payload, null, 2)}
                        </pre>
                    </div>
                </div>
            </div>
        </div>
    );
}
