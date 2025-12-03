import { useTranslations } from 'next-intl';
import { ShieldCheck, Brain, FileText, CheckCircle2, AlertTriangle } from "lucide-react";
import Image from "next/image";
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import { FullServiceCheckoutButton } from "@/components/services/FullServiceCheckoutButton";

export default function ServicesPage() {
    const t = useTranslations('Services');

    return (
        <div className="flex flex-col min-h-screen bg-official-grey">
            <section className="relative bg-trust-navy text-white py-20 border-b-4 border-accent-gold overflow-hidden">
                <div className="absolute inset-0 z-0">
                    <Image
                        src="/bg-hero.png"
                        alt="Background"
                        fill
                        className="object-cover object-center opacity-20"
                        priority
                    />
                </div>
                <div className="container mx-auto px-4 text-center relative z-10 max-w-4xl">
                    <h1 className="text-3xl md:text-5xl font-serif font-bold mb-6 tracking-tight">{t('title')}</h1>
                    <p className="text-xl font-medium text-white/90 mb-6 leading-relaxed">{t('subtitle')}</p>
                    <p className="text-lg text-white/80 leading-relaxed font-light">{t('description')}</p>
                </div>
            </section>

            <section className="container mx-auto px-4 py-16">
                <div className="grid md:grid-cols-2 gap-8 items-stretch max-w-6xl mx-auto">
                    {/* Option A - DIY */}
                    <div className="bg-white rounded-lg shadow-md border border-border p-8 flex flex-col transform transition hover:-translate-y-1 hover:shadow-xl relative">
                        <div className="mb-6">
                            <h3 className="text-2xl font-serif font-bold text-trust-navy mb-2">{t('OptionA.title')}</h3>
                            <p className="text-sm font-bold text-accent-gold uppercase tracking-wider mb-4">{t('OptionA.subtitle')}</p>
                            <p className="text-muted-foreground italic mb-6 border-l-4 border-gray-200 pl-4">
                                "{t('OptionA.desc')}"
                            </p>
                        </div>

                        <ul className="space-y-4 mb-8 text-sm text-gray-700 flex-grow">
                            <li className="flex items-start gap-3">
                                <Brain className="w-5 h-5 text-trust-navy shrink-0 mt-0.5" />
                                <span>{t('OptionA.feature1')}</span>
                            </li>
                            <li className="flex items-start gap-3">
                                <AlertTriangle className="w-5 h-5 text-trust-navy shrink-0 mt-0.5" />
                                <span>{t('OptionA.feature2')}</span>
                            </li>
                            <li className="flex items-start gap-3">
                                <FileText className="w-5 h-5 text-trust-navy shrink-0 mt-0.5" />
                                <span>{t('OptionA.feature3')}</span>
                            </li>
                        </ul>

                        <div className="mt-auto">
                            <div className="text-4xl font-bold text-primary mb-2">{t('OptionA.price')}</div>
                            <p className="text-xs text-red-500 font-medium mb-6">{t('OptionA.note')}</p>
                            <Link href="/assessment?plan=diy">
                                <Button className="w-full py-6 text-lg" variant="outline">{t('OptionA.cta')}</Button>
                            </Link>
                        </div>
                    </div>

                    {/* Option B - Full Service */}
                    <div className="bg-trust-navy text-white rounded-lg shadow-2xl border-2 border-accent-gold p-8 relative overflow-hidden flex flex-col transform transition hover:-translate-y-1 hover:shadow-3xl">
                        <div className="absolute top-0 right-0 bg-accent-gold text-trust-navy text-xs font-bold px-4 py-1.5 uppercase tracking-wider shadow-sm">
                            {t('OptionB.recommended')}
                        </div>

                        <div className="mb-6">
                            <h3 className="text-2xl font-serif font-bold mb-2">{t('OptionB.title')}</h3>
                            <p className="text-sm font-bold text-accent-gold uppercase tracking-wider mb-4">{t('OptionB.subtitle')}</p>
                            <p className="text-white/90 italic mb-6 border-l-4 border-accent-gold/50 pl-4">
                                "{t('OptionB.desc')}"
                            </p>
                        </div>

                        <ul className="space-y-4 mb-8 text-sm text-white/90 flex-grow">
                            <li className="flex items-start gap-3">
                                <CheckCircle2 className="w-5 h-5 text-accent-gold shrink-0 mt-0.5" />
                                <span>{t('OptionB.feature1')}</span>
                            </li>
                            <li className="flex items-start gap-3">
                                <CheckCircle2 className="w-5 h-5 text-accent-gold shrink-0 mt-0.5" />
                                <span>{t('OptionB.feature2')}</span>
                            </li>
                            <li className="flex items-start gap-3">
                                <CheckCircle2 className="w-5 h-5 text-accent-gold shrink-0 mt-0.5" />
                                <span>{t('OptionB.feature3')}</span>
                            </li>
                        </ul>

                        <div className="mt-auto">
                            <div className="text-4xl font-bold text-accent-gold mb-6">{t('OptionB.price')}</div>
                            <FullServiceCheckoutButton
                                label={t('OptionB.cta')}
                                price={t('OptionB.price')}
                            />
                        </div>
                    </div>

                    {/* Option C - Simulator */}
                    <div className="bg-white rounded-lg shadow-md border border-border p-8 flex flex-col transform transition hover:-translate-y-1 hover:shadow-xl relative md:col-span-2 lg:col-span-1">
                        <div className="mb-6">
                            <h3 className="text-2xl font-serif font-bold text-trust-navy mb-2">{t('OptionC.title')}</h3>
                            <p className="text-sm font-bold text-accent-gold uppercase tracking-wider mb-4">{t('OptionC.subtitle')}</p>
                            <p className="text-muted-foreground italic mb-6 border-l-4 border-gray-200 pl-4">
                                "{t('OptionC.desc')}"
                            </p>
                        </div>

                        <ul className="space-y-4 mb-8 text-sm text-gray-700 flex-grow">
                            <li className="flex items-start gap-3">
                                <Brain className="w-5 h-5 text-trust-navy shrink-0 mt-0.5" />
                                <span>{t('OptionC.feature1')}</span>
                            </li>
                            <li className="flex items-start gap-3">
                                <ShieldCheck className="w-5 h-5 text-trust-navy shrink-0 mt-0.5" />
                                <span>{t('OptionC.feature2')}</span>
                            </li>
                            <li className="flex items-start gap-3">
                                <FileText className="w-5 h-5 text-trust-navy shrink-0 mt-0.5" />
                                <span>{t('OptionC.feature3')}</span>
                            </li>
                        </ul>

                        <div className="mt-auto">
                            <div className="text-4xl font-bold text-primary mb-2">{t('OptionC.price')}</div>
                            <Link href="/assessment?plan=simulator">
                                <Button className="w-full py-6 text-lg" variant="outline">{t('OptionC.cta')}</Button>
                            </Link>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    );
}
