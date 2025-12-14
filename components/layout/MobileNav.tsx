"use client";

import { Link } from "@/src/i18n/routing";
import { useTranslations } from "next-intl";
import { usePathname } from "next/navigation";
import { Home, Briefcase, Activity, Settings, Plus, MessageSquare, User } from "lucide-react";
import { SettingsMenu } from "./SettingsMenu";

export function MobileNav() {
    const t = useTranslations();
    const pathname = usePathname();

    const isActive = (path: string) => pathname === path || pathname?.startsWith(`${path}/`);

    const navItems = [
        {
            label: t('Common.nav.home'),
            href: "/",
            icon: Home
        },
        {
            label: t('Common.nav.services'),
            href: "/services",
            icon: Briefcase
        },
        {
            label: t('Common.nav.status'),
            href: "/dashboard",
            icon: Activity
        }
    ];

    return (
        <nav className="bg-white border-t border-gray-200 px-4 py-2 safe-bottom flex justify-between items-center z-30 flex-none text-[10px] shadow-[0_-4px_15px_-3px_rgba(0,0,0,0.05)]">
            <Link href="/" className="flex flex-col items-center gap-1 p-2 min-w-[50px] text-[#2672DE] transition-colors rounded-lg active:bg-gray-50">
                <Home className="w-5 h-5 stroke-[2.5]" />
                <span className="font-semibold">{t('Common.nav.home')}</span>
            </Link>

            <Link href="/services" className="flex flex-col items-center gap-1 p-2 min-w-[50px] text-gray-400 hover:text-[#003366] transition-colors rounded-lg active:bg-gray-50">
                <Briefcase className="w-5 h-5" />
                <span className="font-medium">{t('Common.nav.services')}</span>
            </Link>

            {/* Central Action Button */}
            <Link href="/assessment" className="bg-[#2672DE] text-white p-2.5 rounded-xl shadow-md active:scale-95 transition-transform mx-1 hover:bg-[#003366]">
                <Plus className="w-5 h-5 stroke-[3]" />
            </Link>

            <Link href="/support" className="flex flex-col items-center gap-1 p-2 min-w-[50px] text-gray-400 hover:text-[#003366] transition-colors rounded-lg active:bg-gray-50">
                <MessageSquare className="w-5 h-5" />
                <span className="font-medium">{t('Common.nav.status')}</span>
            </Link>

            <Link href="/profile" className="flex flex-col items-center gap-1 p-2 min-w-[50px] text-gray-400 hover:text-[#003366] transition-colors rounded-lg active:bg-gray-50">
                <User className="w-5 h-5" />
                <span className="font-medium">Profile</span>
            </Link>
        </nav>
    );
}
