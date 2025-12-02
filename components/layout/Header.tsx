import { Lock } from "lucide-react";
import Link from "next/link";
import Image from "next/image";
import { useTranslations } from 'next-intl';

export function Header() {
    const t = useTranslations('Common');

    return (
        <header className="sticky top-0 z-50 w-full bg-primary text-primary-foreground shadow-md backdrop-blur-sm bg-primary/95 supports-[backdrop-filter]:bg-primary/90">
            <div className="container mx-auto flex h-16 items-center justify-between px-4 md:px-6">
                <Link href="/" className="flex items-center gap-3 group">
                    <div className="relative h-10 w-10 overflow-hidden rounded-sm bg-white p-0.5 transition-transform group-hover:scale-105">
                        <Image
                            src="/logo.png"
                            alt="US Visa Processing Center Logo"
                            width={40}
                            height={40}
                            className="object-contain"
                        />
                    </div>
                    <span className="font-serif text-lg font-bold tracking-tight text-white group-hover:text-white/90 transition-colors">
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
