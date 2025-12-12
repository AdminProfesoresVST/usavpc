"use client";

import { useTranslations } from 'next-intl';
import { Link } from "@/src/i18n/routing";
import {
    Sheet,
    SheetContent,
    SheetDescription,
    SheetHeader,
    SheetTitle,
    SheetTrigger,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Menu, Home, Briefcase, FileText, Phone, LogIn } from "lucide-react";
import { LanguageSelector } from "./LanguageSelector";

export function MobileMenu({ className }: { className?: string }) {
    const t = useTranslations();

    return (
        <Sheet>
            <SheetTrigger asChild>
                <Button variant="ghost" size="icon" className={`h-10 w-10 hover:bg-white/10 ${className || 'text-trust-navy hover:bg-gray-100'}`}>
                    <Menu className="h-6 w-6" />
                    <span className="sr-only">Open menu</span>
                </Button>
            </SheetTrigger>
            <SheetContent side="left" className="w-[300px] sm:w-[350px] bg-white border-r border-gray-100 p-0 flex flex-col">
                <SheetHeader className="p-6 bg-trust-navy text-white">
                    <div className="flex items-center gap-3">
                        <div className="h-12 w-12 rounded-full bg-white/10 flex items-center justify-center border-2 border-white/20">
                            <span className="text-lg font-bold">JD</span>
                        </div>
                        <div className="flex flex-col text-left">
                            <SheetTitle className="text-white text-lg font-bold leading-none">John Doe</SheetTitle>
                            <SheetDescription className="text-gray-300 text-xs mt-1">
                                {t('Common.Roles.applicant')}
                            </SheetDescription>
                        </div>
                    </div>
                </SheetHeader>

                <div className="flex-1 overflow-y-auto py-4 px-2">
                    <nav className="flex flex-col gap-1">
                        <div className="px-4 py-2 text-xs font-bold text-gray-400 uppercase tracking-wider">
                            {t('Common.Menu.mainMenu')}
                        </div>

                        <Link href="/" className="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 rounded-lg text-gray-700 transition-colors">
                            <Home className="h-5 w-5 text-trust-navy" />
                            <span className="font-medium text-sm">{t('Common.Nav.home')}</span>
                        </Link>

                        <Link href="/#services" className="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 rounded-lg text-gray-700 transition-colors">
                            <Briefcase className="h-5 w-5 text-trust-navy" />
                            <span className="font-medium text-sm">{t('Common.Nav.services')}</span>
                        </Link>

                        <Link href="/dashboard" className="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 rounded-lg text-gray-700 transition-colors">
                            <FileText className="h-5 w-5 text-trust-navy" />
                            <span className="font-medium text-sm">{t('Common.Nav.dashboard')}</span>
                        </Link>

                        <Link href="/contact" className="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 rounded-lg text-gray-700 transition-colors">
                            <Phone className="h-5 w-5 text-trust-navy" />
                            <span className="font-medium text-sm">{t('Common.Nav.contact')}</span>
                        </Link>

                        <div className="px-4 py-2">
                            <LanguageSelector />
                        </div>

                        <div className="my-2 border-t border-gray-100"></div>

                        <div className="px-4 py-2 text-xs font-bold text-gray-400 uppercase tracking-wider">
                            {t('Common.Menu.account')}
                        </div>

                        <Link href="/login" className="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 rounded-lg text-trust-navy font-bold transition-colors">
                            <LogIn className="h-5 w-5" />
                            <span className="font-medium text-sm">{t('Common.Nav.login')}</span>
                        </Link>
                    </nav>
                </div>
            </SheetContent>
        </Sheet>
    );
}
