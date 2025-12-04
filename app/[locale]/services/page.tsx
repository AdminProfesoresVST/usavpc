import { useTranslations } from 'next-intl';
import { ShieldCheck, Brain, FileText, CheckCircle2, AlertTriangle } from "lucide-react";
import Image from "next/image";
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import { ServiceCheckoutButton } from "@/components/services/ServiceCheckoutButton";
import { ServiceCard } from "@/components/services/ServiceCard";

import { MobileServices } from "@/components/mobile/MobileServices";

export default function ServicesPage() {
    const t = useTranslations('Services');

    return (
        <>
            {/* Mobile App Experience */}
            <div className="md:hidden">
                <MobileServices />
            </div>

            {/* Desktop Web Experience */}
            <div className="hidden md:flex flex-col min-h-screen bg-official-grey">
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
                        <h1 className="text-3xl md:text-5xl font-serif font-bold mb-6 tracking-tight text-white">{t('title')}</h1>
                        <p className="text-xl font-medium text-white/90 mb-6 leading-relaxed">{t('subtitle')}</p>
                        <p className="text-lg text-white/80 leading-relaxed font-light">{t('description')}</p>
                    </div>
                </section>

                <section className="container mx-auto px-4 py-16">
                    <div className="grid md:grid-cols-3 gap-6 items-stretch max-w-6xl mx-auto">
                        {/* Option A - DIY */}
                        <ServiceCard
                            title={t('OptionA.title')}
                            subtitle={t('OptionA.subtitle')}
                            description={t('OptionA.desc')}
                            price={t('OptionA.price')}
                            features={[
                                t('OptionA.feature1'),
                                t('OptionA.feature2'),
                                t('OptionA.feature3')
                            ]}
                            customCta={
                                <ServiceCheckoutButton
                                    label={t('OptionA.cta')}
                                    price={t('OptionA.price')}
                                    basePriceNumeric={39}
                                    plan="diy"
                                    variant="outline"
                                />
                            }
                            note={t('OptionA.note')}
                        />

                        {/* Option B - Full Service */}
                        <ServiceCard
                            variant="featured"
                            isRecommended={true}
                            title={t('OptionB.title')}
                            subtitle={t('OptionB.subtitle')}
                            description={t('OptionB.desc')}
                            price={t('OptionB.price')}
                            features={[
                                t('OptionB.feature1'),
                                t('OptionB.feature2'),
                                t('OptionB.feature3')
                            ]}
                            customCta={
                                <ServiceCheckoutButton
                                    label={t('OptionB.cta')}
                                    price={t('OptionB.price')}
                                    basePriceNumeric={99}
                                    plan="full"
                                    variant="featured"
                                />
                            }
                        />

                        {/* Option C - Simulator */}
                        <ServiceCard
                            variant="simulator"
                            title={t('OptionC.title')}
                            subtitle={t('OptionC.subtitle')}
                            description={t('OptionC.desc')}
                            price={t('OptionC.price')}
                            features={[
                                t('OptionC.feature1'),
                                t('OptionC.feature2'),
                                t('OptionC.feature3')
                            ]}
                            customCta={
                                <ServiceCheckoutButton
                                    label={t('OptionC.cta')}
                                    price={t('OptionC.price')}
                                    basePriceNumeric={29}
                                    plan="simulator"
                                    variant="outline"
                                />
                            }
                        />
                    </div>
                </section>
            </div>
        </>
    );
}
