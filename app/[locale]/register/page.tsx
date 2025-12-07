"use client";

import { useState } from "react";
import { createClient } from "@/utils/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { useTranslations } from 'next-intl';
import Image from "next/image";
import { Link } from "@/src/i18n/routing";
import { useSearchParams } from "next/navigation";

export default function RegisterPage() {
    const [email, setEmail] = useState("");
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState("");
    const supabase = createClient();
    const t = useTranslations('Register');

    const searchParams = useSearchParams(); // Import this
    const next = searchParams.get('next');

    const handleRegister = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        const redirectTo = next
            ? `${window.location.origin}/auth/callback?next=${encodeURIComponent(next)}`
            : `${window.location.origin}/auth/callback`;

        const { error } = await supabase.auth.signInWithOtp({
            email,
            options: {
                emailRedirectTo: redirectTo,
                shouldCreateUser: true,
            },
        });

        if (error) {
            setMessage("Error: " + error.message);
        } else {
            setMessage("Check your email to confirm your account!");
        }
        setLoading(false);
    };

    const handleGoogleLogin = async () => {
        setLoading(true);
        const redirectTo = next
            ? `${window.location.origin}/auth/callback?next=${encodeURIComponent(next)}`
            : `${window.location.origin}/auth/callback`;

        const { error } = await supabase.auth.signInWithOAuth({
            provider: 'google',
            options: {
                redirectTo,
                queryParams: {
                    access_type: 'offline',
                    prompt: 'consent',
                },
            },
        });

        if (error) {
            setMessage("Error: " + error.message);
            setLoading(false);
        }
    };

    return (
        <div className="relative min-h-screen flex flex-col">
            <div className="absolute inset-0 z-0 bg-trust-navy">
                <Image
                    src="/bg-hero.png"
                    alt="Background"
                    fill
                    className="object-cover object-center opacity-20"
                    priority
                />
            </div>
            <div className="container mx-auto px-4 py-16 flex justify-center relative z-10 flex-grow items-center">
                <Card className="w-full max-w-md p-8 bg-white shadow-lg border-border">
                    <h1 className="text-2xl font-serif font-bold text-primary mb-6 text-center">
                        {t('title')}
                    </h1>

                    <div className="space-y-4 mb-6">
                        <Button
                            variant="outline"
                            className="w-full gap-2 font-semibold text-gray-700 border-gray-300 hover:bg-gray-50"
                            onClick={handleGoogleLogin}
                            disabled={loading}
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" height="20" viewBox="0 0 24 24" width="20"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" /><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" /><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" /><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" /><path d="M1 1h22v22H1z" fill="none" /></svg>
                            {t('googleBtn')}
                        </Button>
                        <div className="relative">
                            <div className="absolute inset-0 flex items-center">
                                <span className="w-full border-t border-gray-200" />
                            </div>
                            <div className="relative flex justify-center text-xs uppercase">
                                <span className="bg-white px-2 text-muted-foreground">Or continue with email</span>
                            </div>
                        </div>
                    </div>

                    <form onSubmit={handleRegister} className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-foreground mb-1">
                                {t('emailLabel')}
                            </label>
                            <Input
                                type="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder={t('placeholder')}
                                required
                                className="bg-input-bg border-input-border"
                            />
                        </div>
                        <Button
                            type="submit"
                            disabled={loading}
                            className="w-full bg-primary text-white uppercase font-semibold"
                        >
                            {loading ? t('creatingAccount') : t('signUp')}
                        </Button>
                        {message && (
                            <p className="text-sm text-center text-muted-foreground mt-4">
                                {message}
                            </p>
                        )}
                    </form>
                    <div className="mt-6 text-center text-sm">
                        <span className="text-muted-foreground">{t('alreadyHaveAccount')}</span>
                        <Link
                            href={next ? `/login?next=${encodeURIComponent(next)}` : "/login"}
                            className="text-primary font-semibold hover:underline"
                        >
                            {t('loginBtn')}
                        </Link>
                    </div>
                </Card>
            </div>
        </div>
    );
}
