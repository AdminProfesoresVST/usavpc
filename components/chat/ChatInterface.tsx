"use client";

import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Send, User, Bot } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { useTranslations } from 'next-intl';

interface Message {
    id: string;
    role: "user" | "assistant";
    content: string;
    timestamp: Date;
    formalVersion?: string;
    redFlags?: string[];
}

export function ChatInterface() {
    const t = useTranslations('Chat');
    const [messages, setMessages] = useState<Message[]>([]);

    useEffect(() => {
        setMessages([
            {
                id: "welcome",
                role: "assistant",
                content: t('welcome'),
                timestamp: new Date(),
            },
        ]);
    }, [t]);

    const [input, setInput] = useState("");
    const [isTyping, setIsTyping] = useState(false);
    const messagesEndRef = useRef<HTMLDivElement>(null);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    const handleSend = async () => {
        if (!input.trim()) return;

        const userMsg: Message = {
            id: Date.now().toString(),
            role: "user",
            content: input,
            timestamp: new Date(),
        };

        const newMessages = [...messages, userMsg];
        setMessages(newMessages);
        setInput("");
        setIsTyping(true);

        try {
            const response = await fetch("/api/chat", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    messages: newMessages.map(m => ({ role: m.role, content: m.content }))
                }),
            });

            if (!response.ok) throw new Error("Failed to fetch response");

            const data = await response.json();

            const botMsg: Message = {
                id: (Date.now() + 1).toString(),
                role: "assistant",
                content: data.content,
                timestamp: new Date(),
                formalVersion: data.formal_version,
                redFlags: data.red_flags
            };

            setMessages((prev) => [...prev, botMsg]);
        } catch (error) {
            console.error("Chat Error:", error);
            setMessages((prev) => [...prev, {
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
            <div className="p-4 border-b border-border bg-muted/30">
                <div className="flex items-center gap-2">
                    <div className="h-3 w-3 rounded-full bg-success-green animate-pulse" />
                    <h2 className="font-serif font-bold text-primary">{t('title')}</h2>
                </div>
                <p className="text-xs text-muted-foreground mt-1">
                    {t('secureId')}: {Math.random().toString(36).substr(2, 9).toUpperCase()}
                </p>
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

                            {/* Magic Mirror & Red Flags (Only for Assistant messages) */}
                            {msg.role === "assistant" && (
                                <div className="pl-12 max-w-[85%] space-y-2">
                                    {/* Formal Version */}
                                    {msg.formalVersion && (
                                        <motion.div
                                            initial={{ opacity: 0, height: 0 }}
                                            animate={{ opacity: 1, height: "auto" }}
                                            className="bg-official-grey border border-gray-200 rounded-sm p-3 text-xs text-muted-foreground"
                                        >
                                            <div className="flex items-center gap-1 mb-1 text-trust-navy font-bold uppercase tracking-wider text-[10px]">
                                                <span>Formal Record</span>
                                            </div>
                                            <p className="italic">"{msg.formalVersion}"</p>
                                        </motion.div>
                                    )}

                                    {/* Red Flags */}
                                    {msg.redFlags && msg.redFlags.length > 0 && (
                                        <motion.div
                                            initial={{ opacity: 0, scale: 0.95 }}
                                            animate={{ opacity: 1, scale: 1 }}
                                            className="bg-red-50 border border-red-100 rounded-sm p-3 text-xs text-alert-red"
                                        >
                                            <div className="flex items-center gap-1 mb-1 font-bold uppercase tracking-wider text-[10px]">
                                                <span>Risk Factor Detected</span>
                                            </div>
                                            <ul className="list-disc list-inside">
                                                {msg.redFlags.map((flag, idx) => (
                                                    <li key={idx}>{flag}</li>
                                                ))}
                                            </ul>
                                        </motion.div>
                                    )}
                                </div>
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
                            <div className="bg-white border border-border p-3 rounded-sm shadow-sm flex items-center gap-1">
                                <span className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce [animation-delay:-0.3s]" />
                                <span className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce [animation-delay:-0.15s]" />
                                <span className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce" />
                            </div>
                        </div>
                    </motion.div>
                )}
                <div ref={messagesEndRef} />
            </div>

            <div className="p-4 border-t border-border bg-white">
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
                        disabled={isTyping}
                    />
                    <Button
                        type="submit"
                        disabled={!input.trim() || isTyping}
                        className="bg-primary text-primary-foreground hover:bg-primary/90 uppercase tracking-wide font-semibold"
                    >
                        <Send size={16} />
                    </Button>
                </form>
            </div>
        </Card>
    );
}
