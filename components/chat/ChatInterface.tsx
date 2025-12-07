"use client";

import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Send, User, Bot, CheckCircle2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { useTranslations, useLocale } from 'next-intl';

interface Message {
    id: string;
    role: "user" | "assistant";
    content: string;
    timestamp: Date;
    validationResult?: {
        original: string;
        interpreted: string;
        type: string;
    };
}

interface QuestionState {
    field: string;
    question: string;
    type: 'text' | 'select' | 'date' | 'boolean';
    options?: { label: string; value: string }[];
    context?: string;
}

export function ChatInterface({ onComplete }: { onComplete?: () => void }) {
    const t = useTranslations('Chat');
    const locale = useLocale();
    const [messages, setMessages] = useState<Message[]>([]);
    const [currentQuestion, setCurrentQuestion] = useState<QuestionState | null>(null);
    const [progress, setProgress] = useState(0);

    // Initial load
    useEffect(() => {
        const initChat = async () => {
            try {
                // Call API with empty answer to get first question
                const response = await fetch("/api/chat", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ answer: null }),
                });
                const data = await response.json();

                if (data.nextStep) {
                    setMessages([{
                        id: "welcome",
                        role: "assistant",
                        content: data.nextStep.question,
                        timestamp: new Date(),
                    }]);
                    setCurrentQuestion(data.nextStep);
                }
            } catch (error) {
                console.error("Init Error:", error);
            }
        };
        initChat();
    }, []);

    const [input, setInput] = useState("");
    const [isTyping, setIsTyping] = useState(false);
    const messagesEndRef = useRef<HTMLDivElement>(null);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    const startTimeRef = useRef<number>(Date.now());

    // Reset timer when question changes
    useEffect(() => {
        if (currentQuestion) {
            startTimeRef.current = Date.now();
        }
    }, [currentQuestion]);

    const handleSend = async (answerOverride?: string) => {
        const answerToSend = answerOverride || input;
        if (!answerToSend.trim()) return;

        const duration = Date.now() - startTimeRef.current;

        // Add User Message
        const userMsg: Message = {
            id: Date.now().toString(),
            role: "user",
            content: answerToSend, // For display, we might want to show the label if it was a select
            timestamp: new Date(),
        };

        // If it was a select, find the label for display
        if (currentQuestion?.type === 'select' && currentQuestion.options) {
            const selectedOption = currentQuestion.options.find(o => o.value === answerToSend);
            if (selectedOption) userMsg.content = selectedOption.label;
        }

        setMessages(prev => [...prev, userMsg]);
        setInput("");
        setIsTyping(true);
        setCurrentQuestion(null); // Hide inputs while processing

        try {
            const response = await fetch("/api/chat", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    answer: answerToSend,
                    duration: duration,
                    locale: locale
                }),
            });

            if (!response.ok) throw new Error("Failed to fetch response");

            const data = await response.json();

            // Add Assistant Message (Next Question)
            if (data.nextStep) {
                const botMsg: Message = {
                    id: (Date.now() + 1).toString(),
                    role: "assistant",
                    content: data.nextStep.question,
                    timestamp: new Date(),
                    validationResult: data.validationResult
                };
                setMessages(prev => [...prev, botMsg]);
                setCurrentQuestion(data.nextStep);
                setProgress(data.progress || 0);
            } else {
                // Finished!
                setMessages(prev => [...prev, {
                    id: Date.now().toString(),
                    role: "assistant",
                    content: t('finalMessage'),
                    timestamp: new Date()
                }]);

                // Trigger completion callback
                if (onComplete) {
                    setTimeout(() => {
                        onComplete();
                    }, 2000);
                }
            }

        } catch (error) {
            console.error("Chat Error:", error);
            setMessages(prev => [...prev, {
                id: Date.now().toString(),
                role: "assistant",
                content: t('error'),
                timestamp: new Date(),
            }]);
        } finally {
            setIsTyping(false);
        }
    };

    return (
        <Card className="w-full max-w-2xl mx-auto h-[600px] flex flex-col border-border shadow-sm bg-white">
            <div className="p-4 border-b border-border bg-muted/30 flex justify-between items-center">
                <div className="flex items-center gap-2">
                    <div className="h-3 w-3 rounded-full bg-success-green animate-pulse" />
                    <div>
                        <h2 className="font-serif font-bold text-primary">{t('title')}</h2>
                        <p className="text-xs text-muted-foreground">{t('secureId')}</p>
                    </div>
                </div>
                {/* Progress Indicator */}
                <div className="flex items-center gap-2">
                    <div className="text-xs font-mono text-primary">{Math.round(progress)}%</div>
                    <div className="w-24 h-2 bg-gray-200 rounded-full overflow-hidden">
                        <div
                            className="h-full bg-success-green transition-all duration-500"
                            style={{ width: `${progress}%` }}
                        />
                    </div>
                </div>
            </div>

            <div className="flex-1 overflow-y-auto p-4 space-y-6 bg-official-grey/50">
                <AnimatePresence initial={false}>
                    {messages.map((msg) => (
                        <div key={msg.id} className="flex flex-col gap-2">
                            <motion.div
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                className={cn(
                                    "flex w-full",
                                    msg.role === "user" ? "justify-end" : "justify-start"
                                )}
                            >
                                <div
                                    className={cn(
                                        "flex max-w-[80%] gap-2",
                                        msg.role === "user" ? "flex-row-reverse" : "flex-row"
                                    )}
                                >
                                    <div
                                        className={cn(
                                            "h-8 w-8 rounded-sm flex items-center justify-center shrink-0",
                                            msg.role === "user" ? "bg-primary text-white" : "bg-white border border-border text-primary"
                                        )}
                                    >
                                        {msg.role === "user" ? <User size={16} /> : <Bot size={16} />}
                                    </div>
                                    <div
                                        className={cn(
                                            "p-3 rounded-sm text-sm shadow-sm",
                                            msg.role === "user"
                                                ? "bg-primary text-white"
                                                : "bg-white border border-border text-foreground"
                                        )}
                                    >
                                        {msg.content}
                                        <span className="block text-[10px] opacity-70 mt-1 text-right">
                                            {msg.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                        </span>
                                    </div>
                                </div>
                            </motion.div>

                            {/* Validation Mirror - Only show for complex inputs (not simple booleans) */}
                            {msg.validationResult && msg.validationResult.type !== 'boolean' && (
                                <motion.div
                                    initial={{ opacity: 0, height: 0 }}
                                    animate={{ opacity: 1, height: "auto" }}
                                    className="pl-12 max-w-[85%]"
                                >
                                    <div className="bg-blue-50 border border-blue-100 rounded-sm p-3 text-xs text-blue-900">
                                        <div className="flex items-center gap-1 mb-1 font-bold uppercase tracking-wider text-[10px] text-blue-700">
                                            <CheckCircle2 size={12} />
                                            <span>{t('systemInterpretation')}</span>
                                        </div>
                                        <p className="italic mb-1">{t('original')}: "{msg.validationResult.original}"</p>
                                        <p className="font-semibold">{t('formal')}: "{msg.validationResult.interpreted}"</p>
                                    </div>
                                </motion.div>
                            )}
                        </div>
                    ))}
                </AnimatePresence>

                {isTyping && (
                    <motion.div
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="flex justify-start w-full"
                    >
                        <div className="flex max-w-[80%] gap-2">
                            <div className="h-8 w-8 rounded-sm flex items-center justify-center shrink-0 bg-white border border-border text-primary">
                                <Bot size={16} />
                            </div>
                            <div className="bg-white border border-border p-3 rounded-sm shadow-sm flex items-center gap-3">
                                <div className="flex items-center gap-1">
                                    <span className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce [animation-delay:-0.3s]" />
                                    <span className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce [animation-delay:-0.15s]" />
                                    <span className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce" />
                                </div>
                                <span className="text-xs text-muted-foreground animate-pulse">{t('analyzing')}</span>
                            </div>
                        </div>
                    </motion.div>
                )}
                <div ref={messagesEndRef} />
            </div>

            <div className="p-4 border-t border-border bg-white">
                {currentQuestion?.type === 'select' && currentQuestion.options ? (
                    <div className="flex flex-wrap gap-2 justify-end">
                        {currentQuestion.options.map((option) => (
                            <Button
                                key={option.value}
                                onClick={() => handleSend(option.value)}
                                variant="outline"
                                className="border-primary text-primary hover:bg-primary hover:text-white transition-colors"
                            >
                                {option.label}
                            </Button>
                        ))}
                    </div>
                ) : (
                    <form
                        onSubmit={(e: React.FormEvent) => {
                            e.preventDefault();
                            handleSend();
                        }}
                        className="flex gap-2"
                    >
                        <Input
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            placeholder={t('placeholder')}
                            className="flex-1 bg-input-bg border-input-border focus-visible:ring-focus-ring"
                            disabled={isTyping || !currentQuestion}
                        />
                        <Button
                            type="submit"
                            disabled={!input.trim() || isTyping || !currentQuestion}
                            className="bg-primary text-primary-foreground hover:bg-primary/90 uppercase tracking-wide font-semibold"
                        >
                            <Send size={16} />
                        </Button>
                    </form>
                )}
            </div>
        </Card>
    );
}
