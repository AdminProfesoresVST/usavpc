// ... imports
import { SimulatorReport } from "./SimulatorReport";

// ... Inside ChatInterface

const [isFinished, setIsFinished] = useState(false);
const [finalStats, setFinalStats] = useState<{ score: number, verdict: "APPROVED" | "DENIED" } | null>(null);

// ... handleSend logic
// Inside: const data = await response.json();

if (data.meta) {
    // Update last message with metadata if available
    // Only assistant messages have metadata
}

// Check Termination
if (data.meta?.action?.startsWith("TERMINATE")) {
    setFinalStats({
        score: data.meta.current_score,
        verdict: data.meta.action.includes("APPROVED") ? "APPROVED" : "DENIED"
    });
    setIsFinished(true);
    // Don't add next question if terminated?
    // Or add the verdict message?
}

if (data.nextStep && !data.meta?.action?.startsWith("TERMINATE")) {
    const botMsg: Message = {
        id: (Date.now() + 1).toString(),
        role: "assistant",
        content: data.response || data.nextStep.question,
        timestamp: new Date(),
        validationResult: {
            // Reuse this field for Simulator Meta
            displayValue: data.meta?.score_delta?.toString(),
            extractedValue: data.meta?.feedback
        }
    };
    setMessages(prev => [...prev, botMsg]);
    // ...
}
// ...

if (isFinished && finalStats) {
    // Build Report Items from Messages (User -> Assistant Pairs)
    const reportItems = messages.filter(m => m.role === 'assistant' && m.validationResult?.extractedValue).map((msg, idx) => {
        // Find preceding user message
        const msgIndex = messages.findIndex(m => m.id === msg.id);
        const userMsg = messages[msgIndex - 1]; // Approximate
        return {
            question: userMsg ? "Respuesta del Usuario" : "Interacción",
            answer: userMsg?.content || "...",
            scoreDelta: parseInt(msg.validationResult?.displayValue || "0"),
            feedback: msg.validationResult?.extractedValue || "",
            scoreTotal: 0
        }
    });

    // BETTER: Retrieve History from DB? 
    // For now, Client State is okay MVP.
    // Actually, logic above relies on Assistant Message having Feedback.
    // The Feedback is about the PREVIOUS User Answer.
    // So Assistant Message N has feedback for User Message N-1.

    const strictItems = [];
    for (let i = 0; i < messages.length; i++) {
        if (messages[i].role === 'user') {
            // Find next assistant message
            const nextBot = messages[i + 1];
            if (nextBot && nextBot.role === 'assistant' && nextBot.validationResult?.extractedValue) {
                strictItems.push({
                    question: messages[i - 1]?.content || "Pregunta Inicial", // The question BEFORE user answered
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
        {/* ... Existing UI ... */}


        return (
        <div className="flex flex-col h-full w-full bg-[#F0F2F5]">
            {/* Assistant Header (Embedded in flow or sticky?) Template implies embedded */}
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
                            {/* Message Bubbles Logic (same as before) */}
                            <motion.div
                                initial={{ opacity: 0, y: 8 }}
                                animate={{ opacity: 1, y: 0 }}
                                className={cn(
                                    "px-4 py-2.5 shadow-sm text-[15px] leading-relaxed relative",
                                    msg.role === "user"
                                        ? "bg-[#2672DE] text-white rounded-2xl rounded-br-sm text-left"
                                        : "bg-white text-[#1F2937] rounded-2xl rounded-bl-sm text-left border border-gray-100" // Updated to White/Border
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
