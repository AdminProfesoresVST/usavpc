
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import path from 'path';

// Load env from .env.local
dotenv.config({ path: path.resolve(process.cwd(), '.env.local') });

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY!;

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function debugState() {
    console.log("🔍 Inspecting Latest User Payload...");

    // Get most recent modified application
    const { data: apps, error } = await supabase
        .from('applications')
        .select('user_id, ds160_payload')
        // .order('created_at', { ascending: false }) // No timestamps
        .limit(1);

    if (error || !apps || apps.length === 0) {
        console.error("❌ No applications found.", error);
        return;
    }

    const app = apps[0];
    console.log(`👤 User ID: ${app.user_id}`);
    // console.log(`📅 Updated: ${app.updated_at}`);

    const payload = app.ds160_payload || {};
    const passportData = payload.ds160_data?.passport || {};

    console.log("----- PASSPORT DATA -----");
    console.log(JSON.stringify(passportData, null, 2));

    // Test Logic check
    const passportNum = passportData.passport_number;
    console.log(`\n🛂 Passport Number Found: "${passportNum}"`);

    if (passportNum && passportNum.length > 3) {
        console.log("✅ Condition (passportNum > 3) is TRUE. Auto-Answer SHOULD fire.");
    } else {
        console.log("❌ Condition (passportNum > 3) is FALSE. Auto-Answer will FAIL.");
    }

    const bookNum = passportData.passport_book_num;
    console.log(`📖 Current Book Number in DB: "${bookNum}"`);
}

debugState();
