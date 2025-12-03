import { useTranslations } from 'next-intl';
import { Mail } from "lucide-react";
import Image from "next/image";
import { ContactForm } from "@/components/contact/ContactForm";

export default function ContactPage() {
    const t = useTranslations('Contact');

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

                    <ContactForm />
                </div>
            </section>
        </div>
    );
}
