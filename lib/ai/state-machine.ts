import { DS160Payload } from "@/types/ds160";
import { SupabaseClient } from "@supabase/supabase-js";

export interface QuestionState {
    field: string;
    question: string;
    type: 'text' | 'select' | 'date' | 'boolean';
    options?: { label: string; value: string }[];
    context?: string;
}

interface FlowStep {
    id: string;
    field_key: string;
    question_es: string;
    input_type: string;
    options: any;
    context: string;
    required_logic: { field: string; operator: string; value: any } | null;
}

export class DS160StateMachine {
    private payload: DS160Payload;
    private supabase: SupabaseClient;
    private locale: string;

    constructor(payload: DS160Payload, supabase: SupabaseClient, locale: string = 'es') {
        this.payload = payload;
        this.supabase = supabase;
        this.locale = locale;
    }

    public async getNextStep(): Promise<QuestionState | null> {
        // 1. Fetch Flow Definition (Cached in real app, here we fetch)
        const { data: steps, error } = await this.supabase
            .from('ai_interview_flow')
            .select('*')
            .order('order_index', { ascending: true });

        if (error || !steps) {
            console.error("Failed to fetch flow", error);
            return null;
        }

        // 2. Iterate and find first missing field
        for (const step of steps) {
            if (this.shouldAsk(step)) {
                // Determine question based on locale
                let questionText = step.question_es; // Default fallback matches source of truth

                if (this.locale === 'en' && step.question_en) questionText = step.question_en;
                else if (this.locale === 'fr' && step.question_fr) questionText = step.question_fr;
                else if (this.locale === 'cn' && step.question_cn) questionText = step.question_cn;
                else if (this.locale === 'pt' && step.question_pt) questionText = step.question_pt;
                else if (this.locale === 'hi' && step.question_hi) questionText = step.question_hi;

                return {
                    field: step.field_key,
                    question: questionText,
                    type: step.input_type as any,
                    options: step.options,
                    context: step.context
                };
            }
        }

        return null; // All done
    }

    private shouldAsk(step: FlowStep): boolean {
        // A. Check Logic Conditions (Dependencies)
        if (step.required_logic) {
            const { field, operator, value } = step.required_logic;
            const actualValue = this.getDeepValue(this.payload, field);

            if (operator === 'eq' && actualValue !== value) return false;
            if (operator === 'neq' && actualValue === value) return false;
            // Add more operators as needed
        }

        // B. Check if already answered
        const currentValue = this.getDeepValue(this.payload, step.field_key);

        // Special handling for composite fields (like spouse)
        if (step.context === 'spouse_parser') {
            // Check if spouse object is fully populated
            const spouse = currentValue;
            if (spouse && spouse.surnames && spouse.given_names && spouse.dob) return false; // Done
            return true; // Ask
        }

        // Standard check: is it null/undefined/empty?
        if (currentValue === null || currentValue === undefined || currentValue === '') return true;

        return false; // Already answered
    }

    private getDeepValue(obj: any, path: string): any {
        return path.split('.').reduce((acc, part) => acc && acc[part], obj);
    }

    public async saveAnswer(userId: string, field: string, value: any): Promise<void> {
        // 1. Update local payload
        const keys = field.split('.');
        let current: any = this.payload;
        for (let i = 0; i < keys.length - 1; i++) {
            if (!current[keys[i]]) current[keys[i]] = {};
            current = current[keys[i]];
        }
        current[keys[keys.length - 1]] = value;

        // 2. Persist to DB
        const { error } = await this.supabase
            .from('applications')
            .update({ ds160_payload: this.payload })
            .eq('user_id', userId);

        if (error) console.error("Failed to save answer", error);
    }
}
