
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import path from 'path';

// Load env from root
dotenv.config({ path: path.resolve(__dirname, '../.env.local') });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceRoleKey) {
    console.error("❌ Missing Environment Variables:");
    console.error("   NEXT_PUBLIC_SUPABASE_URL:", !!supabaseUrl);
    console.error("   SUPABASE_SERVICE_ROLE_KEY:", !!serviceRoleKey);
    process.exit(1);
}

console.log("✅ Env Vars Found. Testing Admin Access...");

const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false
    }
});

async function testAdminWrite() {
    // Generate a Dummy User ID (Use a specialized Test ID to avoid collisions)
    const TEST_ID = '00000000-0000-0000-0000-111111111111';

    console.log(`Testing Upsert to 'profiles' with ID: ${TEST_ID}`);

    const { data, error } = await adminClient
        .from('profiles')
        .upsert({
            id: TEST_ID,
            email: 'admin_test@test.com'
        })
        .select()
        .single();

    if (error) {
        console.error("❌ Admin Write Failed!");
        console.error("   Error Message:", error.message);
        console.error("   Error Details:", error.details);
        console.error("   Error Hint:", error.hint);
        process.exit(1);
    } else {
        console.log("✅ Admin Write Success!");
        console.log("   Inserted Data:", data);

        // Cleanup
        console.log("Cleaning up...");
        await adminClient.from('profiles').delete().eq('id', TEST_ID);
        console.log("✅ Cleanup Done.");
        process.exit(0);
    }
}

testAdminWrite();
