"use client";

import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ArrowLeft, CheckCircle2, Languages, MessageSquare, Send, Sparkles, X, PlusCircle, Bot, User } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { useTranslations, useLocale } from 'next-intl';
import { SimulatorReport } from "./SimulatorReport";

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

export function ChatInterface({ onComplete, initialData, mode = 'standard' }: { onComplete?: () => void, initialData?: any, mode?: string }) {
    const t = useTranslations('Chat');
    const locale = useLocale();
    const [messages, setMessages] = useState<Message[]>([]);
    const [currentQuestion, setCurrentQuestion] = useState<QuestionState | null>(null);
    const [progress, setProgress] = useState(0);

    const [isFinished, setIsFinished] = useState(false);
    const [finalStats, setFinalStats] = useState<{ score: number, verdict: "APPROVED" | "DENIED" } | null>(null);

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
                throw new Error("Failed to communicate with AI");
            }

            const data = await response.json();

            // Update metadata if present (simplified logic)
            if (data.meta) {
                // can extend logic here if needed
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
                // If terminated, maybe wait 3s then show Report?
                // For now, immediate switch (controlled by isFinished render)
                // But we probably want the user to read the last message.
                // Let's rely on isFinished state.
                // If isFinished=true, logic below handles it.
            }

        } catch (error) {
            console.error("Chat Error:", error);
            setMessages(prev => [...prev, {
                id: Date.now().toString(),
                role: "assistant",
                content: "Error de conexión. Intente de nuevo.",
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
        <div className="flex flex-col h-full w-full bg-[#F0F2F5]">
            {/* Assistant Header */}
            <div className="px-4 pt-4 pb-2">
                <div className="flex items-center gap-4 bg-white p-4 rounded-2xl shadow-sm border border-gray-100">
                    <div className="relative">
                        <div className="w-12 h-12 rounded-full bg-[#F0F2F5] flex items-center justify-center">
                            <Bot className="w-6 h-6 text-[#003366]" />
                        </div>
                        <span className="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
                    </div>
                    <div>
                        <h3 className="font-bold text-[#1F2937]">
                            {mode === 'simulator' ? "Oficial Consular (Simulador)" : "Asistente Consular"}
                        </h3>
                        <p className="text-xs text-gray-500">Sistema Automatizado • ID 4421</p>
                    </div>
                </div>
            </div>

            {/* Chat Area */}
            <div className="flex-1 overflow-y-auto px-4 py-2 space-y-3 scroll-smooth relative no-scrollbar">

                {/* Date Divider */}
                <div className="flex justify-center my-4">
                    <span className="text-gray-400 text-[11px] font-medium uppercase tracking-wide">Hoy</span>
                </div>

                <AnimatePresence initial={false}>
                    {messages.map((msg) => (
                        <div key={msg.id} className={cn(
                            "flex flex-col gap-1 max-w-[85%] w-fit mb-1",
                            msg.role === "user" ? "ml-auto items-end" : "mr-auto items-start"
                        )}>
                            <motion.div
                                initial={{ opacity: 0, y: 8 }}
                                animate={{ opacity: 1, y: 0 }}
                                className={cn(
                                    "px-4 py-2.5 shadow-sm text-[15px] leading-relaxed relative",
                                    msg.role === "user"
                                        ? "bg-[#2672DE] text-white rounded-2xl rounded-br-sm text-left"
                                        : "bg-white text-[#1F2937] rounded-2xl rounded-bl-sm text-left border border-gray-100"
                                )}
                            >
                                {msg.content}
                                <div className={cn(
                                    "text-[10px] text-right mt-1 opacity-70",
                                    msg.role === "user" ? "text-blue-100" : "text-gray-400"
                                )}>
                                    {msg.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                </div>
                            </motion.div>
                        </div>
                    ))}
                </AnimatePresence>

                {isTyping && (
                    <div className="flex justify-start w-full mb-4">
                        <div className="bg-white px-3 py-2 rounded-2xl rounded-bl-sm inline-flex items-center gap-1 shadow-sm border border-gray-100">
                            <span className="w-1.5 h-1.5 bg-[#003366] rounded-full animate-bounce [animation-delay:-0.3s]" />
                            <span className="w-1.5 h-1.5 bg-[#003366] rounded-full animate-bounce [animation-delay:-0.15s]" />
                            <span className="w-1.5 h-1.5 bg-[#003366] rounded-full animate-bounce" />
                        </div>
                    </div>
                )}
                <div ref={messagesEndRef} />
            </div>

            {/* Input Area */}
            <div className="flex-none p-3 pb-4 bg-[#F0F2F5]">
                <div className="bg-white p-2 rounded-full flex items-center shadow-md border border-gray-100">
                    <button
                        onClick={() => setInput("")}
                        className="p-2 text-[#2672DE] hover:bg-blue-50 rounded-full transition"
                    >
                        <PlusCircle size={24} />
                    </button>

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
                        placeholder={isTyping ? "Espere..." : (currentQuestion?.type === 'select' ? "Seleccione una opción..." : "Escribe tu respuesta...")}
                        className="flex-1 bg-transparent border-none outline-none text-sm px-2 text-[#1F2937] placeholder-gray-400"
                        autoComplete="off"
                        disabled={isTyping}
                    />

                    <button
                        onClick={() => handleSend()}
                        disabled={!input.trim() || isTyping}
                        className="p-2 bg-[#2672DE] text-white rounded-full hover:bg-blue-700 transition disabled:opacity-50"
                    >
                        <Send size={18} className="ml-0.5" />
                    </button>
                </div>
            </div>
        </div>
    );
}
