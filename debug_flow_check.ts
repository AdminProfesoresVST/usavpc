
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;
const supabase = createClient(supabaseUrl, supabaseKey);

// MOCK payload from the DB finding
const payload = {
    "ds160_data": {
        "travel": { "purpose_code": "B2" },
        "contact": {
            "phone_work": "N/A",
            "home_address": "Does Not Apply",
            "mailing_same": "Does Not Apply",
            "email_address": "osiris.villacampa@gmail.com",
            "phone_primary": "Does Not Apply",
            "phone_secondary": "Does Not Apply",
            "social_media_check": "villacampast"
        },
        "passport": {
            "passport_type": "R",
            "expiration_date": "2021-01-09",
            "passport_issuer": "DOM",
            "passport_number": "SC4260875",
            "passport_book_num": "Does Not Apply"
        },
        "personal": {
            "dob": "1976-05-17",
            "sex": "M",
            "spouse": { "dob": "1976-07-21", "surnames": "CAMASTA ISSA", "given_names": "CAROLINA" },
            "us_ssn": "Does not apply",
            "pob_city": "Santo Domingo",
            "surnames": "VILLACAMPA RECIO",
            "pob_state": "Santo Domingo",
            "us_tax_id": "no tengo",
            "given_names": "OSIRIS",
            "national_id": "00201137205",
            "nationality": "DOM",
            "native_name": "OSIRIS",
            "pob_country": "República Dominicana",
            "telecode_name": "no",
            "marital_status": "M",
            "other_names_used": "no",
            "other_nationality": "No",
            "perm_resident_other": "No"
        },
        "work_history": {
            "current_job": {
                "duties": "I am a robotics engineer, teach classes, and also run my own company."
            },
            "previous_jobs": []
        },
        "security_questions": {}
    },
    "has_refusals": false,
    "monthly_income": "800MIL PESOS",
    "triage_property": "SI",
    "primary_occupation": "tourism"
};

async function getDeepValue(obj: any, path: string): Promise<any> {
    return path.split('.').reduce((acc, part) => acc && acc[part], obj);
}

async function run() {
    console.log("Fetching steps...");
    const { data: steps, error } = await supabase
        .from('ai_interview_flow')
        .select('*')
        .order('order_index', { ascending: true });

    if (error) {
        console.error("DB Error:", error);
        return;
    }

    console.log(`Found ${steps.length} steps.`);

    for (const step of steps) {
        console.log(`\n--- Step: ${step.field_key} (${step.question_es}) ---`);

        // 1. Check Logic
        let shouldAsk = true;
        if (step.required_logic) {
            const { field, operator, value } = step.required_logic;
            const actualValue = await getDeepValue(payload, field);
            console.log(`Logic Check: ${field} == ${actualValue}. Required: ${operator} ${value}`);

            if (operator === 'eq' && actualValue !== value) shouldAsk = false;
            if (operator === 'neq' && actualValue === value) shouldAsk = false;
        }

        if (!shouldAsk) {
            console.log("-> SKIPPING (Logic false)");
            continue;
        }

        // 2. Check Answered
        const currentValue = await getDeepValue(payload, step.field_key);
        console.log(`Current Value: '${currentValue}'`);

        if (currentValue !== null && currentValue !== undefined && currentValue !== '') {
            console.log("-> SKIPPING (Already Answered)");
            continue;
        }

        // 3. Auto Answer
        if (step.field_key.includes('passport_book_num')) {
            console.log("-> WOULD AUTO ANSWER: Does Not Apply");
            // In real app, this continues.
            continue;
        }

        console.log(">>> THIS IS THE NEXT QUESTION! <<<");
        console.log(step);
        return;
    }

    console.log("All steps completed.");
}

run();
