
import { OpenAI } from "openai";
import dotenv from "dotenv";
import path from "path";

// Load environment variables
dotenv.config({ path: path.resolve(process.cwd(), ".env.local") });

const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

const VALIDATOR_PROMPT_TEMPLATE = `You are a JSON Utility.
Your ONLY job is to normalize the user input.

INPUT: User Input: "{input}"
QUESTION Context: "{question}"

LOGIC:
1. extractedValue = Input normalized (UPPERCASE for text, YYYY-MM-DD for dates).
2. isValid = true.
3. EXCEPTION: If Input is explicitly "I refuse", "No quiero", "Skip" -> isValid = false.
4. EXCEPTION: If Input is "No sé", "Unknown" -> isValid = false.

OUTPUT JSON format:
{
  "isValid": boolean,
  "refusalMessage": "string" (only if invalid),
  "extractedValue": "string",
  "english_proficiency": "N/A",
  "sentiment": "Neutral",
  "isHelpRequest": false,
  "helpResponse": ""
}`;

async function testValidation(question: string, input: string) {
    console.log(`\n--- Testing Input: "${input}" against Question: "${question}" ---`);

    const prompt = VALIDATOR_PROMPT_TEMPLATE
        .replace('{question}', question)
        .replace('{input}', input);

    try {
        const completion = await openai.chat.completions.create({
            model: "gpt-4o-mini",
            messages: [
                { role: "system", content: prompt }
            ],
            response_format: { type: "json_object" }
        });

        const result = JSON.parse(completion.choices[0].message.content || '{}');
        console.log("Result:", JSON.stringify(result, null, 2));

        if (result.isValid) {
            console.log("✅ PASSED");
        } else {
            console.log("❌ FAILED (Refusal: " + result.refusalMessage + ")");
        }
    } catch (e) {
        console.error("Error:", e);
    }
}

async function main() {
    await testValidation("What is your spouse's surname?", "camasta issa");
    await testValidation("What is your spouse's surname?", "no tengo idea");
    await testValidation("What is your spouse's date of birth?", "21 julio 1976");
}

main();
