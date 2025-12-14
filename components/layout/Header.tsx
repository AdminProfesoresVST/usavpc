import { ShieldCheck, Menu } from "lucide-react";
import { Link } from "@/src/i18n/routing";

interface HeaderProps {
    title?: string;
    subtitle?: string;
    progress?: number;
    collapsed?: boolean;
}

export function Header({ title, subtitle, progress, collapsed = false }: HeaderProps) {
    return (
        <header className={`bg-[#003366] text-white pt-10 px-6 shadow-lg flex-none z-20 relative transition-all duration-300 ${collapsed ? 'pb-4 rounded-b-[1.5rem]' : 'pb-6 rounded-b-[2rem]'}`}>
            <div className={`flex justify-between items-center transition-all ${collapsed ? 'mb-0' : 'mb-4'}`}>
                <Link href="/" className="flex items-center gap-2">
                    <div className="bg-white/10 p-1.5 rounded-lg backdrop-blur-sm">
                        <ShieldCheck className="w-5 h-5 text-white" />
                    </div>
                    <span className="font-bold tracking-tight text-sm opacity-90">USAVPC Mobile</span>
                </Link>
                <button className="text-white/80 hover:text-white">
                    <Menu className="w-6 h-6" />
                </button>
            </div>

            {/* Dynamic Content */}
            {!collapsed && (
                <div className="fade-enter block">
                    {subtitle && <p className="text-blue-200 text-xs font-medium uppercase tracking-wider mb-1">{subtitle}</p>}
                    {title && <h1 className="text-xl font-bold">{title}</h1>}

                    {/* Progress Bar */}
                    {progress !== undefined && (
                        <div className="mt-4 h-1.5 bg-white/20 rounded-full overflow-hidden w-full max-w-[200px]">
                            <div
                                className="h-full bg-[#2672DE] transition-all duration-500 ease-out"
                                style={{ width: `${progress}%` }}
                            ></div>
                        </div>
                    )}
                </div>
            )}
        </header>
    );
}
