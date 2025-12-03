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

export default function LoginPage() {
    const [email, setEmail] = useState("");
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState("");
    const supabase = createClient();
    const t = useTranslations('Login');

    const searchParams = useSearchParams();
    const next = searchParams.get('next');

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        const redirectTo = next
            ? `${window.location.origin}/auth/callback?next=${encodeURIComponent(next)}`
            : `${window.location.origin}/auth/callback`;

        const { error } = await supabase.auth.signInWithOtp({
            email,
            options: {
                emailRedirectTo: redirectTo,
            },
        });

        if (error) {
            setMessage("Error: " + error.message);
        } else {
            setMessage("Check your email for the login link!");
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
                    <div className="text-center mb-8">
                        <h1 className="text-3xl font-serif font-bold text-trust-navy mb-2">{t('title')}</h1>
                        <p className="text-muted-foreground">{t('subtitle')}</p>
                    </div>
                    <form onSubmit={handleLogin} className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-foreground mb-1">
                                Email Address
                            </label>
                            <Input
                                type="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="name@example.com"
                                required
                                className="bg-input-bg border-input-border"
                            />
                        </div>
                        <Button
                            type="submit"
                            disabled={loading}
                            className="w-full bg-primary text-white uppercase font-semibold"
                        >
                            {loading ? "Sending Secure Link..." : "Send Secure Access Link"}
                        </Button>
                        <div className="flex justify-center items-center gap-2 mt-4 text-xs text-muted-foreground">
                            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-green-600"><rect width="18" height="11" x="3" y="11" rx="2" ry="2" /><path d="M7 11V7a5 5 0 0 1 10 0v4" /></svg>
                            <span>256-bit SSL Encrypted Connection</span>
                        </div>
                        {message && (
                            <p className="text-sm text-center text-muted-foreground mt-4">
                                {message}
                            </p>
                        )}
                    </form>
                    <div className="mt-6 text-center text-sm">
                        <span className="text-muted-foreground">Don't have an account? </span>
                        <Link
                            href={next ? `/register?next=${encodeURIComponent(next)}` : "/register"}
                            className="text-primary font-semibold hover:underline"
                        >
                            Create Account
                        </Link>
                    </div>
                </Card>
            </div>
        </div>
    );
}
