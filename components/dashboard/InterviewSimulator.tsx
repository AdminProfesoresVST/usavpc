"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Mic, Play, StopCircle, Volume2 } from "lucide-react";
import { useTranslations } from 'next-intl';

export function InterviewSimulator() {
    const t = useTranslations('Common'); // Assuming we add translations later
    const [isRecording, setIsRecording] = useState(false);
    const [isPlaying, setIsPlaying] = useState(false);
    const [feedback, setFeedback] = useState<string | null>(null);

    const toggleRecording = () => {
        if (isRecording) {
            setIsRecording(false);
            // Simulate AI processing
            setTimeout(() => {
                setFeedback("Good confidence, but try to be more specific about your travel dates. Avoid vague answers like 'maybe in summer'.");
            }, 1500);
        } else {
            setIsRecording(true);
            setFeedback(null);
        }
    };

    return (
        <div className="space-y-6">
            <div className="bg-gradient-to-r from-trust-navy to-blue-900 text-white p-8 rounded-lg shadow-lg">
                <h2 className="text-2xl font-serif font-bold mb-2">AI Consul Simulator</h2>
                <p className="opacity-90">Practice your interview with our Voice-Enabled Virtual Officer.</p>
            </div>

            <div className="grid md:grid-cols-2 gap-6">
                {/* Virtual Consul */}
                <Card className="p-6 flex flex-col items-center justify-center min-h-[300px] bg-gray-50 border-2 border-dashed border-gray-200">
                    <div className="w-24 h-24 bg-gray-200 rounded-full flex items-center justify-center mb-4 relative">
                        {isPlaying && <div className="absolute inset-0 bg-blue-400 rounded-full animate-ping opacity-20"></div>}
                        <Volume2 size={40} className="text-gray-600" />
                    </div>
                    <p className="text-lg font-medium text-center mb-6">
                        "What is the specific purpose of your trip to the United States?"
                    </p>
                    <Button
                        variant="outline"
                        onClick={() => setIsPlaying(!isPlaying)}
                        className="gap-2"
                    >
                        {isPlaying ? <StopCircle size={16} /> : <Play size={16} />}
                        {isPlaying ? "Stop Audio" : "Replay Question"}
                    </Button>
                </Card>

                {/* User Response */}
                <Card className="p-6 flex flex-col items-center justify-center min-h-[300px]">
                    <div className={`w-20 h-20 rounded-full flex items-center justify-center mb-6 transition-colors ${isRecording ? 'bg-red-100 text-red-600' : 'bg-blue-50 text-blue-600'}`}>
                        <Mic size={32} className={isRecording ? 'animate-pulse' : ''} />
                    </div>

                    <Button
                        size="lg"
                        className={`w-full max-w-xs mb-6 ${isRecording ? 'bg-red-500 hover:bg-red-600' : ''}`}
                        onClick={toggleRecording}
                    >
                        {isRecording ? "Stop Recording" : "Start Speaking"}
                    </Button>

                    {feedback && (
                        <div className="bg-yellow-50 border border-yellow-200 p-4 rounded-md text-sm text-yellow-800 w-full">
                            <p className="font-bold mb-1">AI Feedback:</p>
                            {feedback}
                        </div>
                    )}
                </Card>
            </div>
        </div>
    );
}
