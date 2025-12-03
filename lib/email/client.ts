import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendEmail({
    to,
    subject,
    html,
    attachments
}: {
    to: string;
    subject: string;
    html: string;
    attachments?: { filename: string; content: Buffer }[];
}) {
    if (!process.env.RESEND_API_KEY) {
        console.warn("RESEND_API_KEY is missing. Email not sent.");
        return { success: false, error: "Missing API Key" };
    }

    try {
        const data = await resend.emails.send({
            from: 'US Visa Processing Center <onboarding@resend.dev>', // Use verified domain in prod
            to,
            subject,
            html,
            attachments
        });

        return { success: true, data };
    } catch (error) {
        console.error("Email sending failed:", error);
        return { success: false, error };
    }
}
