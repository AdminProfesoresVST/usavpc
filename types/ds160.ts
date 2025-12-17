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
    has_refusals?: boolean;
    has_previous_visa?: boolean;

    ds160_data: {
        personal: {
            surnames: string | null;
            given_names: string | null;
            full_name_native: string | null;
            other_names_used: boolean | null;
            other_names_list: string | null;
            telecode_name: boolean | null;
            sex: 'M' | 'F' | null;
            dob: string | null; // YYYY-MM-DD
            city_of_birth: string | null;
            state_of_birth: string | null;
            country_of_birth: string | null;
            nationality: string | null;
            other_nationality: boolean | null;
            other_nationality_details: string | null;
            perm_resident_other: boolean | null;
            national_id_number: string | null;
            us_ssn: string | null;
            us_tax_id: string | null;
            marital_status: 'SINGLE' | 'MARRIED' | 'DIVORCED' | 'WIDOWED' | null;
            spouse?: {
                surnames: string;
                given_names: string;
                dob: string;
                nationality: string;
                pob_city: string;
                pob_country: string;
                address: string;
            };
        };
        contact: {
            home_address: string | null;
            mailing_same: boolean | null;
            mailing_address: string | null;
            phone_primary: string | null;
            phone_secondary: string | null;
            phone_work: string | null;
            other_phones: string | null;
            email_address: string | null;
            other_emails: string | null;
            social_media: string | null;
        };
        passport: {
            passport_type: string | null;
            passport_number: string | null;
            passport_book_num: string | null;
            passport_issuer: string | null;
            passport_issue_city: string | null;
            passport_dates: string | null;
            lost_passport: string | null;
        };
        travel: {
            purpose_code: string | null; // e.g., 'B1/B2'
            travel_plans: string | null;
            intended_arrival_date: string | null;
            stay_length_value: number | null;
            stay_length_unit: 'DAYS' | 'WEEKS' | 'MONTHS' | null;
            us_address: {
                street: string | null;
                city: string | null;
                state: string | null;
                zip: string | null;
            } | string | null; // Allow string for simple text input
            paying_entity: 'SELF' | 'OTHER_PERSON' | 'ORGANIZATION' | null;
            travel_companions: string | null;
        };
        previous_travel: {
            previous_us_travel: string | null;
            us_driver_license: string | null;
            previous_us_visa: string | null;
            visa_refusal: string | null;
            immigrant_petition: boolean | null;
        };
        us_contact: {
            us_point_of_contact: string | null;
        };
        family: {
            father_info: string | null;
            mother_info: string | null;
            immediate_relatives: string | null;
            other_relatives: boolean | null;
        };
        work_history: {
            current_job: {
                employer_name: string | null;
                employer_info: string | null; // Combined address/phone
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
                } | null;
            };
            previous_jobs: Array<{
                employer_name: string;
                job_title: string;
                start_date: string;
                end_date: string;
                duties: string;
            }>;
            education: string | null;
        };
        security_misc: {
            additional_questions: string | null;
        };
        security_questions: {
            [key: string]: 'YES' | 'NO' | null | undefined; // q1_disease, q2_criminal, etc.
            security_health?: 'YES' | 'NO' | null;
            security_criminal?: 'YES' | 'NO' | null;
            security_security?: 'YES' | 'NO' | null;
            security_immigration?: 'YES' | 'NO' | null;
            security_other?: 'YES' | 'NO' | null;
        } & {
            user_confirmed_all_no: boolean;
        };
    };
}

export type ApplicationStatus =
    | 'draft'
    | 'paid_pending_review'
    | 'in_review_human'
    | 'submitted_ceac'
    | 'completed_delivered'
    | 'on_hold_client_action';
