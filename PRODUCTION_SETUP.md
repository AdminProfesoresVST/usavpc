# Production Setup Guide 🚀

To finalize your application and ensure emails look professional, you must configure the following settings in your **Supabase Dashboard**. These settings cannot be changed via code.

## 1. Configure Email Sender (Crucial for "Professional" Look)

This changes the "From" name in the emails your users receive.

1.  Go to **Supabase Dashboard** -> **Authentication** -> **Email Templates**.
2.  Look for **"Sender Configuration"** (usually at the top or in settings).
3.  **Sender Email**: Change this to your official email (e.g., `noreply@usvisaprocessingcenter.com` or `info@yourdomain.com`).
    *   *Note: If you use a custom domain, you MUST configure SMTP (see below), otherwise emails will go to Spam.*
4.  **Sender Name**: Change this to **"US Visa Processing Center"**.

## 2. Configure Custom SMTP (Required for Custom Domains)

If you change the "Sender Email" to anything other than the default supabase address, you **must** set up your own email server (SMTP) to ensure delivery.

1.  Go to **Project Settings** -> **Authentication** -> **SMTP Settings**.
2.  Enable **"Enable Custom SMTP"**.
3.  Enter your email provider details (e.g., AWS SES, Resend, SendGrid, or your hosting provider).
    *   **Host**: `smtp.provider.com`
    *   **Port**: `465` (SSL) or `587` (TLS)
    *   **User/Pass**: Your credentials.
    *   **Sender Email**: Must match the one you set in Step 1.

## 3. Site URL Configuration

Ensure users are redirected back to the correct site after logging in.

1.  Go to **Authentication** -> **URL Configuration**.
2.  **Site URL**: Set this to `https://us-visa-processing-center-pwa.netlify.app`.
3.  **Redirect URLs**: Add the following:
    *   `https://us-visa-processing-center-pwa.netlify.app/**`
    *   `http://localhost:3000/**` (for development)

## 4. Email Templates

Ensure you have pasted the HTML template provided in `supabase/templates/magic-link.html` into the **"Magic Link"** template section.

---

**Checklist for Launch:**
- [ ] Sender Name set to "US Visa Processing Center"
- [ ] Sender Email set (and SMTP configured if custom)
- [ ] Site URL set to Netlify URL
- [ ] Magic Link Template updated with HTML code
