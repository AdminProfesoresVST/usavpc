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
import { ArrowRight, ShieldCheck } from "lucide-react";

export default function RegisterPage() {
    const [email, setEmail] = useState("");
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState("");
    const supabase = createClient();
    const t = useTranslations('Register');

    const searchParams = useSearchParams();
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
        <div className="min-h-screen bg-[#F0F2F5] flex flex-col items-center justify-center p-4">
            {/* Header / Logo */}
            <div className="mb-8 text-center">
                <div className="flex items-center gap-2 justify-center mb-4">
                    <div className="h-10 w-10 bg-blue-600 rounded-xl flex items-center justify-center text-white font-bold shadow-lg shadow-blue-200">
                        US
                    </div>
                </div>
                <h1 className="text-2xl font-bold text-gray-900 tracking-tight">{t('title')}</h1>
                <p className="text-gray-500 text-sm mt-1">{t('subtitle') || 'Start your application securely'}</p>
            </div>

            <Card className="w-full max-w-sm p-8 bg-white shadow-xl shadow-gray-200/50 border-0 rounded-[2rem]">
                <div className="space-y-4 mb-6">
                    <Button
                        variant="outline"
                        className="w-full gap-3 py-6 font-semibold text-gray-700 border-gray-100 bg-gray-50 hover:bg-gray-100 rounded-xl transition-all"
                        onClick={handleGoogleLogin}
                        disabled={loading}
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" height="20" viewBox="0 0 24 24" width="20"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" /><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" /><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" /><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" /><path d="M1 1h22v22H1z" fill="none" /></svg>
                        {t('googleBtn')}
                    </Button>
                    <div className="relative py-2">
                        <div className="absolute inset-0 flex items-center">
                            <span className="w-full border-t border-gray-100" />
                        </div>
                        <div className="relative flex justify-center text-xs uppercase">
                            <span className="bg-white px-3 text-gray-400 font-medium">Or</span>
                        </div>
                    </div>
                </div>

                <form onSubmit={handleRegister} className="space-y-5">
                    <div>
                        <Input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder={t('placeholder')}
                            required
                            className="bg-gray-50 border-gray-200 h-12 rounded-xl focus:ring-2 focus:ring-blue-500/20"
                        />
                    </div>

                    <Button
                        type="submit"
                        disabled={loading}
                        className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold h-12 rounded-xl shadow-lg shadow-blue-600/20 transition-all active:scale-95"
                    >
                        {loading ? t('creatingAccount') : t('signUp')}
                    </Button>

                    <div className="flex justify-center items-center gap-2 mt-4 text-[10px] text-gray-400 bg-gray-50 py-2 rounded-lg">
                        <ShieldCheck size={12} className="text-green-600" />
                        <span>256-bit Secure Connection</span>
                    </div>

                    {message && (
                        <div className="p-3 bg-blue-50 text-blue-800 text-sm rounded-xl text-center font-medium animate-in fade-in zoom-in duration-300">
                            {message}
                        </div>
                    )}
                </form>

                <div className="mt-8 text-center text-sm">
                    <span className="text-gray-400">{t('alreadyHaveAccount')} </span>
                    <Link
                        href={next ? `/login?next=${encodeURIComponent(next)}` : "/login"}
                        className="text-blue-600 font-bold hover:underline"
                    >
                        {t('loginBtn')}
                    </Link>
                </div>
            </Card>

            <p className="mt-8 text-xs text-center text-gray-400">
                &copy; 2024 US Visa Center. All rights reserved.
            </p>
        </div>
    );
}
