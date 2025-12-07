"use client";

import { useTranslations } from 'next-intl';
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import Image from "next/image";
import {
    ArrowRight,
    FileText,
    ShieldCheck,
    Zap,
    BrainCircuit,
    ChevronRight,
    PlayCircle,
    Briefcase,
    Download
} from "lucide-react";
import { MobileMenu } from "@/components/layout/MobileMenu";
import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';
import { useState } from "react";

// ... imports ...

export function MobileHome() {
    const t = useTranslations();
    const router = useRouter();
    const locale = useLocale();
    const [isProcessing, setIsProcessing] = useState<string | null>(null);

    const handlePlanSelect = async (plan: string) => {
        setIsProcessing(plan);
        try {
            const response = await fetch('/api/applications/draft', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ plan, locale }),
            });

            if (response.status === 401) {
                // Not logged in -> Register/Login with next param
                router.push(`/${locale}/login?next=/${locale}/assessment?plan=${plan}`);
                return;
            }

            const data = await response.json();
            if (data.success) {
                router.push(`/${locale}/assessment`);
            } else {
                console.error("Draft Error:", data.error);
                setIsProcessing(null);
            }
        } catch (e) {
            console.error(e);
            setIsProcessing(null);
        }
    };

    return (
        <div className="min-h-screen w-full bg-official-grey text-trust-navy flex flex-col font-sans">
            {/* 1. App Header (Sticky) */}
            <header className="sticky top-0 h-20 bg-white px-5 flex items-center justify-between shadow-sm shrink-0 z-50 transition-all">
                <div>
                    <h1 className="text-lg font-black text-trust-navy leading-none tracking-tight">
                        {t('Common.Mobile.title')}
                    </h1>
                    <div className="flex items-center gap-1.5 mt-1">
                        <div className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse"></div>
                        <p className="text-[10px] text-gray-400 uppercase tracking-widest font-bold">
                            System Online
                        </p>
                    </div>
                </div>
                <MobileMenu />
            </header>

            {/* 2. Main Content (Scrollable) */}
            <main className="flex-1 p-3 flex flex-col gap-3">

                {/* A. Hero / Action Area (Compact, High Impact) */}
                <section className="bg-trust-navy rounded-2xl p-5 text-white shadow-lg relative overflow-hidden flex flex-col justify-center shrink-0 min-h-[140px]">
                    {/* 1. Real Image Background (Added per User Request) */}
                    <div className="absolute inset-0 z-0">
                        <Image
                            src="/bg-hero.png"
                            alt="US Visa Center"
                            fill
                            className="object-cover object-center opacity-20 mixed-blend-overlay"
                            priority
                        />
                        {/* Gradient Overlay for Text Readability */}
                        <div className="absolute inset-0 bg-gradient-to-r from-trust-navy via-trust-navy/80 to-transparent"></div>
                    </div>

                    <div className="relative z-10 flex flex-col h-full justify-between">
                        <div className="flex items-start justify-between">
                            <div>
                                <div className="inline-flex items-center gap-1.5 bg-white/10 px-2 py-0.5 rounded-full text-[9px] uppercase tracking-wide font-bold mb-2 border border-white/20 text-accent-gold">
                                    <ShieldCheck className="w-3 h-3" /> Official Service
                                </div>
                                <h2 className="text-2xl font-black leading-none mb-1 text-white tracking-tight">
                                    Visa USA
                                </h2>
                                <p className="text-white/70 text-xs font-medium leading-snug">
                                    AI-Assisted Application
                                </p>
                            </div>
                        </div>

                        <Link href="/services" className="mt-3 w-full">
                            <Button className="w-full bg-white text-trust-navy hover:bg-gray-100 font-bold h-10 rounded-xl text-sm shadow-xl transition-all active:scale-95 flex items-center justify-between px-4">
                                <span>Start New Application</span>
                                <div className="bg-trust-navy/10 rounded-full p-1">
                                    <ArrowRight className="w-4 h-4 text-trust-navy" />
                                </div>
                            </Button>
                        </Link>
                    </div>
                </section>

                {/* B. Services Grid (3 Equal Cards) */}
                <section id="services" className="grid grid-rows-[auto_1fr] gap-2 min-h-0 bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden text-left">
                    <div className="px-4 py-2 border-b border-gray-100 bg-gray-50/50 flex justify-between items-center">
                        <h3 className="font-extrabold text-[10px] text-gray-400 uppercase tracking-widest">Select Packet</h3>
                        <button onClick={() => {
                            const servicesSection = document.getElementById('services');
                            if (servicesSection) servicesSection.scrollIntoView({ behavior: 'smooth' });
                        }} className="text-[10px] text-trust-navy font-bold hover:underline">Compare Plans</button>
                    </div>

                    <div className="p-2 grid grid-rows-3 gap-2 min-h-0">
                        {/* Card 01 - Full Service */}
                        <div onClick={() => handlePlanSelect('full')} className="relative bg-gray-50 hover:bg-blue-50 border border-transparent hover:border-blue-100 rounded-xl p-3 flex items-center justify-between transition-all group overflow-hidden cursor-pointer active:scale-98">
                            {isProcessing === 'full' && <div className="absolute inset-0 bg-white/50 z-20 flex items-center justify-center"><div className="w-5 h-5 border-2 border-trust-navy border-t-transparent rounded-full animate-spin"></div></div>}
                            <div className="absolute left-0 top-0 bottom-0 w-1 bg-trust-navy rounded-l-xl"></div>
                            <div className="flex items-center gap-3 ml-2">
                                <div className="text-trust-navy font-black text-lg w-6">01</div>
                                <div>
                                    <h4 className="font-bold text-sm text-trust-navy leading-tight">Full Concierge</h4>
                                    <p className="text-[10px] text-gray-500 font-medium leading-none mt-0.5">We file everything for you</p>
                                </div>
                            </div>
                            <div className="text-right">
                                <span className="font-black text-trust-navy text-sm block">$99</span>
                            </div>
                        </div>

                        {/* Card 02 - DIY */}
                        <div onClick={() => handlePlanSelect('diy')} className="bg-white hover:bg-gray-50 border border-gray-100 hover:border-gray-200 rounded-xl p-3 flex items-center justify-between transition-all group cursor-pointer active:scale-98 relative">
                            {isProcessing === 'diy' && <div className="absolute inset-0 bg-white/50 z-20 flex items-center justify-center"><div className="w-5 h-5 border-2 border-trust-navy border-t-transparent rounded-full animate-spin"></div></div>}
                            <div className="flex items-center gap-3 ml-1">
                                <div className="text-gray-300 font-black text-lg w-6 group-hover:text-gray-400 transition-colors">02</div>
                                <div>
                                    <h4 className="font-bold text-sm text-gray-900 leading-tight">DIY Audit</h4>
                                    <p className="text-[10px] text-gray-500 font-medium leading-none mt-0.5">AI Check & Report</p>
                                </div>
                            </div>
                            <span className="font-bold text-gray-600 text-sm">$39</span>
                        </div>

                        {/* Card 03 - Simulator */}
                        <div onClick={() => handlePlanSelect('simulator')} className="bg-white hover:bg-gray-50 border border-gray-100 hover:border-gray-200 rounded-xl p-3 flex items-center justify-between transition-all group cursor-pointer active:scale-98 relative">
                            {isProcessing === 'simulator' && <div className="absolute inset-0 bg-white/50 z-20 flex items-center justify-center"><div className="w-5 h-5 border-2 border-trust-navy border-t-transparent rounded-full animate-spin"></div></div>}
                            <div className="flex items-center gap-3 ml-1">
                                <div className="text-gray-300 font-black text-lg w-6 group-hover:text-gray-400 transition-colors">03</div>
                                <div>
                                    <h4 className="font-bold text-sm text-gray-900 leading-tight">Simulator</h4>
                                    <p className="text-[10px] text-gray-500 font-medium leading-none mt-0.5">Interview Practice</p>
                                </div>
                            </div>
                            <span className="font-bold text-gray-600 text-sm">$29</span>
                        </div>
                    </div>
                </section>
            </main>

            {/* 3. Footer (Fixed) */}
            <footer className="h-8 bg-white border-t border-gray-100 flex items-center justify-between px-5 text-[9px] text-gray-400 shrink-0">
                <div className="flex gap-3">
                    <span className="flex items-center gap-1 font-medium"><ShieldCheck className="w-2.5 h-2.5 text-trust-navy" /> Encrypted</span>
                    <span className="flex items-center gap-1 font-medium"><BrainCircuit className="w-2.5 h-2.5 text-trust-navy" /> AI-Powered</span>
                </div>
                <span className="font-mono font-bold text-accent-gold">v1.5.5</span>
            </footer>
        </div>
    );
}
