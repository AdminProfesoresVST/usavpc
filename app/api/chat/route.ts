import { OpenAI } from "openai";
import { NextResponse } from "next/server";

const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

const SYSTEM_PROMPT = `You are a Consular Officer assistant for the US Visa Processing Center. 
Your goal is to help users complete their DS-160 application data gathering.

You must output your response in valid JSON format with the following structure:
{
  "reply": "Your conversational response here...",
  "formal_version": "A formal, bureaucratic rephrasing of the user's last input (e.g., 'Construction work' -> 'Mason / Concrete Finisher'). If the input was already formal, keep it similar.",
  "red_flags": ["List of any potential visa denial risks detected in the user's input (e.g., 'arrest', 'drugs', 'overstay', 'unemployed'). If none, return empty array."]
}

Guidelines:
1. Act with authority and professionalism (GovTech persona).
2. Ask one question at a time to gather necessary information (Citizenship, Purpose of Travel, Employment, etc.).
3. If the user replies in Spanish, understand it perfectly but reply in English (unless explicitly asked otherwise), and provide the English formal version.
4. If the user provides informal input, clarify and suggest the formal DS-160 term in the 'formal_version' field.

Current Phase: Eligibility & Strategy Review (Tripwire).
Ask 5 key questions (one by one):
1. Nationality/Citizenship?
2. Primary purpose of travel?
3. Current employment status?
4. Have you ever been denied a US visa?
5. Estimated monthly income?

After gathering these, inform the user that their "VisaScore" is ready to be calculated and they should proceed to the next step.
`;

export async function POST(req: Request) {
    try {
        const { messages } = await req.json();

        const completion = await openai.chat.completions.create({
            model: "gpt-4o-mini",
            messages: [
                { role: "system", content: SYSTEM_PROMPT },
                ...messages,
            ],
            temperature: 0.3,
            response_format: { type: "json_object" }
        });

        const content = completion.choices[0].message.content;
        if (!content) throw new Error("No content received");

        const parsedContent = JSON.parse(content);

        return NextResponse.json({
            role: "assistant",
            content: parsedContent.reply,
            formal_version: parsedContent.formal_version,
            red_flags: parsedContent.red_flags
        });
    } catch (error) {
        console.error("OpenAI API Error:", error);
        return NextResponse.json(
            { error: "Internal Server Error" },
            { status: 500 }
        );
    }
}
