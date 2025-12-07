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
        <header className="sticky top-0 z-50 w-full bg-trust-navy text-white shadow-md transition-all duration-300">
            {/* 
                STRICT 2-SIZE SYSTEM
                Mobile: h-14, Logo + Hamburger
                Desktop: h-20, Logo + Text + Nav
            */}
            <div className="container mx-auto flex items-center justify-between px-4 md:px-6 h-20">

                {/* 1. Logo Section */}
                <Link href="/" className="flex items-center gap-3 group">
                    {/* Logo: consistent size or slightly adapted */}
                    <div className="relative h-12 w-12 md:h-16 md:w-16 overflow-hidden transition-transform group-hover:scale-105">
                        <Image
                            src="/logo.png"
                            alt="US Visa Processing Center Logo"
                            fill
                            className="object-contain"
                        />
                    </div>

                    {/* Desktop & Mobile Text: Visible Always */}
                    <div className="flex flex-col justify-center">
                        <span className="font-serif text-sm md:text-xl font-bold tracking-tight text-white group-hover:text-white/90 transition-colors leading-tight">
                            US Visa Processing Center
                        </span>
                    </div>
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
