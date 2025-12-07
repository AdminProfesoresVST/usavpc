"use client";

import { useTranslations } from 'next-intl';
import { Link } from "@/src/i18n/routing";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
    DropdownMenuSeparator,
    DropdownMenuLabel
} from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";
import { Menu, Home, Briefcase, FileText, Phone, LogIn } from "lucide-react";

export function MobileMenu() {
    const t = useTranslations();

    return (
        <DropdownMenu>
            <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="icon" className="h-10 w-10 text-trust-navy hover:bg-gray-100">
                    <Menu className="h-6 w-6" />
                    <span className="sr-only">Open menu</span>
                </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56 bg-white border-gray-200">
                <DropdownMenuLabel>{t('Common.Mobile.title')}</DropdownMenuLabel>
                <DropdownMenuSeparator />

                <DropdownMenuItem asChild>
                    <Link href="/" className="flex items-center gap-2 cursor-pointer">
                        <Home className="h-4 w-4" />
                        <span>{t('Common.Nav.home')}</span>
                    </Link>
                </DropdownMenuItem>

                <DropdownMenuItem asChild>
                    <Link href="/services" className="flex items-center gap-2 cursor-pointer">
                        <Briefcase className="h-4 w-4" />
                        <span>{t('Common.Nav.services')}</span>
                    </Link>
                </DropdownMenuItem>

                <DropdownMenuItem asChild>
                    <Link href="/dashboard" className="flex items-center gap-2 cursor-pointer">
                        <FileText className="h-4 w-4" />
                        <span>{t('Common.Nav.dashboard')}</span>
                    </Link>
                </DropdownMenuItem>

                <DropdownMenuItem asChild>
                    <Link href="/contact" className="flex items-center gap-2 cursor-pointer">
                        <Phone className="h-4 w-4" />
                        <span>{t('Common.Nav.contact')}</span>
                    </Link>
                </DropdownMenuItem>

                <DropdownMenuSeparator />

                <DropdownMenuItem asChild className="text-trust-navy font-bold">
                    <Link href="/login" className="flex items-center gap-2 cursor-pointer">
                        <LogIn className="h-4 w-4" />
                        <span>{t('Common.Nav.login')}</span>
                    </Link>
                </DropdownMenuItem>
            </DropdownMenuContent>
        </DropdownMenu>
    );
}
