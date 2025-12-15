"use client";

import { useState } from "react";
import { ChatInterface } from "@/components/chat/ChatInterface";
import { PassportOCR } from "@/components/onboarding/PassportOCR";
import { Triage } from "@/components/onboarding/Triage";
import { Decision } from "@/components/onboarding/Decision";
import { useTranslations } from 'next-intl';
// Header removed (handled by Layout)
import Image from "next/image";
import { AnimatePresence, motion } from "framer-motion";
import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';

type AssessmentStep = 'ocr' | 'triage' | 'decision' | 'chat';

export function AssessmentFlow() {
    const t = useTranslations('Chat');
    const [step, setStep] = useState<AssessmentStep>('chat');
    const [triageAnswers, setTriageAnswers] = useState<any>({});
    const [ocrData, setOcrData] = useState<any>(null);
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
        <div className="flex flex-col h-full bg-[#f0f2f5]">
            {/* Header removed */}

            <div className="flex-1 relative z-10 h-full overflow-hidden">
                <AnimatePresence mode="wait">
                    {step === 'chat' && (
                        <motion.div
                            key="chat"
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            className="h-full"
                        >
                            <ChatInterface
                                initialData={{ ...ocrData, ...triageAnswers }}
                                onComplete={handleChatComplete}
                            />
                        </motion.div>
                    )}
                </AnimatePresence>
            </div>
        </div>
    );
}
