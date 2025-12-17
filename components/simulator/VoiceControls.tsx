"use client";

import { useState, useEffect, useRef } from "react";
import { Mic, MicOff, Volume2, VolumeX } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface VoiceControlsProps {
    onTranscript: (text: string) => void;
    textToSpeak?: string;
    autoSpeak?: boolean;
    disabled?: boolean;
}

export function VoiceControls({ onTranscript, textToSpeak, autoSpeak = true, disabled }: VoiceControlsProps) {
    const [isListening, setIsListening] = useState(false);
    const [isMuted, setIsMuted] = useState(!autoSpeak);
    const [supported, setSupported] = useState(false);

    const recognitionRef = useRef<any>(null);
    const synthRef = useRef<SpeechSynthesis | null>(null);

    // Initialize Speech API
    useEffect(() => {
        if (typeof window !== "undefined") {
            const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
            if (SpeechRecognition) {
                recognitionRef.current = new SpeechRecognition();
                recognitionRef.current.continuous = false; // Stop after one sentence
                recognitionRef.current.interimResults = false;
                recognitionRef.current.lang = "en-US"; // Default to English, maybe dynamic later?

                recognitionRef.current.onresult = (event: any) => {
                    const transcript = event.results[0][0].transcript;
                    if (transcript) {
                        onTranscript(transcript);
                    }
                    setIsListening(false);
                };

                recognitionRef.current.onerror = (event: any) => {
                    console.error("Speech Error:", event.error);
                    setIsListening(false);
                };

                recognitionRef.current.onend = () => {
                    setIsListening(false);
                };

                setSupported(true);
            }

            if ('speechSynthesis' in window) {
                synthRef.current = window.speechSynthesis;
            }
        }
    }, [onTranscript]);

    // Handle TTS Trigger
    useEffect(() => {
        if (textToSpeak && !isMuted && synthRef.current) {
            // Cancel previous
            synthRef.current.cancel();

            const utterance = new SpeechSynthesisUtterance(textToSpeak);
            // Try to find a good voice
            const voices = synthRef.current.getVoices();
            const preferredVoice = voices.find(v => v.lang.includes("en-US") && v.name.includes("Google")) || voices[0];
            if (preferredVoice) utterance.voice = preferredVoice;

            utterance.rate = 1.0;
            utterance.pitch = 1.0;

            synthRef.current.speak(utterance);
        }
    }, [textToSpeak, isMuted]);

    const toggleListening = () => {
        if (!recognitionRef.current) return;

        if (isListening) {
            recognitionRef.current.stop();
        } else {
            recognitionRef.current.start();
            setIsListening(true);
        }
    };

    const toggleMute = () => {
        setIsMuted(!isMuted);
    };

    if (!supported) return null;

    return (
        <div className="flex items-center gap-2">
            <Button
                variant={isMuted ? "ghost" : "default"}
                size="icon"
                onClick={toggleMute}
                className={cn("h-8 w-8", isMuted ? "text-gray-400" : "text-blue-500 bg-blue-50 hover:bg-blue-100")}
                title={isMuted ? "Enable TTS" : "Mute TTS"}
            >
                {isMuted ? <VolumeX className="w-4 h-4" /> : <Volume2 className="w-4 h-4" />}
            </Button>

            <Button
                variant={isListening ? "destructive" : "secondary"}
                size="icon"
                onClick={toggleListening}
                disabled={disabled}
                className={cn(
                    "h-10 w-10 rounded-full transition-all duration-300",
                    isListening ? "animate-pulse ring-4 ring-red-100" : ""
                )}
                title="Speak Answer"
            >
                {isListening ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5" />}
            </Button>
        </div>
    );
}
