import { SupabaseClient } from "@supabase/supabase-js";

export async function getSystemPrompt(supabase: SupabaseClient, key: string): Promise<string> {
  const { data, error } = await supabase
    .from('ai_prompts')
    .select('prompt')
    .eq('key', key)
    .single();

  if (error || !data) {
    console.error(`Failed to fetch prompt: ${key}`, error);
    // Fallback to hardcoded (safety net) or throw
    return FALLBACK_PROMPTS[key as keyof typeof FALLBACK_PROMPTS] || "";
  }

  return data.prompt;
}

// Keep fallbacks just in case DB fails or during transition
const FALLBACK_PROMPTS = {
  JOB_TRANSLATOR: `You are an expert Consular Officer... (Fallback)`,
  RISK_ANALYST: `You are a Visa Risk Analyst... (Fallback)`,
  CHAT_PERSONA: `You are the "Consular Assistant"... (Fallback)`,
  SPOUSE_PARSER: `Extract Spouse details... (Fallback)`,
  ANSWER_VALIDATOR: `You are a strict data validator for the DS-160 form.
    Your goal is to validate the user's answer to a specific question.
    
    Question: "{question}"
    User Answer: "{input}"
    
    Analyze the answer for:
    1. Validity: Does it directly answer the question?
    2. English Proficiency: Rate the user's English on a scale of 1-10 (1=None, 10=Native). Consider grammar, vocabulary, and complexity. If the answer is "Yes/No" or a date, score it as null (cannot determine).
    3. Sentiment: 'neutral', 'confused', 'frustrated', 'confident'.
    4. Help Detection: Does the user seem confused, ask for clarification, or say "I don't know"?
    
    Return JSON:
    {
      "isValid": boolean,
      "refusalMessage": "string (if invalid, polite but firm)",
      "extractedValue": "string (clean value)",
      "english_proficiency": number | null,
      "sentiment": "string",
      "isHelpRequest": boolean,
      "helpResponse": "string (if isHelpRequest is true, explain the question simply like a teacher)"
    }`,
  RISK_ASSESSMENT: `You are a Senior Visa Consultant.
    Analyze the applicant's "Triage Profile" to estimate their visa probability.
    
    Profile:
    - Job: {job}
    - Income: {income}
    - Marital Status: {marital_status}
    - Children: {children}
    - Property: {property}
    
    Goal: Give a 2-sentence "Preliminary Assessment".
    
    Rules:
    1. If they have a Job + Property + Family: "High Probability". Be encouraging.
    2. If they are Unemployed or Low Income: "Medium/Low Probability". Be honest but constructive. Tell them we need to focus on their "Social Ties" or "Savings" to improve chances.
    3. Tone: Professional, Empathetic, Expert.
    4. CRITICAL: This is NOT a rejection. Always end by encouraging them to proceed: "Let's continue filling the form to present your best case."
    
    Return JSON:
    {
      "assessment_message": "string (The message to the user)",
      "risk_level": "low" | "medium" | "high"
    }`
};
