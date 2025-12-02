"use client";

import { useLocale } from "next-intl";
import { useRouter, usePathname } from "next/navigation";
import { Globe } from "lucide-react";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";

const languages = [
    { code: "en", label: "English" },
    { code: "es", label: "Español" },
    { code: "pt", label: "Português" },
    { code: "fr", label: "Français" },
    { code: "cn", label: "中文" },
    { code: "hi", label: "हिन्दी" },
];

export function LanguageSelector() {
    const locale = useLocale();
    const router = useRouter();
    const pathname = usePathname();

    const handleLanguageChange = (newLocale: string) => {
        // Replace the locale in the pathname
        const newPath = pathname.replace(`/${locale}`, `/${newLocale}`);
        router.push(newPath);
    };

    return (
        <DropdownMenu>
            <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="icon" className="text-white hover:bg-white/10 hover:text-white">
                    <Globe className="h-5 w-5" />
                    <span className="sr-only">Switch Language</span>
                </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="bg-white text-text-dark border-border">
                {languages.map((lang) => (
                    <DropdownMenuItem
                        key={lang.code}
                        onClick={() => handleLanguageChange(lang.code)}
                        className={`cursor-pointer ${locale === lang.code ? "bg-official-grey font-bold" : ""}`}
                    >
                        {lang.label}
                    </DropdownMenuItem>
                ))}
            </DropdownMenuContent>
        </DropdownMenu>
    );
}
