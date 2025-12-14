import { SupabaseClient } from "@supabase/supabase-js";

export async function getSystemPrompt(supabase: SupabaseClient, key: string): Promise<string> {
  const { data, error } = await supabase
    .from('ai_prompts')
    .select('prompt')
    .eq('key', key)
    .single();

  if (error || !data) {
    console.error(`CRITICAL: Failed to fetch prompt: ${key}`, error);
    throw new Error(`CRITICAL_DATA_MISSING: Prompt '${key}' not found in ai_prompts table.`);
  }

  return data.prompt;
}

