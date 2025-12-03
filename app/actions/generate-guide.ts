"use server";

import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { OpenAI } from "openai";

const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

export async function generateInterviewGuide(applicationId: string) {
    const cookieStore = await cookies();
    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) { return cookieStore.get(name)?.value; },
                set(name: string, value: string, options: CookieOptions) { cookieStore.set({ name, value, ...options }); },
                remove(name: string, options: CookieOptions) { cookieStore.set({ name, value: "", ...options }); },
            },
        }
    );

    // Fetch Data
    const { data: app, error } = await supabase
        .from("applications")
        .select("*")
        .eq("id", applicationId)
        .single();

    if (error || !app) throw new Error("Application not found");

    // Generate Guide
    const prompt = `
    You are an expert US Visa Consultant. Based on the applicant's profile and risk assessment, generate a personalized Interview Preparation Guide.
    
    Profile: ${JSON.stringify(app.ds160_payload)}
    Risk Assessment: ${JSON.stringify(app.risk_assessment)}

    Output Format: Markdown.
    Include:
    1. Document Checklist (Specific to their case).
    2. Likely Interview Questions (Based on their job, travel purpose, etc.).
    3. Tips for addressing specific risks identified.
    4. Dress code and etiquette advice.
    `;

    const completion = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [{ role: "system", content: prompt }]
    });

    const guide = completion.choices[0].message.content || "";

    // Save
    await supabase
        .from("applications")
        .update({ interview_guide: guide })
        .eq("id", applicationId);

    return { success: true, guide };
}
