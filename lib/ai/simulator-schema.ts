import { z } from 'zod';

export const simulatorSchema = z.object({
    // Internal State & Reasoning
    reasoning: z.string().describe("Step-by-step logic for the next question or verdict."),
    known_data: z.object({}).catchall(z.string().nullable()).optional().describe("Map of data points gathered (e.g., job: 'Engineer')."),
    // Cognitive Core Fields (The "Brain")
    internal_monologue: z.string().describe("PRIVATE: Your internal thought process. Analyze inconsistencies, 214(b) risks, and truthfulness."),
    suspicion_level: z.number().describe("PRIVATE: Current suspicion level (0-100). Increases with vague answers."),
    is_lying: z.boolean().describe("PRIVATE: Do you suspect the applicant is lying?"),

    // Public Output
    suggestion: z.string().describe("Pre-answer tip for the user. Example: 'Tip: Mention your ties.'"),
    response: z.string().describe("The verbal question or verdict to the applicant."),
    feedback: z.string().describe("Coach's tip (Lightbulb)."),
    score_delta: z.number().describe("Points to add/subtract from score (-10 to +10)."),
    action: z.enum(["CONTINUE", "TERMINATE_APPROVED", "TERMINATE_DENIED"]).describe("Whether to stop or continue."),
    current_score: z.number().optional().describe("The new calculated score (0-100).")
});

export type SimulatorOutput = z.infer<typeof simulatorSchema>;
