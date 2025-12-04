import { useTranslations } from 'next-intl';
import { Shield, Users, AlertTriangle } from "lucide-react";
import Image from "next/image";

export default function AboutPage() {
    const t = useTranslations('About');

    return (
        <div className="flex flex-col min-h-screen bg-official-grey">
            <section className="relative bg-trust-navy text-white py-16 border-b-4 border-accent-gold overflow-hidden">
                <div className="absolute inset-0 z-0">
                    <Image
                        src="/bg-hero.png"
                        alt="Background"
                        fill
                        className="object-cover object-center opacity-20"
                        priority
                    />
                </div>
                <div className="container mx-auto px-4 text-center relative z-10">
                    <h1 className="text-3xl md:text-4xl font-serif font-bold mb-4 text-white">{t('title')}</h1>
                </div>
            </section>

            <section className="container mx-auto px-4 py-12 max-w-4xl">
                <div className="space-y-8">
                    <div className="bg-white p-8 rounded-lg shadow-sm border border-border flex gap-6 items-start">
                        <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center shrink-0">
                            <Users className="w-6 h-6 text-primary" />
                        </div>
                        <div>
                            <h3 className="font-serif font-bold text-xl mb-3 text-trust-navy">{t('missionTitle')}</h3>
                            <p className="text-muted-foreground leading-relaxed">{t('missionDesc')}</p>
                        </div>
                    </div>

                    <div className="bg-white p-8 rounded-lg shadow-sm border border-border flex gap-6 items-start">
                        <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center shrink-0">
                            <Shield className="w-6 h-6 text-primary" />
                        </div>
                        <div>
                            <h3 className="font-serif font-bold text-xl mb-3 text-trust-navy">{t('securityTitle')}</h3>
                            <p className="text-muted-foreground leading-relaxed">{t('securityDesc')}</p>
                        </div>
                    </div>

                    <div className="bg-red-50 p-8 rounded-lg border border-red-100 flex gap-6 items-start">
                        <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center shrink-0">
                            <AlertTriangle className="w-6 h-6 text-alert-red" />
                        </div>
                        <div>
                            <h3 className="font-serif font-bold text-xl mb-3 text-alert-red">{t('disclaimerTitle')}</h3>
                            <p className="text-red-900/80 leading-relaxed font-medium">{t('disclaimerDesc')}</p>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    );
}
