"use client";

import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { User, FileText, Shield, HelpCircle, LogOut, Settings } from "lucide-react";
import { Link } from "@/src/i18n/routing";
import { useTranslations } from "next-intl";

export function SettingsMenu({ children }: { children: React.ReactNode }) {
    const t = useTranslations();

    const menuItems = [
        {
            label: t('Settings.profile'),
            href: "/dashboard",
            icon: User,
            color: "text-trust-navy"
        },
        {
            label: t('Settings.privacy'),
            href: "/legal/privacy",
            icon: Shield,
            color: "text-gray-600"
        },
        {
            label: t('Settings.terms'),
            href: "/legal/terms",
            icon: FileText,
            color: "text-gray-600"
        },
        {
            label: t('Settings.refund'),
            href: "/legal/refund",
            icon: HelpCircle,
            color: "text-gray-600"
        }
    ];

    return (
        <Dialog>
            <DialogTrigger asChild>
                {children}
            </DialogTrigger>
            <DialogContent className="w-[90%] rounded-2xl p-0 overflow-hidden gap-0">
                <div className="bg-trust-navy p-6 text-white">
                    <div className="flex items-center gap-3 mb-2">
                        <div className="p-2 bg-white/10 rounded-full">
                            <Settings className="w-6 h-6" />
                        </div>
                        <DialogTitle className="text-xl font-bold">
                            {t('Settings.title')}
                        </DialogTitle>
                    </div>
                    <p className="text-white/70 text-sm">
                        {t('Settings.subtitle')}
                    </p>
                </div>

                <div className="p-4 space-y-2">
                    {menuItems.map((item) => {
                        const Icon = item.icon;
                        return (
                            <Link
                                key={item.href}
                                href={item.href}
                                className="flex items-center gap-4 p-4 rounded-xl hover:bg-gray-50 transition-colors border border-transparent hover:border-gray-100"
                            >
                                <div className={`p-2 rounded-lg bg-gray-50 ${item.color}`}>
                                    <Icon className="w-5 h-5" />
                                </div>
                                <span className="font-medium text-gray-900">{item.label}</span>
                            </Link>
                        );
                    })}

                    <div className="h-px bg-gray-100 my-2" />

                    <Button variant="ghost" className="w-full justify-start gap-4 p-4 text-red-600 hover:text-red-700 hover:bg-red-50 rounded-xl h-auto">
                        <div className="p-2 rounded-lg bg-red-50">
                            <LogOut className="w-5 h-5" />
                        </div>
                        <span className="font-medium">{t('Settings.logout')}</span>
                    </Button>
                </div>
            </DialogContent>
        </Dialog>
    );
}
