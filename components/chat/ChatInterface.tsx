"use client";

import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ArrowLeft, CheckCircle2, Languages, MessageSquare, Send, Sparkles, X, PlusCircle, Bot, User } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { useTranslations, useLocale } from 'next-intl';
import { experimental_useObject } from '@ai-sdk/react';
import { simulatorSchema } from '@/lib/ai/simulator-schema';
import { SimulatorReport } from "./SimulatorReport";
import { ConsulAvatar } from "@/components/simulator/ConsulAvatar"; // [NEW]
import { RiskMeter } from "@/components/simulator/RiskMeter";     // [NEW]
import { VoiceControls } from "@/components/simulator/VoiceControls"; // [NEW]

interface Message {
    id: string;
    role: "user" | "assistant";
    content: string;
    timestamp: Date;
    validationResult?: {
        original?: string;
        interpreted?: string;
        extractedValue?: string;
        displayValue?: string;
        type?: string;
    };
}

interface QuestionState {
    field: string;
    question: string;
    type: 'text' | 'select' | 'date' | 'boolean';
    options?: { label: string; value: string }[];
    context?: string;
}

// [NEW] Simulator State
interface SimulatorState {
    score: number;
    delta: number;
    sentiment: "neutral" | "skeptical" | "angry" | "positive";
    currentSuggestion?: string;
}

export function ChatInterface({ onComplete, initialData, mode = 'standard' }: { onComplete?: () => void, initialData?: any, mode?: string }) {
    const t = useTranslations('Chat');
    const locale = useLocale();
    const [messages, setMessages] = useState<Message[]>([]);
    const [currentQuestion, setCurrentQuestion] = useState<QuestionState | null>(null);
    const [progress, setProgress] = useState(0);

    const [isFinished, setIsFinished] = useState(false);
    const [finalStats, setFinalStats] = useState<{ score: number, verdict: "APPROVED" | "DENIED" } | null>(null);

    // [NEW] Simulator Visual Logic
    const [simState, setSimState] = useState<SimulatorState>({
        score: 50, // Start neutral
        delta: 0,
        sentiment: "neutral"
    });
    const [showBriefing, setShowBriefing] = useState(mode === 'simulator');

    const inputRef = useRef<HTMLInputElement>(null);
    const [input, setInput] = useState("");
    const [isTyping, setIsTyping] = useState(false);
    const messagesEndRef = useRef<HTMLDivElement>(null);
    const startTimeRef = useRef<number>(Date.now());

    // Initial load
    useEffect(() => {
        const initChat = async () => {
            try {
                // Call API with empty answer to get first question
                const response = await fetch("/api/chat", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ answer: null, context: initialData, mode }),
                });
                const data = await response.json();

                // [NEW] Capture Initial Suggestion
                if (data.meta?.suggestion) {
                    setSimState(prev => ({
                        ...prev,
                        currentSuggestion: data.meta.suggestion
                    }));
                }

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

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    // Reset timer when question changes
    useEffect(() => {
        if (currentQuestion) {
            startTimeRef.current = Date.now();
        }
    }, [currentQuestion]);

    // Auto-focus logic
    useEffect(() => {
        if (!isTyping && currentQuestion?.type !== 'select') {
            setTimeout(() => {
                inputRef.current?.focus();
            }, 100);
        }
    }, [isTyping, currentQuestion]);

    const { object, submit, isLoading: isStreaming, error: streamError } = experimental_useObject({
        api: '/api/chat',
        schema: simulatorSchema,
        onFinish: ({ object: finalObj }) => {
            // NOTE: This hook is currently UNUSED by the main logic below (fetch is used instead).
            // Keeping it for reference or future streaming switch.
        },
        onError: (err) => {
            console.error("Stream Error:", err);
        }
    });

    useEffect(() => {
        scrollToBottom();
    }, [messages, isTyping, isStreaming, object]); // Scroll on stream update


    const handleSend = async (answerOverride?: string) => {
        const answerToSend = answerOverride || input;
        if (!answerToSend.trim()) return;

        const duration = Date.now() - startTimeRef.current;

        // Add User Message
        const userMsg: Message = {
            id: Date.now().toString(),
            role: "user",
            content: answerToSend,
            timestamp: new Date(),
        };

        if (currentQuestion?.type === 'select' && currentQuestion.options) {
            const selectedOption = currentQuestion.options.find(o => o.value === answerToSend);
            if (selectedOption) userMsg.content = selectedOption.label;
        }

        setMessages(prev => [...prev, userMsg]);
        setInput("");
        setIsTyping(true);
        setCurrentQuestion(null);

        try {
            const response = await fetch("/api/chat", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    answer: answerToSend,
                    duration: duration,
                    locale: locale,
                    mode: mode,
                    history: messages.map(m => ({ role: m.role, content: m.content }))
                }),
            });

            if (!response.ok) {
                if (!response.ok) {
                    const errorText = await response.text();
                    throw new Error(`Error ${response.status}: ${errorText || "Unknown Server Error"}`);
                }
            }

            const data = await response.json();

            // [NEW] Update Simulator State Logic
            if (data.meta) {
                const newScore = data.meta.current_score || simState.score;
                const delta = data.meta.score_delta || 0;

                // Calculate Sentiment
                let sentiment: SimulatorState["sentiment"] = "neutral";
                if (delta > 0) sentiment = "positive";
                if (delta < 0) sentiment = "skeptical";
                if (delta <= -10) sentiment = "angry";

                setSimState({
                    score: newScore,
                    delta: delta,
                    sentiment: sentiment,
                    currentSuggestion: data.meta.suggestion
                });
            }

            // Check Termination
            if (data.meta?.action?.startsWith("TERMINATE")) {
                setFinalStats({
                    score: data.meta.current_score,
                    verdict: data.meta.action.includes("APPROVED") ? "APPROVED" : "DENIED"
                });
                setIsFinished(true);
            }

            // Add Assistant Message if NOT terminated (or if we want to show last message)
            // Ideally we show the last message even if terminated, to explain why.
            // data.response contains the closing statement.

            const botMsg: Message = {
                id: (Date.now() + 1).toString(),
                role: "assistant",
                content: data.response || data.nextStep?.question || "",
                timestamp: new Date(),
                validationResult: {
                    displayValue: data.meta?.score_delta?.toString(),
                    extractedValue: data.meta?.feedback
                }
            };
            setMessages(prev => [...prev, botMsg]);

            if (data.nextStep && !data.meta?.action?.startsWith("TERMINATE")) {
                setCurrentQuestion(data.nextStep);
                setProgress(data.progress || 0);
            } else {
                // Terminated logic handled by isFinished
            }

        } catch (error) {
            console.error("Chat Error:", error);
            setMessages(prev => [...prev, {
                id: Date.now().toString(),
                role: "assistant",
                content: `Error de conexión (Cliente): ${(error as Error).message || "Desconocido"}. Intente de nuevo.`,
                timestamp: new Date(),
            }]);
        } finally {
            setIsTyping(false);
        }
    };

    if (isFinished && finalStats) {
        // Build Strict Report Items
        const strictItems = [];
        for (let i = 0; i < messages.length; i++) {
            if (messages[i].role === 'user') {
                const nextBot = messages[i + 1];
                if (nextBot && nextBot.role === 'assistant' && nextBot.validationResult?.extractedValue) {
                    strictItems.push({
                        question: messages[i - 1]?.content || "Pregunta Inicial",
                        answer: messages[i].content,
                        scoreDelta: parseInt(nextBot.validationResult.displayValue || "0"),
                        feedback: nextBot.validationResult.extractedValue || "",
                        scoreTotal: 0
                    });
                }
            }
        }

        return (
            <SimulatorReport
                items={strictItems}
                finalScore={finalStats.score}
                verdict={finalStats.verdict}
                onRestart={() => window.location.reload()}
            />
        );
    }

    return (
        <div className="flex flex-col h-full w-full bg-slate-50">
            {/* [NEW] Pre-Interview Briefing Modal */}
            {mode === 'simulator' && showBriefing && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in">
                    <Card className="max-w-md w-full p-6 space-y-6 shadow-2xl border-2 border-blue-100">
                        <div className="text-center space-y-2">
                            <div className="mx-auto w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                                <Bot className="w-6 h-6 text-blue-600" />
                            </div>
                            <h2 className="text-xl font-bold text-slate-800">
                                {locale === 'es' ? 'Antes de comenzar...' : 'Before we start...'}
                            </h2>
                            <p className="text-sm text-slate-500">
                                {locale === 'es'
                                    ? 'Sigue estas recomendaciones para aprobar:'
                                    : 'Follow these recommendations to pass:'}
                            </p>
                        </div>

                        <ul className="space-y-3 text-sm text-slate-700 bg-slate-50 p-4 rounded-lg border border-slate-100">
                            <li className="flex gap-2">
                                <CheckCircle2 className="w-4 h-4 text-green-500 shrink-0 mt-0.5" />
                                <span>{locale === 'es' ? 'Responde corto y directo.' : 'Keep answers short and direct.'}</span>
                            </li>
                            <li className="flex gap-2">
                                <CheckCircle2 className="w-4 h-4 text-green-500 shrink-0 mt-0.5" />
                                <span>{locale === 'es' ? 'Usa detalles (Fechas, Dólares, Lugares).' : 'Use specifics (Dates, Dollars, Places).'}</span>
                            </li>
                            <li className="flex gap-2">
                                <Sparkles className="w-4 h-4 text-yellow-500 shrink-0 mt-0.5" />
                                <span className="font-medium text-yellow-700">
                                    {locale === 'es' ? 'El Coach te dará "Susurros" de ayuda.' : 'The Coach will give you "Whisper" hints.'}
                                </span>
                            </li>
                        </ul>

                        <Button onClick={() => setShowBriefing(false)} className="w-full h-12 text-base shadow-lg hover:scale-[1.02] transition-transform">
                            {locale === 'es' ? 'Entendido, Comenzar' : 'Got it, Start'}
                        </Button>
                    </Card>
                </div>
            )}
            {/* Assistant Header */}
            <div className="px-4 pt-4 pb-2">
                <div className={cn(
                    "flex items-center gap-4 p-4 rounded-3xl shadow-md border relative overflow-hidden transition-all",
                    mode === 'simulator'
                        ? "bg-white border-blue-100/50 text-slate-800 ring-4 ring-blue-50/50"
                        : "bg-white border-gray-100"
                )}>
                    {mode === 'simulator' && (
                        <div className="absolute inset-0 opacity-[0.02] bg-[radial-gradient(#003366_1px,transparent_1px)] [background-size:12px_12px]" />
                    )}
                    {mode === 'simulator' ? (
                        // [NEW] Simulator Header (Avatar + Risk Meter)
                        <>
                            <ConsulAvatar
                                sentiment={simState.sentiment}
                                isSpeaking={isTyping}
                            />
                            <div className="flex-1">
                                <h3 className="font-bold">Oficial Consular</h3>
                                <p className="text-xs text-slate-400">Section 214(b) Enforcement</p>
                            </div>
                            <RiskMeter score={simState.score} delta={simState.delta} />
                        </>
                    ) : (
                        // Standard Header
                        <>
                            <div className="relative">
                                <div className="w-12 h-12 rounded-full bg-[#F0F2F5] flex items-center justify-center">
                                    <Bot className="w-6 h-6 text-[#003366]" />
                                </div>
                                <span className="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
                            </div>
                            <div>
                                <h3 className="font-bold text-[#1F2937]">Asistente Consular</h3>
                                <p className="text-xs text-gray-500">Sistema Automatizado • ID 4421</p>
                            </div>
                        </>
                    )}
                </div>

                {/* [NEW] COACHING SUGGESTION (Simple) */}
                {simState.currentSuggestion && mode === 'simulator' && (
                    <div className="mt-2 mx-1 p-3 bg-yellow-50 border border-yellow-200 rounded-xl flex items-start gap-3 shadow-sm">
                        <div className="p-1.5 bg-yellow-100 rounded-full shrink-0">
                            <Sparkles className="w-4 h-4 text-yellow-600" />
                        </div>
                        <div>
                            <p className="text-xs font-bold text-yellow-800 uppercase tracking-wider mb-0.5">
                                {locale === 'es' ? 'Sugerencia del Coach' : 'Coach Tip'}
                            </p>
                            <p className="text-sm text-yellow-900 leading-snug">
                                {simState.currentSuggestion}
                            </p>
                        </div>
                    </div>
                )}
            </div>


            {/* Chat Area */}
            <div className="flex-1 overflow-y-auto px-4 py-2 space-y-3 scroll-smooth relative no-scrollbar">

                {/* Date Divider */}
                <div className="flex justify-center my-4">
                    <span className="text-gray-400 text-[11px] font-medium uppercase tracking-wide">Hoy</span>
                </div>

                <div className="flex-1 overflow-y-auto p-4 space-y-4">
                    {messages.map((msg) => (
                        <div
                            key={msg.id}
                            className={cn(
                                "flex w-max max-w-[85%] flex-col gap-2 rounded-2xl px-4 py-3 text-sm shadow-sm",
                                msg.role === "user"
                                    ? "ml-auto bg-[#003366] text-white rounded-tr-sm"
                                    : "bg-white text-slate-700 border border-slate-100 rounded-tl-sm"
                            )}
                        >
                            {msg.content}
                            {msg.validationResult?.extractedValue && (
                                <div className="mt-1 text-xs opacity-70 border-t pt-1 border-white/20">
                                    💡 {msg.validationResult.extractedValue}
                                    {msg.validationResult.displayValue && (
                                        <span className={(Number(msg.validationResult.displayValue) || 0) > 0 ? "text-green-300 ml-2" : "text-red-300 ml-2"}>
                                            ({(Number(msg.validationResult.displayValue) > 0 ? "+" : "")}{msg.validationResult.displayValue})
                                        </span>
                                    )}
                                </div>
                            )}
                        </div>
                    ))}

                    {/* STREAMING MESSAGE (Ghost Bubble) */}
                    {isStreaming && object && (
                        <div className="flex w-max max-w-[80%] flex-col gap-2 rounded-lg px-3 py-2 text-sm bg-muted animate-pulse">
                            {object.response || "Thinking..."}
                            {object.feedback && (
                                <div className="mt-1 text-xs opacity-70 border-t pt-1 border-black/20">
                                    💡 {object.feedback}
                                </div>
                            )}
                        </div>
                    )}

                    {isTyping && !isStreaming && ( // Only show generic generic dots if NOT streaming object
                        <div className="flex w-max max-w-[80%] flex-col gap-2 rounded-lg px-3 py-2 text-sm bg-muted">
                            <motion.div
                                initial={{ opacity: 0 }}
                                animate={{ opacity: 1 }}
                                className="flex gap-1"
                            >
                                <span className="animate-bounce">●</span>
                                <span className="animate-bounce delay-100">●</span>
                                <span className="animate-bounce delay-200">●</span>
                            </motion.div>
                        </div>
                    )}
                    <div ref={messagesEndRef} />
                </div>

                {/* Input Area */}
                <div className="flex-none p-3 pb-4 bg-[#F0F2F5]">
                    {/* Helper Helper Text */}
                    <div className="text-center mb-2 text-[10px] text-gray-400 font-mono tracking-wider">
                        {mode === 'simulator' ? "SECTION 214(b) ENFORCEMENT ACTIVE" : ""}
                    </div>

                    <div className="bg-white p-2 rounded-full flex items-center shadow-md border border-gray-100 gap-2">
                        {/* Voice Controls Integration */}
                        {mode === 'simulator' ? (
                            <VoiceControls
                                onTranscript={(text) => setInput(text)}
                                textToSpeak={messages.length > 0 && messages[messages.length - 1].role === "assistant" ? messages[messages.length - 1].content : ""}
                                autoSpeak={true}
                                disabled={isTyping || isStreaming || isFinished}
                            />
                        ) : (
                            <button
                                onClick={() => setInput("")}
                                className="p-2 text-[#2672DE] hover:bg-blue-50 rounded-full transition"
                            >
                                <PlusCircle size={24} />
                            </button>
                        )}

                        <input
                            ref={inputRef}
                            type="text"
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            onKeyDown={(e) => {
                                if (e.key === 'Enter' && !e.shiftKey) {
                                    e.preventDefault();
                                    handleSend();
                                }
                            }}
                            placeholder={mode === 'simulator' ? "Habla o escribe tu respuesta..." : (isTyping ? "Espere..." : "Escribe tu respuesta...")}
                            className="flex-1 bg-transparent border-none outline-none text-sm px-2 text-[#1F2937] placeholder-gray-400"
                            autoComplete="off"
                            disabled={isTyping || (mode === 'simulator' && isFinished)}
                        />

                        <button
                            onClick={() => handleSend()}
                            disabled={!input.trim() || isTyping}
                            className={cn(
                                "p-2 rounded-full transition disabled:opacity-50",
                                mode === 'simulator' ? "bg-slate-900 text-white hover:bg-slate-800" : "bg-[#2672DE] text-white hover:bg-blue-700"
                            )}
                        >
                            <Send size={18} className="ml-0.5" />
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}
