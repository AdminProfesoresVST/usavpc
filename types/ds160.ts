// DS-160 Payload Type Definition
// Based on the "JSON Gigante" specification from the Blueprint

export interface DS160Payload {
    application_id?: string;
    status?: string;
    // Triage Fields (Root Level)
    primary_occupation?: string;
    monthly_income?: string;
    marital_status?: string;
    triage_has_children?: string;
    triage_property?: string;

    ds160_data: {
        personal: {
            surnames: string | null;
            given_names: string | null;
            full_name_native: string | null;
            dob: string | null; // YYYY-MM-DD
            city_of_birth: string | null;
            state_of_birth: string | null;
            country_of_birth: string | null;
            nationality: string | null;
            national_id_number: string | null;
            marital_status: 'SINGLE' | 'MARRIED' | 'DIVORCED' | 'WIDOWED' | null;
            spouse?: {
                surnames: string;
                given_names: string;
                dob: string;
                nationality: string;
            };
        };
        travel: {
            purpose_code: string | null; // e.g., 'B1/B2'
            intended_arrival_date: string | null;
            stay_length_value: number | null;
            stay_length_unit: 'DAYS' | 'WEEKS' | 'MONTHS' | null;
            us_address: {
                street: string | null;
                city: string | null;
                state: string | null;
                zip: string | null;
            };
            paying_entity: 'SELF' | 'OTHER_PERSON' | 'ORGANIZATION' | null;
        };
        work_history: {
            current_job: {
                employer_name: string | null;
                job_title_raw_es: string | null;
                job_title_translated_en: string | null; // AI Generated
                start_date: string | null;
                monthly_income_local_currency: number | null;
                duties_raw_es: string | null;
                duties_formatted_en: string | null; // AI Generated
                address: {
                    street: string | null;
                    city: string | null;
                    state: string | null;
                    country: string | null;
                };
            };
            previous_jobs: Array<{
                employer_name: string;
                job_title: string;
                start_date: string;
                end_date: string;
                duties: string;
            }>;
        };
        security_questions: {
            [key: string]: 'YES' | 'NO' | null; // q1_disease, q2_criminal, etc.
        } & {
            user_confirmed_all_no: boolean;
        };
        // Add other sections (Family, Passport, etc.) as needed
    };
}

export type ApplicationStatus =
    | 'draft'
    | 'paid_pending_review'
    | 'in_review_human'
    | 'submitted_ceac'
    | 'completed_delivered'
    | 'on_hold_client_action';
