
import { Card } from "@/components/ui/card";
import { CheckCircle2, XCircle, AlertCircle, Lightbulb, Download, Printer, ShieldCheck, TrendingUp, Sparkles, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { motion } from "framer-motion";

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
        <div className="flex flex-col h-full bg-[#FAFAFA] print:bg-white animate-in fade-in duration-500">
            {/* Header Content */}
            <div className="p-6 pb-2 print:p-0">
                <Card className={cn(
                    "relative overflow-hidden border-0 shadow-lg print:shadow-none bg-white",
                    "before:absolute before:top-0 before:left-0 before:w-full before:h-1",
                    isApproved ? "before:bg-gradient-to-r before:from-emerald-400 before:to-teal-500" : "before:bg-gradient-to-r before:from-rose-400 before:to-pink-600"
                )}>
                    {/* Background Pattern */}
                    <div className="absolute inset-0 opacity-[0.03] bg-[radial-gradient(#000000_1px,transparent_1px)] [background-size:16px_16px]" />

                    <div className="relative p-6 text-center space-y-6">
                        {/* Official Label */}
                        <div className="flex items-center justify-center gap-2 text-[10px] uppercase tracking-[0.2em] text-slate-400 font-medium">
                            <ShieldCheck className="w-3 h-3" />
                            <span>Official Analysis Dossier</span>
                        </div>

                        {/* Verdict Icon & Text */}
                        <div className="space-y-3">
                            <div className="flex justify-center">
                                <div className={cn(
                                    "p-3 rounded-full shadow-inner",
                                    isApproved ? "bg-emerald-50" : "bg-rose-50"
                                )}>
                                    {isApproved ? (
                                        <CheckCircle2 className="w-12 h-12 text-emerald-500" strokeWidth={1.5} />
                                    ) : (
                                        <XCircle className="w-12 h-12 text-rose-500" strokeWidth={1.5} />
                                    )}
                                </div>
                            </div>

                            <div>
                                <h1 className={cn(
                                    "text-3xl font-light tracking-tight",
                                    isApproved ? "text-emerald-900" : "text-rose-900"
                                )}>
                                    {isApproved ? "Visa Application Approved" : "Application Denied"}
                                </h1>
                                <p className="text-sm text-slate-500 mt-1 font-light">
                                    {isApproved ? "Your profile shows strong eligibility." : "Significant gaps identified in your case."}
                                </p>
                            </div>
                        </div>

                        {/* Score Metric */}
                        <div className="flex items-center justify-center gap-8 py-2">
                            <div className="text-center">
                                <p className="text-[10px] text-slate-400 uppercase tracking-wider mb-1">Score</p>
                                <div className="flex items-baseline justify-center gap-1">
                                    <span className={cn(
                                        "text-5xl font-extralight tracking-tighter",
                                        isApproved ? "text-emerald-600" : "text-slate-700"
                                    )}>
                                        {finalScore}
                                    </span>
                                    <span className="text-sm text-slate-300 font-light">/100</span>
                                </div>
                            </div>

                            <div className="h-10 w-px bg-slate-100" />

                            <div className="text-center">
                                <p className="text-[10px] text-slate-400 uppercase tracking-wider mb-1">Confidence</p>
                                <div className={cn(
                                    "text-sm font-medium px-3 py-1.5 rounded-full border",
                                    isApproved
                                        ? "bg-emerald-50 border-emerald-100 text-emerald-700"
                                        : "bg-rose-50 border-rose-100 text-rose-700"
                                )}>
                                    {isApproved ? "High Probability" : "High Risk"}
                                </div>
                            </div>
                        </div>

                        {/* Actions */}
                        <div className="flex justify-center gap-3 pt-2 print:hidden">
                            <Button
                                variant="ghost"
                                size="sm"
                                onClick={handlePrint}
                                className="text-slate-500 hover:text-slate-800 hover:bg-slate-50 border border-slate-100 rounded-full px-6 h-9"
                            >
                                <Printer className="w-3.5 h-3.5 mr-2" />
                                Print
                            </Button>
                            <Button
                                variant="ghost"
                                size="sm"
                                onClick={handlePrint}
                                className="text-slate-500 hover:text-slate-800 hover:bg-slate-50 border border-slate-100 rounded-full px-6 h-9"
                            >
                                <Download className="w-3.5 h-3.5 mr-2" />
                                Save PDF
                            </Button>
                        </div>
                    </div>
                </Card>
            </div>

            {/* Timeline Header */}
            <div className="px-6 pb-2 print:px-0">
                <div className="flex items-center justify-between text-xs text-slate-400 uppercase tracking-wider font-medium">
                    <span>Interaction Logic</span>
                    <span>{items.length} Rounds</span>
                </div>
            </div>

            {/* List */}
            <div className="flex-1 overflow-y-auto px-6 pb-6 space-y-4 custom-scrollbar">
                {items.map((item, idx) => (
                    <div key={idx} className="group relative pl-4 pb-2 border-l border-slate-100 last:border-0 hover:border-slate-200 transition-colors">
                        {/* Timeline Dot */}
                        <div className={cn(
                            "absolute -left-[5px] top-3 w-2.5 h-2.5 rounded-full ring-4 ring-white transition-all group-hover:scale-110",
                            item.scoreDelta > 0 ? "bg-emerald-400" : item.scoreDelta < 0 ? "bg-rose-400" : "bg-slate-300"
                        )} />

                        <Card className="p-4 border border-slate-100 shadow-sm rounded-xl bg-white hover:shadow-md transition-shadow">
                            {/* Question */}
                            <div className="mb-3">
                                <p className="text-[10px] text-slate-400 uppercase tracking-wider mb-1 flex items-center gap-1.5">
                                    <span className="w-1 h-1 rounded-full bg-slate-400" />
                                    Officer Asked
                                </p>
                                <p className="text-sm text-slate-700 font-medium italic">"{item.question}"</p>
                            </div>

                            {/* Answer */}
                            <div className="mb-3">
                                <p className="text-[10px] text-slate-400 uppercase tracking-wider mb-1 flex items-center gap-1.5">
                                    <span className="w-1 h-1 rounded-full bg-slate-400" />
                                    You Answered
                                </p>
                                <p className="text-sm text-slate-800">{item.answer}</p>
                            </div>

                            {/* Feedback */}
                            {item.feedback && (
                                <div className={cn(
                                    "mt-3 text-xs p-3 rounded-lg flex gap-3 leading-relaxed",
                                    item.scoreDelta < 0 ? "bg-rose-50/50 text-rose-800" : "bg-emerald-50/50 text-emerald-800"
                                )}>
                                    <div className="shrink-0 mt-0.5">
                                        <Lightbulb className={cn(
                                            "w-3.5 h-3.5",
                                            item.scoreDelta < 0 ? "text-rose-500" : "text-emerald-500"
                                        )} />
                                    </div>
                                    <span>{item.feedback}</span>
                                </div>
                            )}

                            {/* Delta Badge */}
                            <div className="absolute top-4 right-4">
                                <span className={cn(
                                    "px-2 py-0.5 rounded text-[10px] font-bold border",
                                    item.scoreDelta > 0
                                        ? "bg-emerald-50 border-emerald-100 text-emerald-600"
                                        : item.scoreDelta < 0
                                            ? "bg-rose-50 border-rose-100 text-rose-600"
                                            : "bg-slate-50 border-slate-100 text-slate-500"
                                )}>
                                    {item.scoreDelta > 0 ? "+" : ""}{item.scoreDelta} PTS
                                </span>
                            </div>
                        </Card>
                    </div>
                ))}
            </div>

            {/* Footer Action */}
            <div className="p-4 bg-white border-t border-slate-50 print:hidden">
                <Button
                    onClick={onRestart}
                    className="w-full h-14 bg-slate-900 hover:bg-slate-800 text-white rounded-2xl shadow-xl shadow-slate-200 transition-all hover:scale-[1.01] active:scale-[0.99] text-lg font-medium tracking-wide flex items-center justify-center gap-2"
                >
                    <Sparkles className="w-5 h-5 text-yellow-300" />
                    Start New Simulation
                </Button>
            </div>

            <style jsx global>{`
                @media print {
                    @page { margin: 0; }
                    body { -webkit-print-color-adjust: exact; }
                }
            `}</style>
        </div>
    );
}
