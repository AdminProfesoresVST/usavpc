"use client";

import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ArrowLeft, CheckCircle2, Languages, MessageSquare, Send, Sparkles, X, PlusCircle, Bot, User } from 'lucide-react';
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

export function ChatInterface({ onComplete, initialData }: { onComplete?: () => void, initialData?: any }) {
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
                    body: JSON.stringify({ answer: null, context: initialData }),
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

    const inputRef = useRef<HTMLInputElement>(null);
    const [input, setInput] = useState("");
    const [isTyping, setIsTyping] = useState(false);
    const messagesEndRef = useRef<HTMLDivElement>(null);
    const startTimeRef = useRef<number>(Date.now());

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
            // Small delay to ensure render is complete
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
                    locale: locale
                }),
            });

            if (!response.ok) {
                throw new Error("Failed to communicate with AI");
            }

            const data = await response.json();

            if (data.nextStep) {
                const botMsg: Message = {
                    id: (Date.now() + 1).toString(),
                    role: "assistant",
                    content: data.response || data.nextStep.question,
                    timestamp: new Date(),
                    validationResult: data.validationResult
                };
                setMessages(prev => [...prev, botMsg]);
                setCurrentQuestion(data.nextStep);
                setProgress(data.progress || 0);
            } else {
                setMessages(prev => [...prev, {
                    id: Date.now().toString(),
                    role: "assistant",
                    content: t('finalMessage'),
                    timestamp: new Date()
                }]);

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
                content: "I'm having trouble connecting. Please try again.",
                timestamp: new Date(),
            }]);
        } finally {
            setIsTyping(false);
        }
    };

    return (
        <Card className="w-full max-w-2xl mx-auto h-[650px] flex flex-col border-none shadow-2xl bg-white/95 backdrop-blur-sm rounded-3xl overflow-hidden ring-1 ring-black/5">
            {/* Header */}
            <div className="p-4 border-b border-gray-100 bg-white/50 flex justify-between items-center backdrop-blur-md sticky top-0 z-10">
                <div className="flex items-center gap-3">
                    <div className="relative">
                        <div className="h-10 w-10 rounded-full bg-gradient-to-tr from-blue-600 to-indigo-600 flex items-center justify-center text-white shadow-lg">
                            <Bot size={20} />
                        </div>
                        <div className="absolute bottom-0 right-0 h-3 w-3 rounded-full bg-green-500 ring-2 ring-white animate-pulse" />
                    </div>
                    <div>
                        <h2 className="font-bold text-gray-800 text-lg leading-tight">{t('title')}</h2>
                        <p className="text-xs text-gray-500 font-medium">{t('secureId')}</p>
                    </div>
                </div>

                <div className="flex flex-col items-end gap-1">
                    <span className="text-xs font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full">{Math.round(progress)}% Complete</span>
                    <div className="w-32 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                        <div
                            className="h-full bg-gradient-to-r from-blue-500 to-indigo-600 transition-all duration-700 ease-out"
                            style={{ width: `${progress}%` }}
                        />
                    </div>
                </div>
            </div>

            {/* Chat Area - WhatsApp Corporate Style */}
            <div className="flex-1 overflow-y-auto p-4 space-y-3 bg-white scroll-smooth relative">

                {/* Minimal Header / Profile Overlay (Optional, matching snippet context) */}
                <div className="flex flex-col items-center py-6 opacity-60">
                    <div className="h-20 w-20 bg-[#F0F2F5] rounded-full flex items-center justify-center text-[#2672DE] mb-2 font-bold text-2xl border border-gray-100">
                        AG
                    </div>
                    <h2 className="text-xl font-bold text-[#1F2937]">Asistente Consular</h2>
                    <p className="text-sm text-gray-500">Soporte Oficial • Trust Navy Corp</p>
                </div>

                {/* Date Divider (Static for now) */}
                <div className="flex justify-center my-4">
                    <span className="text-gray-400 text-[11px] font-medium uppercase tracking-wide">Hoy</span>
                </div>

                <AnimatePresence initial={false}>
                    {messages.map((msg) => (
                        <div key={msg.id} className={cn(
                            "flex flex-col gap-1 max-w-[85%] w-fit mb-1",
                            msg.role === "user" ? "ml-auto items-end" : "mr-auto items-start"
                        )}>
                            <div className="flex items-end gap-2">
                                {msg.role !== 'user' && (
                                    <img
                                        src="https://ui-avatars.com/api/?name=Asistente+Consular&background=F0F2F5&color=003366"
                                        alt="AC"
                                        className="w-7 h-7 rounded-full mb-1 border border-gray-50 shrink-0"
                                    />
                                )}

                                <motion.div
                                    initial={{ opacity: 0, y: 8 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    className={cn(
                                        "px-4 py-2.5 shadow-sm text-[15px] leading-relaxed relative",
                                        msg.role === "user"
                                            ? "bg-[#2672DE] text-white rounded-2xl rounded-br-sm text-left" // Focus Blue
                                            : "bg-[#F0F2F5] text-[#1F2937] rounded-2xl rounded-bl-sm text-left" // Official Grey
                                    )}
                                >
                                    {msg.content}

                                    {/* Timestamp inside bubble */}
                                    <div className={cn(
                                        "text-[10px] text-right mt-1 opacity-70",
                                        msg.role === "user" ? "text-blue-100" : "text-gray-500"
                                    )}>
                                        {msg.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                        {msg.role === "user" && <CheckCircle2 size={10} className="inline ml-1" />}
                                    </div>
                                </motion.div>
                            </div>

                            {/* Logic Mirror (Subtle corporate style) */}
                            {msg.validationResult && (msg.validationResult.extractedValue || msg.validationResult.interpreted) && msg.role === 'assistant' && (
                                <motion.div
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1 }}
                                    className="px-2 mt-1 mb-2"
                                >
                                    <div className="flex flex-col gap-1 ml-8 max-w-[85%]">
                                        <div className="flex items-center gap-1.5">
                                            <Sparkles size={12} className="text-blue-500" />
                                            <span className="text-[10px] uppercase tracking-wider font-bold text-blue-500">IA Procesó:</span>
                                        </div>
                                        <div className="bg-blue-50/50 text-blue-900 border-l-2 border-blue-400 px-3 py-2 rounded-r-lg text-xs shadow-sm backdrop-blur-sm">
                                            {msg.validationResult.displayValue || msg.validationResult.extractedValue || msg.validationResult.interpreted}
                                        </div>
                                    </div>
                                </motion.div>
                            )}
                        </div>
                    ))}
                </AnimatePresence>

                {isTyping && (
                    <div className="flex justify-start w-full pl-9 mb-4">
                        <div className="bg-[#F0F2F5] px-3 py-2 rounded-2xl rounded-bl-sm inline-flex items-center gap-1 shadow-sm">
                            <span className="w-1.5 h-1.5 bg-[#003366] rounded-full animate-bounce [animation-delay:-0.3s]" />
                            <span className="w-1.5 h-1.5 bg-[#003366] rounded-full animate-bounce [animation-delay:-0.15s]" />
                            <span className="w-1.5 h-1.5 bg-[#003366] rounded-full animate-bounce" />
                        </div>
                    </div>
                )}
                <div ref={messagesEndRef} />
            </div>

            {/* Input Area - Corporate Pill Style */}
            <div className="flex-none bg-white p-2 px-3 flex items-center gap-2 border-t border-gray-50">
                <button
                    onClick={() => {
                        // Reset/Clear Logic or Attach Menu
                        setInput("");
                    }}
                    className="p-2 text-[#2672DE] transition hover:bg-blue-50 rounded-full"
                >
                    <PlusCircle size={24} />
                </button>

                <div className="flex-1 bg-[#F0F2F5] rounded-full flex items-center px-4 py-2 min-h-[44px]">
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
                        className="w-full bg-transparent border-none outline-none text-[#1F2937] placeholder-gray-400 text-[15px]"
                        autoComplete="off"
                        disabled={isTyping}
                    />
                </div>

                <button
                    onClick={() => handleSend()}
                    disabled={!input.trim() || isTyping}
                    className="p-2 text-[#2672DE] transition-transform active:scale-95 disabled:opacity-50 hover:bg-blue-50 rounded-full"
                >
                    <Send size={24} className="fill-current" />
                </button>
            </div>
        </Card>
    );
}
