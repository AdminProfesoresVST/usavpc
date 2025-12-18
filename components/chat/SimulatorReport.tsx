
import { Card } from "@/components/ui/card";
import { CheckCircle2, XCircle, AlertCircle, Lightbulb, Download, Printer, ShieldCheck, TrendingUp } from "lucide-react";
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

    const handlePrint = () => {
        window.print();
    };

    return (
        <div className="flex flex-col h-full bg-[#F0F2F5] p-4 gap-4 print:p-0 print:bg-white">
            {/* Header Verdict */}
            <Card className={`p-6 text-center border-l-4 shadow-xl print:shadow-none ${isApproved ? "border-green-500 bg-green-50/30" : "border-red-500 bg-red-50/30"}`}>
                <div className="flex justify-between items-start mb-2 print:hidden">
                    <div className="flex items-center gap-1 text-[10px] text-gray-400 font-bold uppercase tracking-widest">
                        <ShieldCheck className="w-3 h-3 text-blue-500" />
                        Official Analysis Dossier
                    </div>
                </div>

                <div className="flex justify-center mb-4">
                    {isApproved ? (
                        <CheckCircle2 className="w-20 h-20 text-green-500" />
                    ) : (
                        <XCircle className="w-20 h-20 text-red-500" />
                    )}
                </div>
                <h1 className="text-3xl font-black mb-1 text-[#003366]">
                    {isApproved ? "VISA APPROVED" : "VISA DENIED"}
                </h1>
                <div className="flex items-center justify-center gap-4 mb-4">
                    <div className="text-5xl font-black text-[#003366]">
                        {finalScore}<span className="text-lg text-gray-400">/100</span>
                    </div>
                    <div className="h-10 w-px bg-gray-200" />
                    <div className="text-left">
                        <p className="text-[10px] font-bold text-gray-400 uppercase leading-none">Confidence Level</p>
                        <p className={`text-sm font-bold ${isApproved ? "text-green-600" : "text-amber-600"}`}>
                            {isApproved ? "High Probability" : "High Risk Area"}
                        </p>
                    </div>
                </div>
                <p className="text-gray-600 text-sm max-w-sm mx-auto">
                    {isApproved
                        ? "You have demonstrated strong ties and a clear purpose of travel. Maintain this consistency during the real interview."
                        : "Critical logic gaps detected. Review the red-flagged answers below to adjust your strategy."}
                </p>

                <div className="mt-6 flex gap-2 justify-center print:hidden">
                    <Button variant="outline" size="sm" onClick={handlePrint} className="gap-2 border-[#003366] text-[#003366] hover:bg-blue-50">
                        <Printer className="w-4 h-4" />
                        Print Dossier
                    </Button>
                    <Button variant="outline" size="sm" onClick={handlePrint} className="gap-2 border-[#003366] text-[#003366] hover:bg-blue-50">
                        <Download className="w-4 h-4" />
                        Export PDF
                    </Button>
                </div>
            </Card>

            {/* Detailed Breakdown */}
            <div className="flex-1 overflow-hidden flex flex-col min-h-0 bg-white rounded-xl border border-gray-200 shadow-xl print:shadow-none print:border-none">
                <div className="p-4 border-b border-gray-100 bg-gray-50/50 flex justify-between items-center">
                    <h3 className="text-xs font-black text-gray-500 uppercase tracking-widest flex items-center gap-2">
                        <TrendingUp className="w-3 h-3 text-blue-500" />
                        Logic & Behavioral Analysis
                    </h3>
                    <span className="text-[10px] text-gray-400 font-medium">
                        {items.length} Rounds Evaluated
                    </span>
                </div>

                <div className="flex-1 overflow-y-auto p-4 custom-scrollbar">
                    <div className="space-y-4">
                        {items.map((item, idx) => (
                            <div key={idx} className="border border-gray-100 rounded-xl overflow-hidden relative transition-all hover:border-blue-200 hover:shadow-md">
                                {/* Score Badge */}
                                <div className={`absolute top-0 right-0 px-3 py-1.5 text-[10px] font-black text-white z-10 rounded-bl-xl
                                    ${item.scoreDelta > 0 ? "bg-green-500" : item.scoreDelta < 0 ? "bg-red-500" : "bg-gray-400"}`}>
                                    {item.scoreDelta > 0 ? "+" : ""}{item.scoreDelta} PTS
                                </div>

                                <div className="p-4 bg-white">
                                    <div className="mb-3 pr-12">
                                        <p className="text-[10px] text-gray-400 font-black uppercase mb-1 flex items-center gap-1">
                                            <div className="w-1.5 h-1.5 rounded-full bg-blue-500" />
                                            Officer Query
                                        </p>
                                        <p className="text-sm font-bold text-gray-800 italic leading-snug">"{item.question}"</p>
                                    </div>

                                    <div className="mb-3 bg-gray-50 p-3 rounded-lg border border-gray-100">
                                        <p className="text-[10px] text-gray-500 font-bold uppercase mb-1">Applicant Response</p>
                                        <p className="text-sm text-gray-700 leading-relaxed">{item.answer}</p>
                                    </div>

                                    {item.feedback && (
                                        <div className={`flex gap-3 items-start p-3 rounded-lg border ${item.scoreDelta < 0 ? "bg-red-50 border-red-100" : "bg-blue-50 border-blue-100"}`}>
                                            <div className={`mt-1 p-1 rounded-full ${item.scoreDelta < 0 ? "bg-red-100" : "bg-blue-100"}`}>
                                                <Lightbulb className={`w-3.5 h-3.5 ${item.scoreDelta < 0 ? "text-red-600" : "text-blue-600"}`} />
                                            </div>
                                            <div>
                                                <p className={`text-[10px] font-black uppercase mb-1 ${item.scoreDelta < 0 ? "text-red-700" : "text-blue-700"}`}>
                                                    {item.scoreDelta < 0 ? "Critical Correction" : "Strategic Advice"}
                                                </p>
                                                <p className="text-xs text-gray-700 leading-relaxed font-medium">
                                                    {item.feedback}
                                                </p>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            <Button onClick={onRestart} className="w-full bg-[#003366] hover:bg-[#002244] text-white py-8 text-xl font-black rounded-xl shrink-0 shadow-2xl transition-transform active:scale-[0.98] print:hidden">
                RESTART SIMULATION
            </Button>

            <p className="text-[10px] text-gray-400 text-center uppercase tracking-widest font-medium opacity-50 print:block hidden">
                Generated via USVPC AI Simulator | Official Protocol 214(b) | {new Date().toLocaleDateString()}
            </p>
        </div>
    );
}

const printStyles = `
@media print {
    body * {
        visibility: hidden;
    }
    .print-container, .print-container * {
        visibility: visible;
    }
    .print-container {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
    }
}
`;
