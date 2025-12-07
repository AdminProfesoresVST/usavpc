"use client";

import { useTranslations } from 'next-intl';
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
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
import { SafeInterviewGuideButton } from "@/components/pdf/SafeInterviewGuideButton";

export function MobileHome() {
    const t = useTranslations();

    return (
        <div className="flex flex-col min-h-screen bg-gray-50 pb-12">
            {/* App Header */}
            <div className="bg-white px-4 py-4 border-b border-gray-100 sticky top-0 z-10">
                <h1 className="text-xl font-bold text-trust-navy">
                    {t('Common.Mobile.title')}
                </h1>
                <p className="text-xs text-gray-500">
                    {t('Common.Mobile.subtitle')}
                </p>
            </div>

            <div className="p-4 space-y-4">
                {/* Primary Action Card */}
                <div className="bg-trust-navy rounded-2xl p-5 text-white shadow-lg shadow-trust-navy/20 relative overflow-hidden group">
                    <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl"></div>

                    <div className="relative z-10">
                        <div className="inline-flex items-center gap-2 bg-white/10 px-2 py-0.5 rounded-full text-[9px] font-medium mb-3 border border-white/20">
                            <ShieldCheck className="w-3 h-3" />
                            <span>SECURE & ENCRYPTED</span>
                        </div>

                        <h2 className="text-xl font-bold mb-1 leading-tight text-white">
                            Start Your Visa Application
                        </h2>
                        <p className="text-white/80 text-xs mb-4 leading-relaxed">
                            Complete your DS-160 with AI assistance and expert review.
                        </p>

                        <Link href="/services" className="block">
                            <Button className="w-full bg-white text-trust-navy hover:bg-white/90 font-bold h-10 rounded-xl shadow-sm text-sm">
                                Check Eligibility
                                <ArrowRight className="w-4 h-4 ml-2" />
                            </Button>
                        </Link>
                    </div>
                </div>

                {/* Quick Actions Grid */}
                <div className="grid grid-cols-2 gap-4">
                    <Link href="/dashboard" className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 active:scale-95 transition-transform">
                        <div className="w-10 h-10 bg-blue-50 rounded-full flex items-center justify-center mb-3">
                            <FileText className="w-5 h-5 text-trust-navy" />
                        </div>
                        <h3 className="font-bold text-gray-900 text-sm">My Status</h3>
                        <p className="text-xs text-gray-500 mt-1">Track application</p>
                    </Link>

                    <Link href="/services" className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 active:scale-95 transition-transform">
                        <div className="w-10 h-10 bg-gray-50 rounded-full flex items-center justify-center mb-3">
                            <Zap className="w-5 h-5 text-trust-navy" />
                        </div>
                        <h3 className="font-bold text-gray-900 text-sm">Express</h3>
                        <p className="text-xs text-gray-500 mt-1">24h Processing</p>
                    </Link>
                </div>

                {/* Free Resources Card */}
                <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100">
                    <div className="flex items-center gap-3 mb-4">
                        <div className="w-10 h-10 bg-green-50 rounded-full flex items-center justify-center">
                            <Download className="w-5 h-5 text-green-600" />
                        </div>
                        <div>
                            <h3 className="font-bold text-gray-900">Recursos Gratuitos</h3>
                            <p className="text-xs text-gray-500">Guía de Entrevista</p>
                        </div>
                    </div>
                    <p className="text-sm text-gray-600 mb-4 leading-relaxed">
                        Descargue nuestra guía oficial de preparación para la entrevista sin costo.
                    </p>
                    <div className="w-full">
                        <SafeInterviewGuideButton />
                    </div>
                </div>

                {/* Services List (App Menu Style) */}
                <div className="bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden">
                    <div className="p-4 border-b border-gray-50">
                        <h3 className="font-bold text-gray-900">Available Services</h3>
                    </div>

                    <div className="divide-y divide-gray-50">
                        <Link href="/services?plan=full" className="flex items-center justify-between p-4 hover:bg-gray-50 transition-colors">
                            <div className="flex items-center gap-4">
                                <div className="w-10 h-10 bg-trust-navy/5 rounded-xl flex items-center justify-center">
                                    <Briefcase className="w-5 h-5 text-trust-navy" />
                                </div>
                                <div>
                                    <h4 className="font-semibold text-sm text-gray-900">Full Service</h4>
                                    <p className="text-xs text-gray-500">End-to-end management</p>
                                </div>
                            </div>
                            <ChevronRight className="w-5 h-5 text-gray-300" />
                        </Link>

                        <Link href="/services?plan=diy" className="flex items-center justify-between p-4 hover:bg-gray-50 transition-colors">
                            <div className="flex items-center gap-4">
                                <div className="w-10 h-10 bg-gray-50 rounded-xl flex items-center justify-center">
                                    <BrainCircuit className="w-5 h-5 text-trust-navy" />
                                </div>
                                <div>
                                    <h4 className="font-semibold text-sm text-gray-900">DIY Audit</h4>
                                    <p className="text-xs text-gray-500">AI Risk Analysis</p>
                                </div>
                            </div>
                            <ChevronRight className="w-5 h-5 text-gray-300" />
                        </Link>

                        <Link href="/services?plan=simulator" className="flex items-center justify-between p-4 hover:bg-gray-50 transition-colors">
                            <div className="flex items-center gap-4">
                                <div className="w-10 h-10 bg-gray-50 rounded-xl flex items-center justify-center">
                                    <PlayCircle className="w-5 h-5 text-trust-navy" />
                                </div>
                                <div>
                                    <h4 className="font-semibold text-sm text-gray-900">Interview Sim</h4>
                                    <p className="text-xs text-gray-500">Practice with AI</p>
                                </div>
                            </div>
                            <ChevronRight className="w-5 h-5 text-gray-300" />
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
}
