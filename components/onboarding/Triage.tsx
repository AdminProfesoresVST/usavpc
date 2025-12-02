"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { useTranslations } from "next-intl";
import { ArrowRight, CheckCircle2 } from "lucide-react";

interface TriageProps {
    onComplete: (data: any) => void;
}

export function Triage({ onComplete }: TriageProps) {
    const t = useTranslations('HomePage.Triage');
    const [step, setStep] = useState(0);
    const [answers, setAnswers] = useState<any>({});

    const questions = [
        {
            id: 'q1',
            key: 'q1',
            options: ['tourism', 'business', 'other']
        },
        {
            id: 'q2',
            key: 'q2',
            options: ['no', 'yes']
        },
        {
            id: 'q3',
            key: 'q3',
            options: ['asap', 'months', 'flexible']
        }
    ];

    const handleAnswer = (questionId: string, answer: string) => {
        const newAnswers = { ...answers, [questionId]: answer };
        setAnswers(newAnswers);

        if (step < questions.length - 1) {
            setStep(step + 1);
        } else {
            onComplete(newAnswers);
        }
    };

    const currentQ = questions[step];

    return (
        <Card className="w-full max-w-md mx-auto p-8 bg-white shadow-lg border-border min-h-[400px] flex flex-col justify-center">
            <AnimatePresence mode="wait">
                <motion.div
                    key={step}
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    className="w-full"
                >
                    <div className="mb-8">
                        <span className="text-xs font-bold text-accent-gold uppercase tracking-wider mb-2 block">
                            Question {step + 1} of {questions.length}
                        </span>
                        <h2 className="text-2xl font-serif font-bold text-trust-navy">
                            {t(`${currentQ.key}.title`)}
                        </h2>
                    </div>

                    <div className="space-y-3">
                        {currentQ.options.map((opt) => (
                            <Button
                                key={opt}
                                variant="outline"
                                className="w-full justify-between text-left h-auto py-4 px-6 text-lg border-2 hover:border-trust-navy hover:bg-trust-navy/5 group transition-all"
                                onClick={() => handleAnswer(currentQ.id, opt)}
                            >
                                <span className="text-trust-navy font-medium group-hover:text-trust-navy">
                                    {t(`${currentQ.key}.options.${opt}`)}
                                </span>
                                <ArrowRight className="w-5 h-5 text-gray-300 group-hover:text-trust-navy transition-colors" />
                            </Button>
                        ))}
                    </div>
                </motion.div>
            </AnimatePresence>

            <div className="mt-8 flex gap-1 justify-center">
                {questions.map((_, idx) => (
                    <div
                        key={idx}
                        className={`h-1.5 rounded-full transition-all duration-300 ${idx === step ? "w-8 bg-trust-navy" : idx < step ? "w-2 bg-success-green" : "w-2 bg-gray-200"
                            }`}
                    />
                ))}
            </div>
        </Card>
    );
}
