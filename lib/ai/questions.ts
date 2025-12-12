export const FALLBACK_QUESTIONS = [
    {
        field: 'ds160_data.personal.marital_status',
        question: '¿Cuál es tu estado civil actual?',
        question_en: 'What is your marital status?',
        input_type: 'select',
        options: [
            { label: "Soltero/a", value: "S" },
            { label: "Casado/a", value: "M" },
            { label: "Unión Libre", value: "L" },
            { label: "Divorciado/a", value: "D" },
            { label: "Viudo/a", value: "W" }
        ],
        context: null
    },
    {
        field: 'spouse_details',
        question: 'Cuéntame sobre tu pareja: Nombre completo y fecha de nacimiento.',
        question_en: 'Tell me about your spouse: Full name and DOB.',
        input_type: 'text',
        options: null,
        context: 'spouse_parser',
        logic: { field: "ds160_data.personal.marital_status", operator: "eq", value: "M" }
    },
    {
        field: 'primary_occupation',
        question: '¿A qué te dedicas? (Ej: "Soy ingeniero y trabajo en Google" o "Tengo una tienda de ropa")',
        question_en: 'What do you do for work?',
        input_type: 'text',
        options: null,
        context: 'needs_translation' // Uses JOB_TRANSLATOR
    },
    {
        field: 'ds160_data.work_history.current_job.duties',
        question: 'Explica qué haces en un día normal de trabajo (Tus responsabilidades principales).',
        question_en: 'Explain your main duties at work.',
        input_type: 'text',
        options: null,
        context: 'polish_content' // Uses CONTENT_POLISHER
    },
    {
        field: 'monthly_income',
        question: '¿Cuál es tu ingreso mensual aproximado en dólares (USD)?',
        question_en: 'What is your approximate monthly income in USD?',
        input_type: 'text',
        options: null,
        context: null
    },
    {
        field: 'ds160_data.travel.purpose_code',
        question: '¿Cuál es el motivo principal de tu viaje a EE.UU.?',
        question_en: 'What is the main purpose of your trip?',
        input_type: 'select',
        options: [
            { label: "Turismo / Vacaciones", value: "B2" },
            { label: "Negocios / Conferencias", value: "B1" },
            { label: "Tratamiento Médico", value: "B2" }
        ],
        context: null
    },
    {
        field: 'triage_property',
        question: '¿Tienes alguna propiedad a tu nombre? (Casa, terreno, departamento)',
        question_en: 'Do you own any property?',
        input_type: 'boolean',
        options: null,
        context: null
    }
];
