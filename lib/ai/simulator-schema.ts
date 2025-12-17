import { z } from 'zod';

export const simulatorSchema = z.object({
    reasoning: z.string().describe("Step-by-step logic for the next question or verdict."),
    known_data: z.object({}).catchall(z.string().nullable()).describe("Map of data points gathered (e.g., job: 'Engineer')."),
    response: z.string().describe("The verbal response or question to the user."),
    feedback: z.string().describe("REQUIRED. Coach feedback explaining the score change AND providing a specific recommendation."),
    score_delta: z.number().describe("Points to add/subtract from score (-10 to +10)."),
    action: z.enum(["CONTINUE", "TERMINATE_APPROVED", "TERMINATE_DENIED"]).describe("Whether to stop or continue."),
    current_score: z.number().optional().describe("The new calculated score (0-100).")
});

export type SimulatorOutput = z.infer<typeof simulatorSchema>;
