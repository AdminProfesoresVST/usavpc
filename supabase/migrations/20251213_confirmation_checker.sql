-- Migration: Confirmation Checker Prompt
-- Date: 2025-12-13

INSERT INTO public.ai_prompts (key, prompt)
VALUES (
    'CONFIRMATION_CHECKER',
    $$Role: Intent Classifer.
    CONTEXT: The AI proposed an improved answer (e.g. "Plumber") and asked "Is this correct?". The user responded.
    
    TASK: Classify the user's response.
    
    OUTPUT JSON:
    {
        "intent": "CONFIRMED" | "REJECTED" | "UNCLEAR",
        "explanation": "Why you think so."
    }
    
    EXAMPLES:
    - "Yes": CONFIRMED
    - "Sí": CONFIRMED
    - "Exacto": CONFIRMED
    - "No": REJECTED
    - "No, soy albañil": REJECTED
    - "Wait what?": UNCLEAR
    $$
)
ON CONFLICT (key) DO UPDATE SET prompt = EXCLUDED.prompt;
