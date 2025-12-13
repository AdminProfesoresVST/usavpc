"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Edit2, CheckCircle, AlertCircle } from "lucide-react";
import { resetDS160Field } from "@/app/actions/ds160";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { Spinner } from "@/components/ui/spinner"; // Assuming we have this, or fallback

export function DS160Review({ payload, schema }: { payload: any, schema: any[] }) {
    const router = useRouter();
    const [loadingField, setLoadingField] = useState<string | null>(null);

    // Group schema by section
    const sections: Record<string, any[]> = {};
    schema.forEach(item => {
        if (!sections[item.section]) sections[item.section] = [];
        sections[item.section].push(item);
    });

    const getDeepValue = (obj: any, path: string) => {
        return path.split('.').reduce((acc, part) => acc && acc[part], obj);
    };

    const handleEdit = async (fieldKey: string) => {
        try {
            setLoadingField(fieldKey);
            await resetDS160Field(fieldKey);
            toast.success("Respuesta borrada. Redirigiendo al chat...");
            router.push(`/assessment?focus=${fieldKey}`); // Optional query param for chat focus
        } catch (error) {
            toast.error("Error al resetear la respuesta");
        } finally {
            setLoadingField(null);
        }
    };

    return (
        <Card className="mt-8 border-trust-navy/10 shadow-sm">
            <CardHeader className="bg-gray-50/50 border-b border-gray-100">
                <CardTitle className="text-xl font-serif text-trust-navy flex items-center justify-between">
                    <span>Revisión del Formulario DS-160</span>
                    <Badge variant="outline" className="bg-white">
                        {schema.length} Preguntas Totales
                    </Badge>
                </CardTitle>
            </CardHeader>
            <CardContent className="p-0">
                <Accordion type="single" collapsible className="w-full">
                    {Object.entries(sections).map(([sectionKey, questions]) => (
                        <AccordionItem key={sectionKey} value={sectionKey} className="border-b">
                            <AccordionTrigger className="px-6 hover:bg-gray-50 capitalize">
                                <span className="flex items-center gap-2">
                                    {sectionKey.replace(/_/g, ' ')}
                                    <Badge variant="secondary" className="ml-2 text-xs">
                                        {questions.length} preguntas
                                    </Badge>
                                </span>
                            </AccordionTrigger>
                            <AccordionContent className="bg-gray-50/30 px-6 py-4">
                                <div className="space-y-4">
                                    {questions.map((q: any) => {
                                        const answer = getDeepValue(payload, q.field_key);
                                        const isAnswered = answer !== undefined && answer !== null && answer !== '';

                                        return (
                                            <div key={q.field_key} className="flex items-start justify-between p-3 bg-white rounded border border-gray-100 shadow-sm">
                                                <div className="space-y-1 flex-1">
                                                    <p className="text-sm font-medium text-gray-700">
                                                        {q.question_es}
                                                    </p>
                                                    <div className="text-sm text-gray-500">
                                                        {isAnswered ? (
                                                            <span className="font-semibold text-trust-navy">
                                                                {typeof answer === 'object' ? JSON.stringify(answer) : String(answer)}
                                                            </span>
                                                        ) : (
                                                            <span className="text-amber-600 italic flex items-center gap-1">
                                                                <AlertCircle size={12} /> Pendiente
                                                            </span>
                                                        )}
                                                    </div>
                                                </div>
                                                <Button
                                                    size="sm"
                                                    variant="ghost"
                                                    className="shrink-0 ml-4 text-trust-navy hover:text-trust-blue hover:bg-blue-50"
                                                    onClick={() => handleEdit(q.field_key)}
                                                    disabled={loadingField === q.field_key}
                                                >
                                                    {loadingField === q.field_key ? (
                                                        <Spinner size="sm" />
                                                    ) : (
                                                        <Edit2 size={16} />
                                                    )}
                                                </Button>
                                            </div>
                                        );
                                    })}
                                </div>
                            </AccordionContent>
                        </AccordionItem>
                    ))}
                </Accordion>
            </CardContent>
        </Card>
    );
}
