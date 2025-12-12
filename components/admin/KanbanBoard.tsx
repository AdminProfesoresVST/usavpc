"use client";

import { useState } from "react";
import { ApplicationStatus, DS160Payload } from "@/types/ds160";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { MoreHorizontal, Eye, ArrowRight, AlertCircle } from "lucide-react";
import { updateStatus } from "@/app/actions/update-status";
import { toast } from "sonner";
import { ApplicationDetails } from "./ApplicationDetails";

interface Application {
    id: string;
    user_id: string;
    status: ApplicationStatus;
    created_at: string;
    ds160_payload: DS160Payload;
    profiles?: {
        email: string;
        first_name?: string;
        last_name?: string;
    };
}

interface KanbanBoardProps {
    applications: Application[];
}

const COLUMNS: { id: ApplicationStatus; label: string; color: string }[] = [
    { id: 'draft', label: 'Draft / New', color: 'bg-gray-100 text-gray-800' },
    { id: 'paid_pending_review', label: 'Paid (Pending)', color: 'bg-yellow-100 text-yellow-800' },
    { id: 'in_review_human', label: 'In Review', color: 'bg-blue-100 text-blue-800' },
    { id: 'completed_delivered', label: 'Completed', color: 'bg-green-100 text-green-800' },
];

export function KanbanBoard({ applications: initialApps }: KanbanBoardProps) {
    const [applications, setApplications] = useState(initialApps);
    const [selectedApp, setSelectedApp] = useState<Application | null>(null);

    const handleStatusUpdate = async (appId: string, newStatus: ApplicationStatus) => {
        // Optimistic update
        setApplications(prev => prev.map(app =>
            app.id === appId ? { ...app, status: newStatus } : app
        ));

        // Also update selected app if it's the one being updated
        if (selectedApp && selectedApp.id === appId) {
            setSelectedApp(prev => prev ? { ...prev, status: newStatus } : null);
        }

        try {
            const result = await updateStatus(appId, newStatus);
            if (!result.success) throw new Error("Failed to update");
            toast.success(`Moved to ${newStatus}`);
        } catch (error) {
            toast.error("Failed to update status");
            // Revert
            setApplications(initialApps);
        }
    };

    return (
        <div className="relative h-full">
            <div className="flex h-[calc(100vh-200px)] gap-4 overflow-x-auto pb-4 pr-[420px]">
                {COLUMNS.map(col => (
                    <div key={col.id} className="flex-shrink-0 w-80 flex flex-col bg-gray-50/50 rounded-lg border border-gray-200">
                        <div className={`p-3 border-b border-gray-200 flex justify-between items-center ${col.color} bg-opacity-20 rounded-t-lg`}>
                            <h3 className="font-bold text-sm uppercase tracking-wider">{col.label}</h3>
                            <Badge variant="secondary" className="bg-white/50">
                                {applications.filter(a => a.status === col.id).length}
                            </Badge>
                        </div>

                        <div className="flex-1 overflow-y-auto p-2 space-y-2">
                            {applications
                                .filter(app => app.status === col.id)
                                .map(app => (
                                    <Card
                                        key={app.id}
                                        className={`p-3 hover:shadow-md transition-shadow cursor-pointer bg-white group ${selectedApp?.id === app.id ? 'ring-2 ring-primary' : ''}`}
                                        onClick={() => setSelectedApp(app)}
                                    >
                                        <div className="flex justify-between items-start mb-2">
                                            <div className="text-xs font-mono text-gray-500 truncate max-w-[150px]">
                                                {app.id.split('-')[0]}...
                                            </div>
                                            {app.ds160_payload?.ds160_data?.personal?.marital_status && (
                                                <Badge variant="outline" className="text-[10px] h-5">
                                                    {app.ds160_payload.ds160_data.personal.marital_status}
                                                </Badge>
                                            )}
                                        </div>

                                        <div className="mb-3">
                                            <p className="font-semibold text-sm text-gray-900">
                                                {app.profiles?.email || "Unknown User"}
                                            </p>
                                            <p className="text-xs text-gray-500">
                                                {new Date(app.created_at).toLocaleDateString()}
                                            </p>
                                        </div>

                                        <div className="flex justify-between items-center opacity-0 group-hover:opacity-100 transition-opacity">
                                            <Button
                                                size="sm"
                                                variant="ghost"
                                                className="h-6 w-6 p-0"
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    setSelectedApp(app);
                                                }}
                                            >
                                                <Eye size={14} />
                                            </Button>

                                            <div className="flex gap-1">
                                                {col.id !== 'completed_delivered' && (
                                                    <Button
                                                        size="sm"
                                                        variant="outline"
                                                        className="h-6 text-[10px] px-2"
                                                        onClick={(e) => {
                                                            e.stopPropagation();
                                                            const nextStatus: ApplicationStatus =
                                                                col.id === 'draft' ? 'paid_pending_review' :
                                                                    col.id === 'paid_pending_review' ? 'in_review_human' :
                                                                        'completed_delivered';
                                                            handleStatusUpdate(app.id, nextStatus);
                                                        }}
                                                    >
                                                        Next <ArrowRight size={10} className="ml-1" />
                                                    </Button>
                                                )}
                                            </div>
                                        </div>
                                    </Card>
                                ))}
                        </div>
                    </div>
                ))}
            </div>

            {/* Split Screen Details Panel */}
            {selectedApp && (
                <ApplicationDetails
                    application={selectedApp}
                    onClose={() => setSelectedApp(null)}
                    onStatusUpdate={handleStatusUpdate}
                />
            )}
        </div>
    );
}
