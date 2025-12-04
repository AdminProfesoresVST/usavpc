"use client";

import { Link } from "@/src/i18n/routing";
import { usePathname } from "next/navigation";
import { Home, Briefcase, Activity, Menu } from "lucide-react";

export function MobileNav() {
    const pathname = usePathname();

    const isActive = (path: string) => pathname === path || pathname?.startsWith(`${path}/`);

    const navItems = [
        {
            label: "Home",
            href: "/",
            icon: Home
        },
        {
            label: "Services",
            href: "/services",
            icon: Briefcase
        },
        {
            label: "Status",
            href: "/dashboard",
            icon: Activity
        },
        {
            label: "Menu",
            href: "/contact", // Temporary mapping for Menu until we have a full menu
            icon: Menu
        }
    ];

    return (
        <div className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 pb-safe md:hidden">
            <div className="flex justify-around items-center h-16">
                {navItems.map((item) => {
                    const Icon = item.icon;
                    const active = isActive(item.href);

                    return (
                        <Link
                            key={item.href}
                            href={item.href}
                            className={`flex flex-col items-center justify-center w-full h-full space-y-1 ${active ? "text-trust-navy" : "text-gray-400 hover:text-gray-600"
                                }`}
                        >
                            <Icon className={`w-6 h-6 ${active ? "fill-current" : ""}`} strokeWidth={active ? 2.5 : 2} />
                            <span className="text-[10px] font-medium">{item.label}</span>
                        </Link>
                    );
                })}
            </div>
        </div>
    );
}
