import { Lock } from "lucide-react";
import Link from "next/link";
import { useTranslations } from 'next-intl';

export function Header() {
    const t = useTranslations('Common');

    return (
        <header className="sticky top-0 z-50 w-full bg-primary text-primary-foreground shadow-md">
            <div className="container mx-auto flex h-16 items-center justify-between px-4 md:px-6">
                <Link href="/" className="flex items-center gap-2">
                    <div className="flex h-8 w-8 items-center justify-center rounded-sm bg-white/10">
                        <span className="font-serif text-lg font-bold text-white">US</span>
                    </div>
                    <span className="font-serif text-lg font-bold tracking-tight text-white">
                        US Visa Processing Center
                    </span>
                </Link>
                <div className="flex items-center gap-2 text-sm font-medium text-white/90">
                    <Lock className="h-4 w-4" />
                    <span className="hidden sm:inline-block">{t('secureConnection')}</span>
                    <span className="sm:hidden">{t('secure')}</span>
                </div>
            </div>
        </header>
    );
}
