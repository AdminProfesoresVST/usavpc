"use client";

import { useState } from "react";
import { createClient } from "@/utils/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { useTranslations } from 'next-intl';

export default function LoginPage() {
    const [email, setEmail] = useState("");
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState("");
    const supabase = createClient();
    const t = useTranslations('Common'); // Using Common for now, should add Login namespace

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        const { error } = await supabase.auth.signInWithOtp({
            email,
            options: {
                emailRedirectTo: `${window.location.origin}/auth/callback`,
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
        <div className="container mx-auto px-4 py-16 flex justify-center">
            <Card className="w-full max-w-md p-8 bg-white shadow-lg border-border">
                <h1 className="text-2xl font-serif font-bold text-primary mb-6 text-center">
                    Client Portal Login
                </h1>
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
                        {loading ? "Sending Link..." : "Send Magic Link"}
                    </Button>
                    {message && (
                        <p className="text-sm text-center text-muted-foreground mt-4">
                            {message}
                        </p>
                    )}
                </form>
            </Card>
        </div>
    );
}
