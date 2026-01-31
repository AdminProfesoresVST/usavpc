/**
 * Interview Configuration - Weighted Consular Interview Algorithm
 * 
 * This file defines the deterministic scoring system that imitates
 * real US consular officer behavior for B1/B2 visa interviews.
 * 
 * Based on Section 214(b) of the Immigration and Nationality Act:
 * "Every applicant is presumed to be an intending immigrant until
 * they prove strong ties to their home country."
 */

export interface CategoryConfig {
    weight: number;
    order: number;
    critical: boolean;
    goodBonus: number;
    badPenalty: number;
    keywords: string[];
}

export interface InterviewConfig {
    STARTING_SCORE: number;
    APPROVAL_THRESHOLD: number;
    DENIAL_THRESHOLD: number;
    MIN_QUESTIONS_FOR_DECISION: number;
    CATEGORIES: Record<string, CategoryConfig>;
    TIPS: Record<string, string>;
    QUESTIONS: Record<string, { es: string; en: string }>;
}

export const INTERVIEW_CONFIG: InterviewConfig = {
    // Score Configuration
    STARTING_SCORE: 50,
    APPROVAL_THRESHOLD: 70,
    DENIAL_THRESHOLD: 30,
    MIN_QUESTIONS_FOR_DECISION: 5,

    // Category Weights and Penalties
    CATEGORIES: {
        PURPOSE: {
            weight: 15,
            order: 1,
            critical: false,
            goodBonus: 10,
            badPenalty: -5,
            keywords: ['vacaciones', 'turismo', 'negocios', 'visitar', 'familia', 'tourism', 'business', 'vacation'],
        },
        DURATION: {
            weight: 10,
            order: 2,
            critical: true, // >6 months triggers critical failure
            goodBonus: 8,
            badPenalty: -10,
            keywords: ['días', 'semanas', 'weeks', 'days', 'marzo', 'abril', 'regreso'],
        },
        FUNDING: {
            weight: 25,
            order: 3,
            critical: true, // No job + no savings = critical failure
            goodBonus: 15,
            badPenalty: -20,
            keywords: ['trabajo', 'empresa', 'salario', 'ahorros', 'job', 'salary', 'savings', 'income', 'engineer', 'doctor'],
        },
        TRAVEL_HISTORY: {
            weight: 10,
            order: 4,
            critical: false,
            goodBonus: 8,
            badPenalty: -5,
            keywords: ['viajé', 'europa', 'visité', 'traveled', 'visited', 'passport', 'stamps'],
        },
        FAMILY_TIES: {
            weight: 25,
            order: 5,
            critical: true, // No ties = critical failure
            goodBonus: 15,
            badPenalty: -15,
            keywords: ['esposa', 'hijos', 'familia', 'casa', 'propiedad', 'wife', 'children', 'family', 'house', 'property'],
        },
        ACCOMMODATION: {
            weight: 10,
            order: 6,
            critical: false,
            goodBonus: 5,
            badPenalty: -3,
            keywords: ['hotel', 'airbnb', 'reservación', 'dirección', 'address', 'booking', 'staying'],
        },
        RETURN_PLANS: {
            weight: 5,
            order: 7,
            critical: false,
            goodBonus: 5,
            badPenalty: -5,
            keywords: ['regresar', 'boleto', 'trabajo el lunes', 'escuela', 'return', 'ticket', 'work on monday'],
        },
    },

    // Tips with Concrete Examples (MANDATORY format)
    TIPS: {
        PURPOSE: "💡 Tip: Menciona el motivo y duración. Por ejemplo: 'Voy 10 días a Disney con mi familia para celebrar el cumpleaños de mi hijo.'",
        DURATION: "💡 Tip: Da fechas exactas. Por ejemplo: 'Del 15 al 25 de marzo, 10 días. Ya tengo boleto de regreso.'",
        FUNDING: "💡 Tip: Menciona tu trabajo y ahorros. Por ejemplo: 'Soy ingeniero con 5 años en mi empresa, gano $3,000 al mes y tengo $5,000 ahorrados para el viaje.'",
        TRAVEL_HISTORY: "💡 Tip: Menciona viajes anteriores. Por ejemplo: 'He viajado a Europa 3 veces y siempre regresé a tiempo.'",
        FAMILY_TIES: "💡 Tip: Menciona vínculos en tu país. Por ejemplo: 'Mi esposa y 2 hijos se quedan aquí, tenemos casa propia y mis hijos están en la escuela.'",
        ACCOMMODATION: "💡 Tip: Nombra el hotel o dirección. Por ejemplo: 'Me hospedo en el Holiday Inn de Orlando, ya tengo reservación confirmada.'",
        RETURN_PLANS: "💡 Tip: Menciona compromisos de regreso. Por ejemplo: 'Debo regresar porque trabajo el lunes 26 y mis hijos tienen exámenes esa semana.'",
    },

    // Consular Questions (Short, Direct - Max 15 words)
    QUESTIONS: {
        PURPOSE: {
            es: "¿Cuál es el propósito de su viaje a Estados Unidos?",
            en: "What is the purpose of your trip to the United States?",
        },
        DURATION: {
            es: "¿Cuánto tiempo planea quedarse?",
            en: "How long do you plan to stay?",
        },
        FUNDING: {
            es: "¿Quién paga este viaje y cuál es su trabajo?",
            en: "Who is paying for this trip and what is your job?",
        },
        TRAVEL_HISTORY: {
            es: "¿Ha viajado al exterior antes?",
            en: "Have you traveled abroad before?",
        },
        FAMILY_TIES: {
            es: "¿Tiene familia que se queda en su país?",
            en: "Do you have family staying in your country?",
        },
        ACCOMMODATION: {
            es: "¿Dónde se va a hospedar?",
            en: "Where will you be staying?",
        },
        RETURN_PLANS: {
            es: "¿Por qué debe regresar a su país?",
            en: "Why must you return to your country?",
        },
    },
};

/**
 * Calculates the score delta based on the answer and category.
 * Uses simple keyword matching for quick evaluation.
 */
export function evaluateAnswer(
    answer: string,
    category: keyof typeof INTERVIEW_CONFIG.CATEGORIES
): { scoreDelta: number; quality: 'good' | 'bad' | 'neutral' } {
    const config = INTERVIEW_CONFIG.CATEGORIES[category];
    const lowerAnswer = answer.toLowerCase();

    // Count matching keywords
    const matchedKeywords = config.keywords.filter(kw => lowerAnswer.includes(kw.toLowerCase()));

    if (matchedKeywords.length >= 2) {
        return { scoreDelta: config.goodBonus, quality: 'good' };
    } else if (matchedKeywords.length === 1) {
        return { scoreDelta: Math.floor(config.goodBonus / 2), quality: 'neutral' };
    } else if (lowerAnswer.length < 10) {
        // Very short/vague answer
        return { scoreDelta: config.badPenalty, quality: 'bad' };
    }

    return { scoreDelta: 0, quality: 'neutral' };
}

/**
 * Determines if the interview should terminate and with what verdict.
 */
export function shouldTerminate(
    currentScore: number,
    questionsAnswered: number
): { terminate: boolean; verdict: 'APPROVED' | 'DENIED' | null } {
    const { APPROVAL_THRESHOLD, DENIAL_THRESHOLD, MIN_QUESTIONS_FOR_DECISION } = INTERVIEW_CONFIG;

    // Always deny if score drops too low
    if (currentScore <= DENIAL_THRESHOLD) {
        return { terminate: true, verdict: 'DENIED' };
    }

    // Approve only after minimum questions are answered
    if (questionsAnswered >= MIN_QUESTIONS_FOR_DECISION && currentScore >= APPROVAL_THRESHOLD) {
        return { terminate: true, verdict: 'APPROVED' };
    }

    return { terminate: false, verdict: null };
}

/**
 * Gets the next question category based on order and what's been asked.
 */
export function getNextCategory(
    answeredCategories: string[]
): keyof typeof INTERVIEW_CONFIG.CATEGORIES | null {
    const categories = Object.entries(INTERVIEW_CONFIG.CATEGORIES)
        .sort((a, b) => a[1].order - b[1].order);

    for (const [category] of categories) {
        if (!answeredCategories.includes(category)) {
            return category as keyof typeof INTERVIEW_CONFIG.CATEGORIES;
        }
    }

    return null; // All questions asked
}
