"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "sonner";
import { createKnowledge } from "@/app/actions/create-knowledge";
import { BookOpen, Plus } from "lucide-react";

export function KnowledgeBase() {
    const [isOpen, setIsOpen] = useState(false);
    const [content, setContent] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleSubmit = async () => {
        if (!content.trim()) return;
        setIsSubmitting(true);
        try {
            await createKnowledge(content);
            toast.success("Knowledge added to Brain!");
            setContent("");
            setIsOpen(false);
        } catch (error) {
            toast.error("Failed to learn.");
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="fixed bottom-6 left-6 z-50">
            {!isOpen && (
                <Button
                    onClick={() => setIsOpen(true)}
                    className="rounded-full h-12 w-12 shadow-lg bg-indigo-600 hover:bg-indigo-700"
                >
                    <BookOpen className="h-6 w-6" />
                </Button>
            )}

            {isOpen && (
                <div className="bg-white p-4 rounded-lg shadow-xl border border-gray-200 w-80 animate-in slide-in-from-bottom-5">
                    <div className="flex justify-between items-center mb-3">
                        <h3 className="font-semibold text-sm flex items-center gap-2">
                            <BookOpen size={16} className="text-indigo-600" />
                            Teach the AI
                        </h3>
                        <Button variant="ghost" size="sm" className="h-6 w-6 p-0" onClick={() => setIsOpen(false)}>
                            <Plus size={16} className="rotate-45" />
                        </Button>
                    </div>
                    <Textarea
                        placeholder="e.g., 'Translate 'Jefe de Bodega' as 'Warehouse Manager'..."
                        className="text-sm mb-3 min-h-[100px]"
                        value={content}
                        onChange={(e) => setContent(e.target.value)}
                    />
                    <Button
                        className="w-full bg-indigo-600 hover:bg-indigo-700"
                        size="sm"
                        onClick={handleSubmit}
                        disabled={isSubmitting}
                    >
                        {isSubmitting ? "Learning..." : "Save Rule"}
                    </Button>
                </div>
            )}
        </div>
    );
}
