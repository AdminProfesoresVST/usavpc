import { useTranslations } from 'next-intl';
import { ShieldCheck, Brain, FileText, CheckCircle2 } from "lucide-react";
import Image from "next/image";
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";

export default function ServicesPage() {
    const t = useTranslations('HomePage'); // Using HomePage translations for Fork for now

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
                    <h1 className="text-3xl md:text-4xl font-serif font-bold mb-4">Our Services</h1>
                    <p className="text-lg text-white/80 max-w-2xl mx-auto">Choose the level of assistance that fits your needs.</p>
                </div>
            </section>

            <section className="container mx-auto px-4 py-12">
                <div className="grid md:grid-cols-2 gap-8 items-stretch max-w-5xl mx-auto">
                    {/* Option A - DIY */}
                    <div className="bg-white rounded-lg shadow-sm border border-border p-8 flex flex-col transform transition hover:-translate-y-1 hover:shadow-md">
                        <h3 className="text-xl font-bold text-trust-navy mb-2">{t('Fork.optionA.title')}</h3>
                        <p className="text-muted-foreground mb-6 flex-grow italic">
                            "{t('Fork.optionA.desc')}"
                        </p>
                        <ul className="space-y-3 mb-8 text-sm text-gray-600">
                            <li className="flex items-start gap-2"><CheckCircle2 className="w-5 h-5 text-gray-400 shrink-0" /> Basic Eligibility Check</li>
                            <li className="flex items-start gap-2"><CheckCircle2 className="w-5 h-5 text-gray-400 shrink-0" /> Standard Form Access</li>
                            <li className="flex items-start gap-2"><CheckCircle2 className="w-5 h-5 text-gray-400 shrink-0" /> No Strategy Report</li>
                        </ul>
                        <div className="text-4xl font-bold text-primary mb-6">{t('Fork.optionA.price')}</div>
                        <Link href="/assessment?plan=diy">
                            <Button className="w-full" variant="outline">{t('Fork.optionA.cta')}</Button>
                        </Link>
                    </div>

                    {/* Option B - Full Service */}
                    <div className="bg-trust-navy text-white rounded-lg shadow-lg border border-trust-navy p-8 relative overflow-hidden flex flex-col transform transition hover:-translate-y-1 hover:shadow-xl">
                        <div className="absolute top-0 right-0 bg-accent-gold text-trust-navy text-xs font-bold px-3 py-1 uppercase tracking-wider">Recommended</div>
                        <h3 className="text-xl font-bold mb-2">{t('Fork.optionB.title')}</h3>
                        <p className="text-white/90 mb-6 flex-grow italic">
                            "{t('Fork.optionB.desc')}"
                        </p>
                        <ul className="space-y-3 mb-8 text-sm text-white/80">
                            <li className="flex items-start gap-2"><CheckCircle2 className="w-5 h-5 text-accent-gold shrink-0" /> <strong>VisaScore™</strong> Strategy Report</li>
                            <li className="flex items-start gap-2"><CheckCircle2 className="w-5 h-5 text-accent-gold shrink-0" /> Expert Review & Error Check</li>
                            <li className="flex items-start gap-2"><CheckCircle2 className="w-5 h-5 text-accent-gold shrink-0" /> Interview Preparation Guide</li>
                        </ul>
                        <div className="text-4xl font-bold text-accent-gold mb-6">{t('Fork.optionB.price')}</div>
                        <Link href="/assessment?plan=full">
                            <Button className="w-full bg-white text-[#003366] hover:bg-gray-100 font-bold border-none shadow-md">
                                {t('Fork.optionB.cta')}
                            </Button>
                        </Link>
                    </div>
                </div>
            </section>
        </div>
    );
}
