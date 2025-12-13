"use server";

import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";
import { getCurrentUser } from "@/lib/auth/current-user";

export async function resetDS160Field(fieldKey: string) {
    const { data: { user } } = await getCurrentUser();
    if (!user) throw new Error("Unauthorized");

    const cookieStore = await cookies();
    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) { return cookieStore.get(name)?.value; },
            },
        }
    );

    // 1. Fetch current payload
    const { data: app, error: fetchError } = await supabase
        .from("applications")
        .select("ds160_payload")
        .eq("user_id", user.id)
        .single();

    if (fetchError || !app) throw new Error("Application not found");

    // 2. Set field to null (Deep update)
    const payload = app.ds160_payload;
    const keys = fieldKey.split('.');
    let current = payload;

    // Navigate to parent
    for (let i = 0; i < keys.length - 1; i++) {
        if (!current[keys[i]]) current[keys[i]] = {};
        current = current[keys[i]];
    }

    // Set value to null
    current[keys[keys.length - 1]] = null;

    // 3. Save back
    const { error: updateError } = await supabase
        .from("applications")
        .update({ ds160_payload: payload })
        .eq("user_id", user.id);

    if (updateError) throw new Error(updateError.message);

    revalidatePath("/dashboard");
    return { success: true };
}
