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
    question_en?: string;
}

export class DS160StateMachine {
    private payload: DS160Payload;
    private supabase: SupabaseClient;
    private locale: string;
    private userId: string | null;

    constructor(payload: DS160Payload, supabase: SupabaseClient, locale: string = 'es', userId: string | null = null) {
        this.payload = payload;
        this.supabase = supabase;
        this.locale = locale;
        this.userId = userId;
    }

    public async getNextStep(): Promise<QuestionState | null> {
        // 1. Fetch Flow Definition
        let steps: FlowStep[] = [];
        const { data, error } = await this.supabase
            .from('ai_interview_flow')
            .select('*')
            .order('order_index', { ascending: true });

        if (error || !data || data.length === 0) {
            // STRICT MODE: NO FALLBACKS allowed per Global Rules.
            // "The application must not start if the database does not contain the master dataset."
            console.error("CRITICAL: No interview flow found in DB.");
            throw new Error("CRITICAL_DATA_MISSING: The 'ai_interview_flow' table is empty. Seeding required.");
        } else {
            steps = data;
        }

        // 2. Iterate and find first missing field
        for (const step of steps) {
            // A. Check Logic (Skip if logic says so)
            if (!this.shouldAsk(step)) continue;

            // B. Check if already answered
            if (this.isAnswered(step)) continue;

            // C. SMART DEFAULTS
            const autoValue = this.getAutoAnswer(step.field_key);
            if (autoValue !== null && this.userId) {
                // Auto-save and skip to next iteration
                await this.saveAnswer(this.userId, step.field_key, autoValue);
                continue;
            }

            // Determine question based on locale
            let questionText = step.question_es;
            if (this.locale === 'en' && step.question_en) questionText = step.question_en;

            // Facilitator Touch (SSN Logic)
            if (step.field_key.includes('us_ssn') || step.field_key.includes('us_tax_id')) {
                const nat = this.getDeepValue(this.payload, 'ds160_data.personal.nationality');
                const isUS = nat && (nat.toLowerCase().includes('united states') || nat.toLowerCase().includes('usa') || nat.toLowerCase().includes('eeuu'));
                if (!isUS) {
                    const prefix = this.locale === 'es' ? "Como no-ciudadano, esto suele no aplicar. ¿Tienes SSN de EE.UU.? " : "As non-citizen, usually N/A. Do you have a US SSN? ";
                    const suffix = this.locale === 'es' ? "(Si no, di 'No')" : "(If not, say 'No')";
                    questionText = prefix + suffix;
                }
            }

            // SMART REPHRASING: Passport Type explanation
            if (step.field_key.includes('document_type')) {
                const prefix = this.locale === 'es'
                    ? "Para la mayoría es 'Regular'. "
                    : "For most people, it's 'Regular'. ";
                questionText = prefix + questionText;
            }

            return {
                field: step.field_key,
                question: questionText,
                type: step.input_type as any,
                options: step.options,
                context: step.context
            };
        }

        return null; // All done
    }

    private getAutoAnswer(field: string): any | null {
        // SMART DEFAULTS REMOVED FOR PASSPORT TYPE (User request: Ask explicitly)
        // if (field.includes('ds160_data.passport.passport_type')) return 'R';

        // 2. Passport Book Number -> ALWAYS 'Does Not Apply' (Emergency Unblock)
        // User friction is too high. 99% of cases it is N/A.
        if (field.includes('passport_book_num') || field.includes('book_number')) {
            return "Does Not Apply";
        }

        // 3. Passport Issuer -> Default to Nationality
        if (field.includes('passport_issuer') || field.includes('issuing_country')) {
            const nationality = this.getDeepValue(this.payload, 'ds160_data.personal.nationality');
            if (nationality) return nationality;
        }

        return null;
    }

    private shouldAsk(step: FlowStep): boolean {
        if (step.required_logic) {
            const { field, operator, value } = step.required_logic;
            const actualValue = this.getDeepValue(this.payload, field);
            if (operator === 'eq' && actualValue !== value) return false;
            if (operator === 'neq' && actualValue === value) return false;
        }
        return true;
    }

    private isAnswered(step: FlowStep): boolean {
        const currentValue = this.getDeepValue(this.payload, step.field_key);

        if (step.context === 'spouse_parser') {
            const spouse = currentValue;
            if (spouse && spouse.surnames && spouse.given_names && spouse.dob) return true;
            return false;
        }

        if (currentValue === null || currentValue === undefined || currentValue === '') return false;
        return true;
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
