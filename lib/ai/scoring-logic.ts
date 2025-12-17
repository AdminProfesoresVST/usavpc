import { DS160Payload } from "@/types/ds160";

/**
 * CONSULAR LOGIC MODEL (Section 214(b) Adjudication Simulator)
 * 
 * Based on research from Foreign Affairs Manual (FAM) and ex-Consular Officer testimonials.
 * Core Principle: "Presumption of Immigrant Intent" (INA 214(b)).
 * 
 * The score represents the "Probability of Overcoming 214(b)".
 * Range: 0 (High Risk/Refusal) to 100 (Clear Approval).
 * Threshold: Typically > 85-90 for approval.
 */

interface RiskFactor {
    id: string;
    description: string;
    impact: number; // Positive or Negative points
    category: "TIES" | "RISK" | "CREDIBILITY";
}

interface ScoringResult {
    totalScore: number;
    baseScore: number; // Score solely from DS-160
    factors: RiskFactor[];
    riskLevel: "HIGH" | "MEDIUM" | "LOW";
}

export function calculateConsularScore(payload: DS160Payload | null): ScoringResult {
    let score = 0; // START AT ZERO (User's Request: "If you don't know me, I am at zero")
    // Note: We build the score from the Profile. 
    // If the profile is empty, score remains 0.

    const factors: RiskFactor[] = [];

    if (!payload?.ds160_data) {
        return { totalScore: 10, baseScore: 10, factors: [{ id: "NO_DATA", description: "No DS-160 Data Found", impact: 0, category: "RISK" }], riskLevel: "HIGH" };
    }

    const p = payload.ds160_data.personal || {};
    const w = payload.ds160_data.work_history || {};
    const t = payload.ds160_data.travel || {};

    // --- 1. AGE & MARITAL STATUS INTERACTION (The "Flight Risk" Matrix) ---
    // Young + Single = Highest Statistical Risk of Overstay.
    let age = 30; // Default
    if (p.dob) {
        age = new Date().getFullYear() - new Date(p.dob).getFullYear();
    }

    const marital = p.marital_status; // S, M, C, D, W

    if (age >= 18 && age <= 29) {
        if (marital === 'SINGLE' || marital === 'DIVORCED') {
            factors.push({ id: "YOUNG_SINGLE", description: "Age 18-29 & Single (High Mobility)", impact: 20, category: "RISK" }); // Only 20 base points
        } else {
            factors.push({ id: "YOUNG_TIED", description: "Young but Married (Moderate Ties)", impact: 40, category: "TIES" });
        }
    } else if (age > 29 && age < 60) {
        factors.push({ id: "PRIME_AGE", description: "Prime Working Age (Stability)", impact: 45, category: "TIES" });
        if (marital === 'MARRIED') {
            factors.push({ id: "FAMILY_TIES", description: "Strong Family Ties (Spouse)", impact: +10, category: "TIES" });
        }
    } else if (age >= 60) {
        factors.push({ id: "SENIOR", description: "Senior Applicant (Low Immigrant Intent)", impact: 60, category: "TIES" });
    }

    // --- 2. ECONOMIC TIES (Employment & Income) ---
    // Unemployed is a major red flag.
    const job = payload.primary_occupation; // U=Unemployed, E=Employed, S=Student, B=Business
    const income = parseInt(payload.monthly_income || "0");

    if (job === 'U') {
        factors.push({ id: "UNEMPLOYED", description: "Unemployed / No Income Source", impact: -10, category: "RISK" });
    } else if (job === 'S') {
        factors.push({ id: "STUDENT", description: "Student Status", impact: +5, category: "TIES" });
    } else {
        // Employed
        if (income > 3000) {
            factors.push({ id: "GOOD_INCOME", description: "Strong Solvent Income (> $3k)", impact: +15, category: "TIES" });
        } else if (income > 1000) {
            factors.push({ id: "STABLE_INCOME", description: "Stable Income", impact: +10, category: "TIES" });
        } else {
            factors.push({ id: "LOW_INCOME", description: "Low Income (Economic Vulnerability)", impact: -5, category: "RISK" });
        }
    }

    // --- 3. TRAVEL HISTORY (The #1 Predictor) ---
    // Past compliance predicts future compliance.
    if (payload.has_previous_visa) {
        factors.push({ id: "PREVIOUS_VISA", description: "Previous US Visa Holder (Strongest Tie)", impact: +25, category: "TIES" });
    }
    // We assume 'has_travel' is derived from valid travel data
    // If not in payload main fields, we might miss it. Assuming extracted.

    if (payload.has_refusals) {
        factors.push({ id: "PREVIOUS_REFUSAL", description: "Previous Visa Refusal (High Scrutiny)", impact: -20, category: "RISK" });
    }

    // --- CALCULATION ---
    // Base Baseline: 10 (Almost zero).
    // Sum Factors.
    let derivedScore = 15; // Starting Pulse
    factors.forEach(f => derivedScore += f.impact);

    // CLAMPING for the "Pre-Interview" State
    // No one starts at 100.
    // Max Start: 65 (Even with great ties, interview matters).
    // Min Start: 10.

    derivedScore = Math.max(10, Math.min(65, derivedScore));

    return {
        totalScore: derivedScore,
        baseScore: derivedScore,
        factors,
        riskLevel: derivedScore < 30 ? "HIGH" : derivedScore < 55 ? "MEDIUM" : "LOW"
    };
}
