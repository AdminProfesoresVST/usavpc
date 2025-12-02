import { useTranslations } from 'next-intl';
import { ShieldCheck, Brain, FileText } from "lucide-react";
import Image from "next/image";

export default function ServicesPage() {
    const t = useTranslations('Services');

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
                    <h1 className="text-3xl md:text-4xl font-serif font-bold mb-4">{t('title')}</h1>
                    <p className="text-lg text-white/80 max-w-2xl mx-auto">{t('subtitle')}</p>
                </div>
            </section>

            <section className="container mx-auto px-4 py-12">
                <div className="grid md:grid-cols-3 gap-8">
                    <div className="bg-white p-8 rounded-lg shadow-sm border border-border">
                        <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mb-6">
                            <Brain className="w-6 h-6 text-primary" />
                        </div>
                        <h3 className="font-serif font-bold text-xl mb-3 text-trust-navy">{t('analysisTitle')}</h3>
                        <p className="text-muted-foreground leading-relaxed">{t('analysisDesc')}</p>
                    </div>

                    <div className="bg-white p-8 rounded-lg shadow-sm border border-border">
                        <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mb-6">
                            <FileText className="w-6 h-6 text-primary" />
                        </div>
                        <h3 className="font-serif font-bold text-xl mb-3 text-trust-navy">{t('strategyTitle')}</h3>
                        <p className="text-muted-foreground leading-relaxed">{t('strategyDesc')}</p>
                    </div>

                    <div className="bg-white p-8 rounded-lg shadow-sm border border-border">
                        <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mb-6">
                            <ShieldCheck className="w-6 h-6 text-primary" />
                        </div>
                        <h3 className="font-serif font-bold text-xl mb-3 text-trust-navy">{t('documentTitle')}</h3>
                        <p className="text-muted-foreground leading-relaxed">{t('documentDesc')}</p>
                    </div>
                </div>
            </section>
        </div>
    );
}
