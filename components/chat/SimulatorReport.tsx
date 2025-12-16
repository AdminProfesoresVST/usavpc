
import { Card } from "@/components/ui/card";

import { CheckCircle2, XCircle, AlertCircle, Lightbulb } from "lucide-react";
import { Button } from "@/components/ui/button";

interface ReportItem {
    question: string;
    answer: string;
    scoreDelta: number;
    feedback: string;
    scoreTotal: number;
}

interface SimulatorReportProps {
    items: ReportItem[];
    finalScore: number;
    verdict: "APPROVED" | "DENIED";
    onRestart: () => void;
}

export function SimulatorReport({ items, finalScore, verdict, onRestart }: SimulatorReportProps) {
    const isApproved = verdict === "APPROVED";

    return (
        <div className="flex flex-col h-full bg-[#F0F2F5] p-4 gap-4">
            {/* Header Verdict */}
            <Card className={`p-6 text-center border-l-4 ${isApproved ? "border-green-500" : "border-red-500"}`}>
                <div className="flex justify-center mb-4">
                    {isApproved ? (
                        <CheckCircle2 className="w-16 h-16 text-green-500" />
                    ) : (
                        <XCircle className="w-16 h-16 text-red-500" />
                    )}
                </div>
                <h1 className="text-2xl font-bold mb-2">
                    {isApproved ? "VISA APROBADA" : "VISA DENEGADA"}
                </h1>
                <div className="text-4xl font-black text-[#003366] mb-2">
                    {finalScore}/100
                </div>
                <p className="text-gray-500 text-sm">
                    {isApproved
                        ? "¡Felicidades! Ha demostrado arraigo y coherencia."
                        : "No se preocupe. Revise los comentarios abajo para mejorar."}
                </p>
            </Card>


            {/* Detailed Breakdown */}
            <div className="flex-1 overflow-auto flex flex-col min-h-0">
                <h3 className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-3 flex-none">
                    Análisis Paso a Paso
                </h3>
                <div className="flex-1 overflow-y-auto pr-2">
                    <div className="space-y-4 pb-4">
                        {items.map((item, idx) => (
                            <Card key={idx} className="p-4 relative overflow-hidden">
                                {/* Score Badge */}
                                <div className={`absolute top-0 right-0 px-3 py-1 text-xs font-bold text-white
                                    ${item.scoreDelta > 0 ? "bg-green-500" : item.scoreDelta < 0 ? "bg-red-500" : "bg-gray-400"}`}>
                                    {item.scoreDelta > 0 ? "+" : ""}{item.scoreDelta} pts
                                </div>

                                <div className="mb-3 pr-10">
                                    <p className="text-xs text-gray-400 font-medium mb-1">PREGUNTA</p>
                                    <p className="text-sm font-medium text-gray-800 italic">"{item.question}"</p>
                                </div>

                                <div className="mb-3 bg-blue-50 p-2 rounded-md border border-blue-100">
                                    <p className="text-xs text-blue-400 font-medium mb-1">SU RESPUESTA</p>
                                    <p className="text-sm text-blue-900">{item.answer}</p>
                                </div>

                                {item.feedback && (
                                    <div className="flex gap-2 items-start bg-yellow-50 p-2 rounded-md border border-yellow-100">
                                        <Lightbulb className="w-4 h-4 text-yellow-600 mt-0.5 flex-none" />
                                        <div>
                                            <p className="text-xs text-yellow-600 font-bold mb-0.5">RECOMENDACIÓN (COACH)</p>
                                            <p className="text-xs text-gray-700 leading-relaxed">
                                                {item.feedback}
                                            </p>
                                        </div>
                                    </div>
                                )}
                            </Card>
                        ))}
                    </div>
                    </div>
                </div>
            </div>

            <Button onClick={onRestart} className="w-full bg-[#003366] hover:bg-[#004488] text-white py-6 text-lg">
                Intentar de Nuevo
            </Button>
        </div >
    );
}
