import { Menu } from "lucide-react";
import { Link } from "@/src/i18n/routing";
import Image from "next/image";
import { useTranslations } from 'next-intl';
import { LanguageSelector } from "./LanguageSelector";
import { Button } from "@/components/ui/button";
import { MobileMenu } from "./MobileMenu";

export function Header() {
    const t = useTranslations('Common');

    return (
        <header className="sticky top-0 z-50 w-full bg-trust-navy text-white shadow-md">
            <div className="container mx-auto flex h-20 items-center justify-between px-4 md:px-6">
                {/* 1. Logo Section (Reverted to Original) */}
                <Link href="/" className="flex items-center gap-4 group">
                    <div className="relative h-16 w-16 overflow-hidden transition-transform group-hover:scale-105">
                        <Image
                            src="/logo.png"
                            alt="US Visa Processing Center Logo"
                            width={64}
                            height={64}
                            className="object-contain"
                        />
                    </div>
                    <span className="font-serif text-xl font-bold tracking-tight text-white group-hover:text-white/90 transition-colors hidden md:inline-block">
                        US Visa Processing Center
                    </span>
                    <span className="font-serif text-lg font-bold tracking-tight text-white group-hover:text-white/90 transition-colors md:hidden">
                        USAVPC
                    </span>
                </Link>

                {/* 2. Desktop Navigation (Hidden on Mobile) */}
                <nav className="hidden md:flex items-center gap-8 text-sm font-medium text-white/90">
                    <Link href="/" className="hover:text-accent-gold transition-colors">{t('Nav.home')}</Link>
                    <Link href="/services" className="hover:text-accent-gold transition-colors">{t('Nav.services')}</Link>
                    <Link href="/dashboard" className="hover:text-accent-gold transition-colors">{t('Nav.dashboard')}</Link>
                    <Link href="/contact" className="hover:text-accent-gold transition-colors">{t('Nav.contact')}</Link>
                </nav>

                {/* 3. Actions & Mobile Menu */}
                <div className="flex items-center gap-4">
                    <div className="hidden md:block">
                        <LanguageSelector />
                    </div>

                    <Link href="/login" className="hidden md:block">
                        <Button variant="outline" className="text-trust-navy bg-white hover:bg-white/90 font-bold border-none h-9 text-xs">
                            {t('Nav.login')}
                        </Button>
                    </Link>

                    {/* Mobile Hamburger (Visible only on mobile) */}
                    <div className="md:hidden">
                        <MobileMenu />
                    </div>
                </div>
            </div>
        </header>
    );
}
