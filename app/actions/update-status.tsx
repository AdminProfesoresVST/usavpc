"use server";

import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";

export async function updateStatus(applicationId: string, newStatus: string) {
    const cookieStore = await cookies();
    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) {
                    return cookieStore.get(name)?.value;
                },
                set(name: string, value: string, options: CookieOptions) {
                    cookieStore.set({ name, value, ...options });
                },
                remove(name: string, options: CookieOptions) {
                    cookieStore.set({ name, value: "", ...options });
                },
            },
        }
    );

    const { data: { user }, error: authError } = await supabase.auth.getUser();

    if (authError || !user) {
        throw new Error("Unauthorized: You must be logged in to perform this action.");
    }

    // Optional: Add specific email check for "Super Admin" if needed
    // if (user.email !== 'admin@usvpc.com') throw new Error("Forbidden");

    const { error } = await supabase
        .from("applications")
        .update({ status: newStatus })
        .eq("id", applicationId);

    if (error) {
        throw new Error(error.message);
    }

    // Trigger Email if Completed
    if (newStatus === 'completed_delivered') {
        try {
            // 1. Fetch full application data
            const { data: appData } = await supabase
                .from("applications")
                .select(`*, users (email)`)
                .eq("id", applicationId)
                .single();

            if (appData && appData.users?.email) {
                // 2. Generate PDF
                // Note: We import dynamically to avoid build issues if not needed elsewhere
                const { renderToBuffer } = await import('@react-pdf/renderer');
                const { DS160Document } = await import('@/components/pdf/DS160Document');

                const pdfBuffer = await renderToBuffer(<DS160Document data={ appData.ds160_payload } />);

                // 3. Send Email
                const { sendEmail } = await import('@/lib/email/client');
                await sendEmail({
                    to: appData.users.email,
                    subject: 'Your DS-160 Application Data - US Visa Processing Center',
                    html: `
                        <h1>Application Completed</h1>
                        <p>Dear Applicant,</p>
                        <p>Your DS-160 application data has been processed and is ready.</p>
                        <p>Please find the attached PDF containing your structured data.</p>
                        <br/>
                        <p>Best regards,</p>
                        <p>US Visa Processing Center</p>
                    `,
                    attachments: [
                        {
                            filename: `DS160_${appData.id}.pdf`,
                            content: pdfBuffer
                        }
                    ]
                });
            }
        } catch (emailError) {
            console.error("Failed to send completion email:", emailError);
            // Don't fail the status update just because email failed, but log it
        }
    }

    revalidatePath("/admin");
    revalidatePath("/dashboard");
    return { success: true };
}
