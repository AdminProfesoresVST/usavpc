"use client";

import { useTranslations } from 'next-intl';
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { AlertCircle } from "lucide-react";

import { useSearchParams } from "next/navigation";

export default function AuthCodeErrorPage() {
    // const t = useTranslations('AuthError'); 
    const searchParams = useSearchParams();
    const error = searchParams.get("error");

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <Card className="w-full max-w-md p-8 text-center space-y-6">
                <div className="flex justify-center">
                    <div className="bg-red-100 p-3 rounded-full">
                        <AlertCircle className="w-10 h-10 text-red-600" />
                    </div>
                </div>

                <h1 className="text-2xl font-bold text-gray-900">
                    Authentication Error
                </h1>

                <p className="text-gray-600">
                    We were unable to verify your login link.
                </p>

                {error && (
                    <div className="bg-red-50 border border-red-200 rounded p-3 text-sm text-red-800 font-mono break-all">
                        {error}
                    </div>
                )}

                <div className="space-y-4 pt-4">
                    <Link href="/login">
                        <Button className="w-full bg-primary text-white">
                            Try Logging In Again
                        </Button>
                    </Link>

                    <Link href="/contact">
                        <Button variant="outline" className="w-full">
                            Contact Support
                        </Button>
                    </Link>
                </div>
            </Card>
        </div>
    );
}
