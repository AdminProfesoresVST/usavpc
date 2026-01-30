
import { createClient } from '@supabase/supabase-js';
import { DS160StateMachine } from './lib/ai/state-machine';

// Mock env
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY!; // Use service role to bypass auth

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function verify() {
    console.log("Verifying Question Text...");

    // 1. Fetch directly from DB
    const { data: dbData } = await supabase
        .from('ai_interview_flow')
        .select('question_es')
        .eq('field_key', 'ds160_data.personal.surnames')
        .single();

    console.log("DB Text:", dbData?.question_es);

    // 2. Instantiate State Machine (mock payload)
    const payload = {
        ds160_data: {
            personal: {}, // Empty, so Surnames should be first (or close to first)
            travel: {},
            work_history: {},
            security_questions: {}
        }
    };

    // Check if Surnames is 1st question (index 101)
    // Actually surnames is usually first.

    const sm = new DS160StateMachine(payload as any, supabase, 'es', 'test-user');
    const step = await sm.getNextStep();

    console.log("SM Next Step:", step?.field);
    console.log("SM Question Text:", step?.question);

    if (step?.question.includes("Copia tus apellidos")) {
        console.log("SUCCESS: Backend is serving new text.");
    } else {
        console.error("FAILURE: Backend serving old text.");
    }
}

verify();
