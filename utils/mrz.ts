export const MRZ = {
    // Character mapping for checksum calculation
    // 0-9 = 0-9, A-Z = 10-35, < = 0
    charmap: {
        '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
        'A': 10, 'B': 11, 'C': 12, 'D': 13, 'E': 14, 'F': 15, 'G': 16, 'H': 17, 'I': 18,
        'J': 19, 'K': 20, 'L': 21, 'M': 22, 'N': 23, 'O': 24, 'P': 25, 'Q': 26, 'R': 27,
        'S': 28, 'T': 29, 'U': 30, 'V': 31, 'W': 32, 'X': 33, 'Y': 34, 'Z': 35, '<': 0
    } as Record<string, number>,

    // Weights for calculation: 7, 3, 1 repeating
    weights: [7, 3, 1],

    calculateCheckDigit(str: string): number {
        let sum = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str[i].toUpperCase();
            const value = this.charmap[char] ?? 0;
            const weight = this.weights[i % 3];
            sum += value * weight;
        }
        return sum % 10;
    },

    validate(mrzLine2: string): { isValid: boolean; details: any } {
        // Expected Format (TD3 - Passport):
        // 0-9:   Passport No
        // 9:     Check Digit
        // 10-13: Nationality
        // 13-19: DOB (YYMMDD)
        // 19:    Check Digit
        // 20:    Sex
        // 21-27: Expiration (YYMMDD)
        // 27:    Check Digit
        // 28-42: Personal No
        // 42:    Check Digit possible?
        // 43:    Composite Check Digit (Final)

        // Clean input
        const line = mrzLine2.trim();
        if (line.length < 44) return { isValid: false, details: { error: "Line too short" } };

        // 1. Validate Passport Number
        const passportNo = line.substring(0, 9);
        const passportCheck = line[9];
        const calcPassportCheck = this.calculateCheckDigit(passportNo);
        const isPassportValid = parseInt(passportCheck) === calcPassportCheck || passportCheck === '<'; // Loose check for < sometimes

        // 2. Validate DOB
        const dob = line.substring(13, 19);
        const dobCheck = line[19];
        const calcDobCheck = this.calculateCheckDigit(dob);
        const isDobValid = parseInt(dobCheck) === calcDobCheck;

        // 3. Validate Expiration
        const exp = line.substring(21, 27);
        const expCheck = line[27];
        const calcExpCheck = this.calculateCheckDigit(exp);
        const isExpValid = parseInt(expCheck) === calcExpCheck;

        // 4. Composite Check (Optional but good)
        // Calculates over: Passport(10) + Dob(7) + Exp(7) + Personal(15) 
        // structure depends on TD3. Let's stick to field level for feedback.

        return {
            isValid: isPassportValid && isDobValid && isExpValid,
            details: {
                passport: { value: passportNo, valid: isPassportValid },
                dob: { value: dob, valid: isDobValid },
                expiration: { value: exp, valid: isExpValid }
            }
        };
    }
};
