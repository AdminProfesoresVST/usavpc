"use client";

import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { updateStatus } from "@/app/actions/update-status";
import { toast } from "sonner";
import { useState } from "react";

interface StatusSelectProps {
    applicationId: string;
    currentStatus: string;
}

export function StatusSelect({ applicationId, currentStatus }: StatusSelectProps) {
    const [status, setStatus] = useState(currentStatus);
    const [loading, setLoading] = useState(false);

    const handleValueChange = async (value: string) => {
        setLoading(true);
        try {
            await updateStatus(applicationId, value);
            setStatus(value);
            toast.success(`Status updated to ${value}`);
        } catch (error) {
            toast.error("Failed to update status");
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <Select value={status} onValueChange={handleValueChange} disabled={loading}>
            <SelectTrigger className="w-[140px]">
                <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
                <SelectItem value="pending">Pending</SelectItem>
                <SelectItem value="paid">Paid</SelectItem>
                <SelectItem value="validated">Validated</SelectItem>
                <SelectItem value="queue">In Queue</SelectItem>
                <SelectItem value="ready">Ready</SelectItem>
                <SelectItem value="rejected">Rejected</SelectItem>
            </SelectContent>
        </Select>
    );
}
