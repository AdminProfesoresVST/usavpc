import { Lock } from "lucide-react";
import { Link } from "@/src/i18n/routing";
import Image from "next/image";
import { useTranslations } from 'next-intl';
import { LanguageSelector } from "./LanguageSelector";
import { Button } from "@/components/ui/button";

export function Header() {
    const t = useTranslations('Common');

    return (
        <header className="sticky top-0 z-50 w-full bg-primary text-primary-foreground shadow-md">
            <div className="container mx-auto flex h-20 items-center justify-between px-4 md:px-6">
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

                <nav className="hidden md:flex items-center gap-6 text-sm font-medium text-white/90">
                    <Link href="/" className="hover:text-white transition-colors">{t('nav.home')}</Link>
                    <Link href="/services" className="hover:text-white transition-colors">{t('nav.services')}</Link>
                    <Link href="/about" className="hover:text-white transition-colors">{t('nav.about')}</Link>
                    <Link href="/contact" className="hover:text-white transition-colors">{t('nav.contact')}</Link>
                </nav>

                <div className="flex items-center gap-4">

                    <Link href="/login">
                        <Button variant="ghost" className="text-white hover:bg-white/10 hover:text-white font-medium">
                            {t('nav.login')}
                        </Button>
                    </Link>
                    <LanguageSelector />
                </div>
            </div>
        </header>
    );
}
