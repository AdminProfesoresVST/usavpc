"use client";

import { useTranslations } from 'next-intl';
import { useRouter } from "next/navigation";
import { useLocale } from 'next-intl';
import { Plane, Briefcase, GraduationCap, ChevronRight } from "lucide-react";

export function PurposeSelection() {
    const t = useTranslations();
    const router = useRouter();
    const locale = useLocale();

    const handlePurposeSelect = async (purpose: string) => {
        // Create draft with default plan 'full' and selected purpose
        try {
            const response = await fetch('/api/applications/draft', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ plan: 'full', locale, purpose }), // Passing purpose to backend
            });

            if (response.status === 401) {
                // Redirect to login if needed, preserving flow
                window.location.href = `/${locale}/login?next=/${locale}/scan`;
                return;
            }

            const data = await response.json();
            if (data.success) {
                router.push(`/${locale}/scan`);
            } else {
                console.error("Draft creation failed", data.error);
                router.push(`/${locale}/scan`);
            }
        } catch (e) {
            console.error(e);
            router.push(`/${locale}/scan`);
        }
    };

    return (
        <div className="flex flex-col h-full bg-[#F0F2F5]">
            <div className="flex flex-col gap-4 p-6 fade-enter">
                <p className="text-[#1F2937] text-lg font-medium mb-2">
                    {t('Home.purposeQuestion') || "¿Cuál es el motivo principal de su viaje a los Estados Unidos?"}
                </p>

                <PurposeButton
                    icon={Plane}
                    label="Turismo / Visita Familiar"
                    onClick={() => handlePurposeSelect('B1/B2')}
                />

                <PurposeButton
                    icon={Briefcase}
                    label="Negocios / Conferencia"
                    onClick={() => handlePurposeSelect('B1')}
                />

                <PurposeButton
                    icon={GraduationCap}
                    label="Estudios / Otro"
                    onClick={() => handlePurposeSelect('F1')}
                />
            </div>
        </div>
    );
}

function PurposeButton({ icon: Icon, label, onClick }: { icon: any, label: string, onClick: () => void }) {
    return (
        <button onClick={onClick} className="group w-full p-5 rounded-2xl border-2 border-gray-100 bg-white hover:border-[#2672DE] hover:bg-blue-50 transition-all flex items-center justify-between text-left active:scale-[0.98]">
            <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-full bg-[#F0F2F5] flex items-center justify-center group-hover:bg-white transition-colors">
                    <Icon className="w-5 h-5 text-[#003366]" />
                </div>
                <span className="text-[#1F2937] font-medium group-hover:text-[#003366]">{label}</span>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-300 group-hover:text-[#2672DE]" />
        </button>
    );
}
