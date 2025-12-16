
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY!; // Use Service Role to bypass RLS

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing ENV variables");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function verify() {
    console.log("Verifying DB Schema...");

    // 1. Try to SELECT the column
    const { data, error } = await supabase
        .from('applications')
        .select('simulator_history')
        .limit(1);

    if (error) {
        console.error("FAILED to select simulator_history:", error.message);
        console.log("DIAGNOSIS: The column 'simulator_history' DOES NOT EXIST.");
    } else {
        console.log("SUCCESS: Column 'simulator_history' exists.");
        console.log("Sample Data:", data);
    }
}

verify();
