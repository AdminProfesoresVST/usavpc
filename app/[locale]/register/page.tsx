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
