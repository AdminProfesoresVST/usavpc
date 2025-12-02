import { useTranslations } from 'next-intl';
import { Mail } from "lucide-react";

export default function ContactPage() {
    const t = useTranslations('Contact');

    return (
        <div className="flex flex-col min-h-screen bg-official-grey">
            <section className="bg-trust-navy text-white py-16 border-b-4 border-accent-gold">
                <div className="container mx-auto px-4 text-center">
                    <h1 className="text-3xl md:text-4xl font-serif font-bold mb-4">{t('title')}</h1>
                </div>
            </section>

            <section className="container mx-auto px-4 py-12 max-w-2xl">
                <div className="bg-white p-8 rounded-lg shadow-sm border border-border text-center">
                    <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-6">
                        <Mail className="w-8 h-8 text-primary" />
                    </div>
                    <p className="text-lg text-muted-foreground mb-8 leading-relaxed">
                        {t('desc')}
                    </p>
                    <a
                        href={`mailto:${t('email')}`}
                        className="inline-flex items-center justify-center px-8 py-3 bg-primary text-white font-bold rounded-sm hover:bg-primary/90 transition-colors"
                    >
                        {t('email')}
                    </a>
                </div>
            </section>
        </div>
    );
}
