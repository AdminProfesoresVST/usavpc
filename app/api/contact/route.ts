import { NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";

export async function POST(request: Request) {
    try {
        const body = await request.json();
        const { name, email, subject, message } = body;

        // Validate input
        if (!name || !email || !message) {
            return NextResponse.json(
                { error: "Missing required fields" },
                { status: 400 }
            );
        }

        // Initialize Supabase Admin Client (to bypass RLS for inserting messages from public)
        const supabase = createClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.SUPABASE_SERVICE_ROLE_KEY!
        );

        // Send email via Resend
        const { sendEmail } = await import('@/lib/email/client');
        const emailResult = await sendEmail({
            to: 'support@usvisaprocessingcenter.com', // In prod, this would be the admin email
            subject: `New Contact Inquiry: ${subject}`,
            html: `
                <h1>New Contact Message</h1>
                <p><strong>Name:</strong> ${name}</p>
                <p><strong>Email:</strong> ${email}</p>
                <p><strong>Subject:</strong> ${subject}</p>
                <p><strong>Message:</strong></p>
                <p>${message}</p>
            `
        });

        if (!emailResult.success) {
            console.error("Failed to send contact email:", emailResult.error);
            // We still return success to the user, but log the error
        }

        return NextResponse.json({ success: true });

    } catch (error) {
        console.error("Contact API Error:", error);
        return NextResponse.json(
            { error: "Internal Server Error" },
            { status: 500 }
        );
    }
}
