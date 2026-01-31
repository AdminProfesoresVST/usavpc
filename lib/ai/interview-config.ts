/**
 * Advanced Consular Interview Algorithm
 * 
 * Based on 9 FAM 401.1 (Non-Immigrant Visas) and Section 214(b) of the INA:
 * "Every alien shall be presumed to be an immigrant until they establish
 * that they are entitled to a non-immigrant status."
 * 
 * This implements a probabilistic decision matrix for visa adjudication.
 */

// ============================================================================
// SCORING VARIABLES (Immigration Probability Matrix)
// ============================================================================

export interface ScoringVariables {
    /** V_e: Economic Ties = (Salary / Trip Cost) × Work Tenure */
    economicTies: number;
    /** V_s: Social Ties = (Family in Origin) - (Family in USA) */
    socialTies: number;
    /** V_h: Travel History = (OECD Countries Visited) / Passport Age */
    travelHistory: number;
    /** V_c: Verbal Congruence = DS-160 Data matches Oral Response */
    verbalCongruence: number;
}

export interface ApplicantProfile {
    age: number;
    maritalStatus: 'single' | 'married' | 'divorced' | 'widowed';
    occupation: string;
    monthlySalaryUSD: number;
    tripCostUSD: number;
    workTenureYears: number;
    familyInOrigin: number; // spouse, children, dependents
    familyInUSA: number;
    countriesVisited: number;
    passportAgeYears: number;
    ownsProperty: boolean;
    hasReturnTicket: boolean;
    tripDurationDays: number;
    originCountry: string;
}

// ============================================================================
// COUNTRY RISK FACTORS (Riesgo País)
// ============================================================================

export const COUNTRY_RISK_FACTORS: Record<string, number> = {
    // ============================================================================
    // VERY HIGH RISK (1.5x-1.6x) - Countries with highest denial rates
    // ============================================================================
    'Haiti': 1.6,
    'Somalia': 1.6,
    'Yemen': 1.6,
    'Syria': 1.6,
    'Afghanistan': 1.6,
    'Honduras': 1.5,
    'Guatemala': 1.5,
    'El Salvador': 1.5,
    'Eritrea': 1.5,
    'Sudan': 1.5,
    'Libya': 1.5,
    'Iraq': 1.5,

    // ============================================================================
    // HIGH RISK (1.3x-1.4x) - Countries with high denial rates
    // ============================================================================
    'Venezuela': 1.4,
    'Nicaragua': 1.4,
    'Cuba': 1.4,
    'Iran': 1.4,
    'Pakistan': 1.4,
    'Bangladesh': 1.4,
    'Nigeria': 1.4,
    'Ecuador': 1.3,
    'Bolivia': 1.3,
    'Cameroon': 1.3,
    'Ghana': 1.3,
    'Senegal': 1.3,
    'Ethiopia': 1.3,
    'Nepal': 1.3,
    'Myanmar': 1.3,

    // ============================================================================
    // MEDIUM-HIGH RISK (1.2x) - Countries with elevated denial rates
    // ============================================================================
    'Mexico': 1.2,
    'Dominican Republic': 1.2,
    'Colombia': 1.2,
    'Peru': 1.2,
    'Jamaica': 1.2,
    'Trinidad and Tobago': 1.2,
    'Guyana': 1.2,
    'Suriname': 1.2,
    'India': 1.2,
    'Philippines': 1.2,
    'Vietnam': 1.2,
    'Egypt': 1.2,
    'Morocco': 1.2,
    'Tunisia': 1.2,
    'Algeria': 1.2,
    'Kenya': 1.2,
    'Uganda': 1.2,
    'Tanzania': 1.2,

    // ============================================================================
    // MEDIUM RISK (1.1x) - Countries with moderate denial rates
    // ============================================================================
    'Brazil': 1.1,
    'Paraguay': 1.1,
    'Panama': 1.1,
    'Belize': 1.1,
    'Barbados': 1.1,
    'Bahamas': 1.1,
    'Thailand': 1.1,
    'Indonesia': 1.1,
    'Malaysia': 1.1,
    'China': 1.1,
    'Turkey': 1.1,
    'Russia': 1.1,
    'Ukraine': 1.1,
    'South Africa': 1.1,
    'Lebanon': 1.1,
    'Jordan': 1.1,

    // ============================================================================
    // LOW RISK (1.0x) - Baseline countries
    // ============================================================================
    'Argentina': 1.0,
    'Chile': 1.0,
    'Uruguay': 1.0,
    'Costa Rica': 1.0,
    'Poland': 1.0,
    'Hungary': 1.0,
    'Czech Republic': 1.0,
    'Slovakia': 1.0,
    'Romania': 1.0,
    'Bulgaria': 1.0,
    'Greece': 1.0,
    'Portugal': 1.0,
    'Croatia': 1.0,
    'Slovenia': 1.0,
    'Israel': 1.0,
    'South Korea': 1.0,
    'Taiwan': 1.0,
    'Singapore': 1.0,
    'United Arab Emirates': 1.0,
    'Saudi Arabia': 1.0,
    'Qatar': 1.0,

    // ============================================================================
    // VERY LOW RISK (0.8x-0.9x) - OECD & Visa Waiver countries
    // ============================================================================
    'Canada': 0.8,
    'United Kingdom': 0.8,
    'UK': 0.8,
    'Germany': 0.8,
    'France': 0.8,
    'Spain': 0.8,
    'Italy': 0.8,
    'Netherlands': 0.8,
    'Belgium': 0.8,
    'Austria': 0.8,
    'Sweden': 0.8,
    'Norway': 0.8,
    'Denmark': 0.8,
    'Finland': 0.8,
    'Ireland': 0.8,
    'Japan': 0.8,
    'Australia': 0.8,
    'New Zealand': 0.8,
    'Switzerland': 0.7,
    'Luxembourg': 0.7,
    'Iceland': 0.7,
    'Liechtenstein': 0.7,
    'Monaco': 0.7,
    'Andorra': 0.7,
};

// ============================================================================
// DECISION THRESHOLDS
// ============================================================================

export const DECISION_THRESHOLDS = {
    /** Score >= 0.6: Approved */
    APPROVAL: 0.6,
    /** Score 0.3-0.6: Pending 221(g) - Administrative Processing */
    PENDING_221G_UPPER: 0.6,
    PENDING_221G_LOWER: 0.3,
    /** Score < 0.3: Denied 214(b) */
    DENIAL: 0.3,

    /** Minimum questions before final decision */
    MIN_QUESTIONS: 5,
    /** Maximum questions before decision is forced */
    MAX_QUESTIONS: 10,
};

// ============================================================================
// HIGH RISK PROFILE INDICATORS
// ============================================================================

export const HIGH_RISK_INDICATORS = {
    /** Young + Single + No Property = +40% suspicion */
    YOUNG_SINGLE_NO_PROPERTY: { ageMax: 30, maritalStatus: 'single', ownsProperty: false, suspicionBoost: 0.4 },
    /** Low income + High trip cost = +35% suspicion */
    LOW_INCOME_HIGH_COST: { salaryRatio: 0.5, suspicionBoost: 0.35 },
    /** First time traveler = +25% suspicion */
    FIRST_TIME_TRAVELER: { countriesVisited: 0, suspicionBoost: 0.25 },
    /** Family in USA = +30% suspicion */
    FAMILY_IN_USA: { familyInUSA: 1, suspicionBoost: 0.3 },
    /** Long trip duration = +20% suspicion */
    LONG_TRIP: { daysMin: 30, suspicionBoost: 0.2 },
};

export const LOW_RISK_INDICATORS = {
    /** Married + Kids + Property = -40% suspicion */
    MARRIED_KIDS_PROPERTY: { maritalStatus: 'married', familyInOrigin: 2, ownsProperty: true, suspicionReduction: 0.4 },
    /** Long work tenure = -25% suspicion */
    STABLE_EMPLOYMENT: { workTenureYears: 5, suspicionReduction: 0.25 },
    /** OECD travel history = -30% suspicion */
    OECD_TRAVELER: { countriesVisited: 3, suspicionReduction: 0.3 },
    /** High income relative to trip = -20% suspicion */
    HIGH_INCOME: { salaryRatio: 3, suspicionReduction: 0.2 },
};

// ============================================================================
// INTERVIEW QUESTION CATEGORIES
// ============================================================================

export interface QuestionCategory {
    id: string;
    order: number;
    weight: number; // 0-1
    ds160Field: string; // Which DS-160 section this validates
    criticalFailure: boolean;
    suggestedTip: { es: string; en: string };
    goldenAnswer: { es: string; en: string };
    fraudIndicators: string[];
}

export const QUESTION_CATEGORIES: Record<string, QuestionCategory> = {
    PURPOSE: {
        id: 'PURPOSE',
        order: 1,
        weight: 0.15,
        ds160Field: 'travel.purpose',
        criticalFailure: false,
        suggestedTip: {
            es: "💡 Sé específico sobre el motivo y duración. Por ejemplo: 'Voy 10 días a Disney con mi familia para el cumpleaños de mi hijo.'",
            en: "💡 Be specific about purpose and duration. Example: 'I'm going to Disney for 10 days with my family to celebrate my son's birthday.'"
        },
        goldenAnswer: {
            es: "'Voy a Orlando por 8 días para visitar los parques de Disney. Es el cumpleaños número 10 de mi hijo. Ya tenemos reservaciones en el hotel y boletos de regreso para el 25 de marzo.'",
            en: "'I'm going to Orlando for 8 days to visit Disney parks. It's my son's 10th birthday. We already have hotel reservations and return tickets for March 25th.'"
        },
        fraudIndicators: ['trabajo', 'quedarse', 'buscar empleo', 'work', 'stay', 'looking for job']
    },
    DURATION: {
        id: 'DURATION',
        order: 2,
        weight: 0.10,
        ds160Field: 'travel.intended_length',
        criticalFailure: true, // >6 months = critical
        suggestedTip: {
            es: "💡 Da fechas exactas y menciona tu boleto de regreso. Por ejemplo: 'Del 15 al 25 de marzo, 10 días. Ya tengo boleto de regreso.'",
            en: "💡 Give exact dates and mention your return ticket. Example: 'March 15-25, 10 days. I already have my return ticket.'"
        },
        goldenAnswer: {
            es: "'Estaré 10 días, del 15 al 25 de marzo. Aquí está mi boleto de regreso confirmado con American Airlines.'",
            en: "'I'll be there for 10 days, March 15-25. Here's my confirmed return ticket with American Airlines.'"
        },
        fraudIndicators: ['indefinido', 'no sé', 'depende', 'indefinite', 'not sure', 'depends']
    },
    FUNDING: {
        id: 'FUNDING',
        order: 3,
        weight: 0.25,
        ds160Field: 'work_education.occupation',
        criticalFailure: true, // No job + no savings = critical
        suggestedTip: {
            es: "💡 Menciona tu trabajo, antigüedad e ingresos. Por ejemplo: 'Soy ingeniero con 5 años en mi empresa, gano $3,000 al mes.'",
            en: "💡 Mention your job, tenure and income. Example: 'I'm an engineer with 5 years at my company, I earn $3,000 per month.'"
        },
        goldenAnswer: {
            es: "'Soy Gerente de Proyectos en una empresa de construcción desde hace 8 años. Gano $4,500 mensuales. El viaje cuesta $3,000 y lo estoy pagando con mis ahorros. Aquí está mi carta de trabajo y mis estados de cuenta.'",
            en: "'I'm a Project Manager at a construction company for 8 years. I earn $4,500 monthly. The trip costs $3,000 and I'm paying with my savings. Here's my employment letter and bank statements.'"
        },
        fraudIndicators: ['desempleado', 'informal', 'efectivo', 'unemployed', 'cash', 'informal']
    },
    FAMILY_TIES: {
        id: 'FAMILY_TIES',
        order: 4,
        weight: 0.25,
        ds160Field: 'family.marital_status',
        criticalFailure: true, // No ties = critical
        suggestedTip: {
            es: "💡 Menciona a tu familia que se queda y tus propiedades. Por ejemplo: 'Mi esposa y 2 hijos se quedan, tenemos casa propia.'",
            en: "💡 Mention family staying behind and your property. Example: 'My wife and 2 kids are staying, we own our house.'"
        },
        goldenAnswer: {
            es: "'Mi esposa es doctora y mis dos hijos están en la escuela. Tenemos casa propia desde hace 5 años. Ellos no pueden viajar porque los niños tienen exámenes esa semana.'",
            en: "'My wife is a doctor and my two kids are in school. We've owned our house for 5 years. They can't travel because the kids have exams that week.'"
        },
        fraudIndicators: ['solo', 'sin hijos', 'vivo con padres', 'single', 'no kids', 'live with parents']
    },
    TRAVEL_HISTORY: {
        id: 'TRAVEL_HISTORY',
        order: 5,
        weight: 0.10,
        ds160Field: 'travel.previous_travel',
        criticalFailure: false,
        suggestedTip: {
            es: "💡 Menciona viajes anteriores y que siempre regresaste. Por ejemplo: 'He viajado a Europa 3 veces y siempre regresé a tiempo.'",
            en: "💡 Mention previous trips and that you always returned. Example: 'I've traveled to Europe 3 times and always returned on time.'"
        },
        goldenAnswer: {
            es: "'He viajado a España, Francia e Italia en los últimos 3 años. Aquí puede ver los sellos en mi pasaporte. Siempre regresé antes de que expirara mi visa.'",
            en: "'I've traveled to Spain, France and Italy in the last 3 years. You can see the stamps in my passport. I always returned before my visa expired.'"
        },
        fraudIndicators: ['nunca', 'primera vez', 'never', 'first time']
    },
    ACCOMMODATION: {
        id: 'ACCOMMODATION',
        order: 6,
        weight: 0.10,
        ds160Field: 'travel.address',
        criticalFailure: false,
        suggestedTip: {
            es: "💡 Nombra el hotel o dirección específica. Por ejemplo: 'Me hospedo en el Holiday Inn de Orlando, ya tengo reservación.'",
            en: "💡 Name the specific hotel or address. Example: 'I'm staying at Holiday Inn Orlando, I already have a reservation.'"
        },
        goldenAnswer: {
            es: "'Tengo reservación en el Holiday Inn de Orlando por 10 noches. Aquí está mi confirmación de Booking.com con el número de reserva.'",
            en: "'I have a reservation at Holiday Inn Orlando for 10 nights. Here's my Booking.com confirmation with the reservation number.'"
        },
        fraudIndicators: ['amigo', 'familiar', 'todavía no sé', 'friend', 'relative', 'not sure yet']
    },
    RETURN_COMMITMENT: {
        id: 'RETURN_COMMITMENT',
        order: 7,
        weight: 0.05,
        ds160Field: 'travel.intended_length',
        criticalFailure: false,
        suggestedTip: {
            es: "💡 Menciona compromisos específicos. Por ejemplo: 'Debo regresar porque trabajo el lunes y mis hijos tienen escuela.'",
            en: "💡 Mention specific commitments. Example: 'I must return because I work on Monday and my kids have school.'"
        },
        goldenAnswer: {
            es: "'Tengo una junta importante el lunes 26 que no puedo perder. Además, mis hijos tienen exámenes finales esa semana y mi esposa no puede llevarlos sola.'",
            en: "'I have an important meeting on Monday the 26th that I can't miss. Plus, my kids have final exams that week and my wife can't take them alone.'"
        },
        fraudIndicators: ['no tengo prisa', 'puedo quedarme más', 'no rush', 'can stay longer']
    }
};

// ============================================================================
// SCORING ALGORITHM
// ============================================================================

/**
 * Calculates the Immigration Probability Score.
 * Formula: P = (V_e × 0.3 + V_s × 0.3 + V_h × 0.15 + V_c × 0.25) × (1 / Country Risk)
 * If P < 0.3, output is 214(b) Denial.
 */
export function calculateImmigrationScore(
    profile: ApplicantProfile,
    verbalCongruence: number // 0-1, how well answers match DS-160
): { score: number; decision: '214b_DENIED' | '221g_PENDING' | 'APPROVED'; riskFactors: string[] } {
    const riskFactors: string[] = [];

    // V_e: Economic Ties = (Salary / Trip Cost) × Work Tenure (capped at 1)
    const salaryRatio = profile.monthlySalaryUSD / (profile.tripCostUSD || 1);
    const V_e = Math.min(1, (salaryRatio * profile.workTenureYears) / 10);

    if (salaryRatio < 0.5) riskFactors.push('LOW_INCOME_VS_TRIP_COST');
    if (profile.workTenureYears < 2) riskFactors.push('SHORT_WORK_TENURE');

    // V_s: Social Ties = (Family in Origin - Family in USA) / max(Family in Origin, 1) (capped at 1)
    const familyDiff = profile.familyInOrigin - profile.familyInUSA;
    const V_s = Math.min(1, Math.max(0, familyDiff / Math.max(profile.familyInOrigin, 1)));

    if (profile.familyInUSA > 0) riskFactors.push('FAMILY_IN_USA');
    if (profile.familyInOrigin === 0) riskFactors.push('NO_FAMILY_TIES');

    // V_h: Travel History = Countries Visited / Passport Age (capped at 1)
    const V_h = Math.min(1, profile.countriesVisited / Math.max(profile.passportAgeYears, 1));

    if (profile.countriesVisited === 0) riskFactors.push('FIRST_TIME_TRAVELER');

    // V_c: Verbal Congruence (passed in)
    const V_c = verbalCongruence;

    if (V_c < 0.5) riskFactors.push('VERBAL_INCONSISTENCY');

    // Country Risk Factor
    const countryRisk = COUNTRY_RISK_FACTORS[profile.originCountry] || 1.0;
    if (countryRisk > 1.2) riskFactors.push('HIGH_RISK_COUNTRY');

    // Additional risk factors
    if (profile.age < 30 && profile.maritalStatus === 'single' && !profile.ownsProperty) {
        riskFactors.push('YOUNG_SINGLE_NO_PROPERTY');
    }
    if (profile.tripDurationDays > 30) riskFactors.push('LONG_TRIP_DURATION');
    if (!profile.hasReturnTicket) riskFactors.push('NO_RETURN_TICKET');

    // Calculate final score
    // P = (V_e × 0.3 + V_s × 0.3 + V_h × 0.15 + V_c × 0.25) × (1 / Country Risk)
    const rawScore = (V_e * 0.3) + (V_s * 0.3) + (V_h * 0.15) + (V_c * 0.25);
    const finalScore = rawScore * (1 / countryRisk);

    // Determine decision
    let decision: '214b_DENIED' | '221g_PENDING' | 'APPROVED';
    if (finalScore < DECISION_THRESHOLDS.DENIAL) {
        decision = '214b_DENIED';
    } else if (finalScore < DECISION_THRESHOLDS.APPROVAL) {
        decision = '221g_PENDING';
    } else {
        decision = 'APPROVED';
    }

    return { score: Math.round(finalScore * 100), decision, riskFactors };
}

// ============================================================================
// DATA LOG FOR INTERNAL TRACKING
// ============================================================================

export interface DataLog {
    coherence: number; // 1-10
    nervousnessLevel: 'LOW' | 'MEDIUM' | 'HIGH';
    affectedVariable: 'ECONOMIC' | 'SOCIAL' | 'HISTORY' | 'CONGRUENCE';
    microContradictions: string[];
    scriptDetected: boolean;
}

/**
 * Generates a structured data log for each interaction.
 */
export function generateDataLog(
    previousAnswers: string[],
    currentAnswer: string,
    ds160Data: Record<string, unknown>
): DataLog {
    const lowerAnswer = currentAnswer.toLowerCase();

    // Detect rehearsed/scripted answers (very formal, structured)
    const scriptIndicators = ['en primer lugar', 'es importante mencionar', 'me gustaría destacar',
        'firstly', 'it is important to mention', 'i would like to highlight'];
    const scriptDetected = scriptIndicators.some(ind => lowerAnswer.includes(ind));

    // Check for micro-contradictions with previous answers
    const microContradictions: string[] = [];
    // (In real implementation, would compare with DS-160 data)

    return {
        coherence: scriptDetected ? 4 : 8,
        nervousnessLevel: lowerAnswer.length < 20 ? 'HIGH' : 'LOW',
        affectedVariable: 'CONGRUENCE',
        microContradictions,
        scriptDetected
    };
}
