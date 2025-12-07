"use client";

import { useState } from "react";
import { ChatInterface } from "@/components/chat/ChatInterface";
import { PassportOCR } from "@/components/onboarding/PassportOCR";
import { Triage } from "@/components/onboarding/Triage";
import { Decision } from "@/components/onboarding/Decision";
import { useTranslations } from 'next-intl';
import Image from "next/image";
import { AnimatePresence, motion } from "framer-motion";
import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';

type AssessmentStep = 'ocr' | 'triage' | 'decision' | 'chat';

export function AssessmentFlow() {
    const t = useTranslations('Chat');
    const [step, setStep] = useState<AssessmentStep>('ocr');
    const [triageAnswers, setTriageAnswers] = useState<any>({});
    const router = useRouter();
    const locale = useLocale();

    const handleTriageComplete = (answers: any) => {
        setTriageAnswers(answers);
        setStep('decision');
    };

    const handleChatComplete = () => {
        // Redirect to dashboard where Payment Gate will be waiting
        router.push(`/${locale}/dashboard`);
    };

    return (
        <div className="relative min-h-screen flex flex-col bg-official-grey">
            <div className="absolute inset-0 z-0 h-64 bg-trust-navy overflow-hidden">
                <Image
                    src="/bg-hero.png"
                    alt="Background"
                    fill
                    className="object-cover object-center opacity-20"
                    priority
                />
            </div>
            <div className="container mx-auto px-4 py-8 relative z-10">
                <div className="max-w-4xl mx-auto">
                    <AnimatePresence mode="wait">
                        {step === 'ocr' && (
                            <motion.div
                                key="ocr"
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0, y: -20 }}
                            >
                                <PassportOCR onComplete={() => setStep('triage')} />
                            </motion.div>
                        )}

                        {step === 'triage' && (
                            <motion.div
                                key="triage"
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0, y: -20 }}
                            >
                                <Triage onComplete={handleTriageComplete} />
                            </motion.div>
                        )}

                        {step === 'decision' && (
                            <motion.div
                                key="decision"
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0, y: -20 }}
                            >
                                <Decision
                                    answers={triageAnswers}
                                    onComplete={() => setStep('chat')}
                                />
                            </motion.div>
                        )}

                        {step === 'chat' && (
                            <motion.div
                                key="chat"
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0, y: -20 }}
                            >
                                <h1 className="text-2xl font-serif font-bold mb-6 text-white">{t('title')}</h1>
                                <ChatInterface onComplete={handleChatComplete} />
                            </motion.div>
                        )}
                    </AnimatePresence>
                </div>
            </div>
        </div>
    );
}
