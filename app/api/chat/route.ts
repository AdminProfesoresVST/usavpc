import { OpenAI } from "openai";
import { NextResponse } from "next/server";

const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

const SYSTEM_PROMPT = `You are a Consular Officer assistant for the US Visa Processing Center. 
Your goal is to help users complete their DS-160 application data gathering.
You must:
1. Act with authority and professionalism (GovTech persona).
2. Ask one question at a time to gather necessary information (Citizenship, Purpose of Travel, Employment, etc.).
3. If the user replies in Spanish, understand it perfectly but reply in English, and internally note the translation for the form.
4. If the user provides informal input (e.g., "work in construction"), clarify and suggest the formal DS-160 term (e.g., "Construction Worker / Mason").

Current Phase: Eligibility & Strategy Review (Tripwire).
Ask 5 key questions:
1. Nationality/Citizenship?
2. Primary purpose of travel?
3. Current employment status?
4. Have you ever been denied a US visa?
5. Estimated monthly income?

After gathering these, inform the user that their "VisaScore" is ready to be calculated and they should proceed to the next step (which will be the paywall).
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
            temperature: 0.3, // Low temperature for consistent, formal responses
        });

        const reply = completion.choices[0].message.content;

        return NextResponse.json({ role: "assistant", content: reply });
    } catch (error) {
        console.error("OpenAI API Error:", error);
        return NextResponse.json(
            { error: "Internal Server Error" },
            { status: 500 }
        );
    }
}
