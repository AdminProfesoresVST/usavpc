"use client";

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";

import {
    Brain,
    TrendingUp,
    Heart,
    DollarSign,
    RefreshCcw,
    ShieldCheck,
    Zap,
    Globe,
    ArrowRight,
    CheckCircle2,
    AlertTriangle,
    Loader2
} from "lucide-react";

type WorkerType = 'funnel' | 'empathy' | 'revenue' | 'retention' | 'compliance' | 'speed' | 'economist';

interface Insight {
    id: string;
    worker: WorkerType;
    stage: 'analysis' | 'criticism' | 'refinement' | 'final';
    content: string;
    criticism?: string;
    refinement?: string;
    confidence: number;
    timestamp: Date;
}

const WORKERS = {
    funnel: { name: "The Funnel Architect", icon: TrendingUp, color: "text-blue-500", bg: "bg-blue-100" },
    empathy: { name: "The Empathy Engine", icon: Heart, color: "text-rose-500", bg: "bg-rose-100" },
    revenue: { name: "The Revenue Optimizer", icon: DollarSign, color: "text-green-500", bg: "bg-green-100" },
    retention: { name: "The Retention Specialist", icon: RefreshCcw, color: "text-orange-500", bg: "bg-orange-100" },
    compliance: { name: "The Compliance Officer", icon: ShieldCheck, color: "text-slate-500", bg: "bg-slate-100" },
    speed: { name: "The Speed Demon", icon: Zap, color: "text-yellow-500", bg: "bg-yellow-100" },
    economist: { name: "The Economist", icon: Globe, color: "text-indigo-500", bg: "bg-indigo-100" },
};

export function StrategyReport() {
    const [isSimulating, setIsSimulating] = useState(false);
    const [insights, setInsights] = useState<Insight[]>([]);
    const [progress, setProgress] = useState(0);

    const startSimulation = () => {
        setIsSimulating(true);
        setInsights([]);
        setProgress(0);

        // Simulation Sequence
        const sequence = [
            {
                worker: 'funnel',
                initial: "Drop-off at 'Passport Number' is 30%. Users are lazy.",
                critique: "Lazy? No, they are scared. They don't know WHY we need it.",
                refined: "Add a tooltip: 'Required by US State Dept for DS-160'. Trust increases conversion."
            },
            {
                worker: 'economist',
                initial: "Global price $99 is optimal.",
                critique: "False. $99 is 2 weeks wages in Mexico. We are losing 90% of the LATAM market.",
                refined: "Implement PPP Pricing: $49 for LATAM, $99 for EU/US. Projected Revenue: +40%."
            },
            {
                worker: 'speed',
                initial: "API response 1.2s is acceptable.",
                critique: "Acceptable for a form? Yes. For a 'Conversation'? No. It breaks flow.",
                refined: "Implement Optimistic UI. Show 'Thinking...' immediately, then stream response. Perceived latency: 0ms."
            },
            {
                worker: 'compliance',
                initial: "Allow user to skip 'Marital Status' if unsure.",
                critique: "Dangerous. DS-160 rejects 'Unknown' for adults. This causes rejection.",
                refined: "Force selection but add 'Help me decide' wizard for separated/common-law couples."
            }
        ];

        let step = 0;
        const interval = setInterval(() => {
            if (step >= sequence.length) {
                clearInterval(interval);
                setIsSimulating(false);
                setProgress(100);
                return;
            }

            const item = sequence[step];
            const newInsight: Insight = {
                id: Math.random().toString(),
                worker: item.worker as WorkerType,
                stage: 'final',
                content: item.initial,
                criticism: item.critique,
                refinement: item.refined,
                confidence: 0.85 + (Math.random() * 0.1),
                timestamp: new Date()
            };

            setInsights(prev => [newInsight, ...prev]);
            setProgress(((step + 1) / sequence.length) * 100);
            step++;
        }, 2500);
    };

    return (
        <div className="space-y-6">
            <Card className="border-2 border-slate-200 shadow-sm">
                <CardHeader className="flex flex-row items-center justify-between">
                    <div>
                        <CardTitle className="flex items-center gap-2 text-2xl">
                            <Brain className="h-8 w-8 text-trust-navy" />
                            Business Intelligence Squad
                        </CardTitle>
                        <CardDescription>
                            7 Autonomous Agents analyzing Business & UX Strategy
                        </CardDescription>
                    </div>
                    <Button
                        onClick={startSimulation}
                        disabled={isSimulating}
                        size="lg"
                        className={isSimulating ? "animate-pulse" : ""}
                    >
                        {isSimulating ? (
                            <>
                                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                Agents Working...
                            </>
                        ) : (
                            <>
                                <Zap className="mr-2 h-4 w-4" />
                                Run Strategy Simulation
                            </>
                        )}
                    </Button>
                </CardHeader>
                <CardContent>
                    {insights.length === 0 && !isSimulating ? (
                        <div className="text-center py-12 text-slate-400">
                            <Brain className="h-16 w-16 mx-auto mb-4 opacity-20" />
                            <p>Ready to deploy workers. Click "Run Strategy Simulation" to start.</p>
                        </div>
                    ) : (
                        <div className="space-y-6">
                            {insights.map((insight) => {
                                const WorkerIcon = WORKERS[insight.worker].icon;
                                return (
                                    <Card key={insight.id} className="overflow-hidden border-l-4 border-l-trust-navy animate-in slide-in-from-top-4 duration-500">
                                        <div className="p-6 grid gap-6 md:grid-cols-[200px_1fr]">
                                            {/* Worker Identity */}
                                            <div className="flex flex-col items-start gap-2 border-r border-slate-100 pr-6">
                                                <div className={`p-3 rounded-xl ${WORKERS[insight.worker].bg}`}>
                                                    <WorkerIcon className={`h-6 w-6 ${WORKERS[insight.worker].color}`} />
                                                </div>
                                                <span className="font-bold text-slate-700">{WORKERS[insight.worker].name}</span>
                                                <Badge variant="outline" className="mt-1">
                                                    Confidence: {(insight.confidence * 100).toFixed(0)}%
                                                </Badge>
                                            </div>

                                            {/* Thinking Process */}
                                            <div className="space-y-4">
                                                {/* 1. Initial Thought */}
                                                <div className="flex gap-3 items-start opacity-60">
                                                    <div className="mt-1 p-1 bg-slate-100 rounded-full">
                                                        <Brain className="h-3 w-3 text-slate-500" />
                                                    </div>
                                                    <div>
                                                        <p className="text-xs font-bold uppercase text-slate-400 tracking-wider">Initial Hypothesis</p>
                                                        <p className="text-slate-600">"{insight.content}"</p>
                                                    </div>
                                                </div>

                                                {/* 2. Self-Criticism */}
                                                <div className="flex gap-3 items-start">
                                                    <div className="mt-1 p-1 bg-rose-100 rounded-full">
                                                        <AlertTriangle className="h-3 w-3 text-rose-500" />
                                                    </div>
                                                    <div>
                                                        <p className="text-xs font-bold uppercase text-rose-500 tracking-wider">Self-Correction</p>
                                                        <p className="text-rose-700 font-medium">"{insight.criticism}"</p>
                                                    </div>
                                                </div>

                                                {/* 3. Final Refinement */}
                                                <div className="flex gap-3 items-start bg-green-50/50 p-3 rounded-lg border border-green-100">
                                                    <div className="mt-1 p-1 bg-green-100 rounded-full">
                                                        <CheckCircle2 className="h-3 w-3 text-green-600" />
                                                    </div>
                                                    <div>
                                                        <p className="text-xs font-bold uppercase text-green-600 tracking-wider">Strategic Action</p>
                                                        <p className="text-green-800 font-bold text-lg">{insight.refinement}</p>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </Card>
                                );
                            })}
                        </div>
                    )}
                </CardContent>
            </Card>
        </div>
    );
}
