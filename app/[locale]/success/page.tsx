"use client";

import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';
import { Award, Star, FileCheck, ArrowRight } from "lucide-react";
import { Header } from "@/components/layout/Header";

export default function SuccessPage() {
    const router = useRouter();
    const locale = useLocale();

    return (
        <div className="flex flex-col h-full bg-[#F0F2F5]">
            <Header />

            <div className="fade-enter flex flex-col items-center h-full pt-4 px-6 overflow-y-auto">
                {/* Success Badge */}
                <div className="relative mb-6">
                    <div className="absolute inset-0 bg-blue-200 blur-xl opacity-50 rounded-full"></div>
                    <div className="relative bg-white p-2 rounded-full shadow-md">
                        <Award className="w-12 h-12 text-[#2672DE] fill-blue-50" />
                    </div>
                </div>

                <h2 className="text-2xl font-bold text-[#003366] mb-2 text-center">¡Perfil Sobresaliente!</h2>
                <p className="text-gray-500 text-center mb-8 max-w-[90%]">
                    Basado en sus respuestas, su probabilidad de aprobación es alta.
                </p>

                {/* Strategy Card */}
                <div className="w-full bg-[#003366] rounded-2xl p-6 text-white shadow-xl relative overflow-hidden mb-6 flex-none">
                    <div className="absolute top-0 right-0 w-32 h-32 bg-white/5 rounded-full -mr-10 -mt-10"></div>
                    <div className="absolute bottom-0 left-0 w-24 h-24 bg-[#2672DE]/20 rounded-full -ml-10 -mb-10"></div>

                    <div className="relative z-10">
                        <span className="text-[10px] font-bold tracking-widest uppercase text-blue-200 mb-2 block">Estrategia Recomendada</span>
                        <p className="text-sm text-blue-50 leading-relaxed mb-6">
                            Le recomendamos nuestro <strong>Servicio Integral</strong> para asegurar que cada detalle técnico de su formulario DS-160 sea perfecto.
                        </p>

                        <div className="grid grid-cols-2 gap-3">
                            <div className="bg-white/10 p-2 rounded-lg flex items-center gap-2 backdrop-blur-sm">
                                <Star className="w-4 h-4 text-[#F0F2F5]" />
                                <span className="text-xs font-medium">Revisión Experta</span>
                            </div>
                            <div className="bg-white/10 p-2 rounded-lg flex items-center gap-2 backdrop-blur-sm">
                                <FileCheck className="w-4 h-4 text-[#F0F2F5]" />
                                <span className="text-xs font-medium">Prep. Entrevista</span>
                            </div>
                        </div>
                    </div>
                </div>

                <button
                    onClick={() => router.push(`/${locale}/assessment`)}
                    className="w-full bg-[#2672DE] text-white py-4 rounded-xl font-semibold shadow-md active:scale-95 transition-all mt-auto mb-6 flex items-center justify-center gap-2 group"
                >
                    Iniciar Aplicación
                    <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                </button>
            </div>
        </div>
    );
}
