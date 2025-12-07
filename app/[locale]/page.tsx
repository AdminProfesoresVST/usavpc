import { useTranslations } from 'next-intl';
import { ShieldCheck, Clock, FileCheck } from "lucide-react";
import Image from "next/image";
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import { SafeDownloadButton } from "@/components/pdf/SafeDownloadButton";
import { ServiceCard } from "@/components/services/ServiceCard";
import { ServiceCheckoutButton } from "@/components/services/ServiceCheckoutButton";
import { TrustSection } from "@/components/landing/TrustSection";

import { MobileHome } from "@/components/mobile/MobileHome";
import { SafeInterviewGuideButton } from "@/components/pdf/SafeInterviewGuideButton";

export default function Home() {
  const t = useTranslations();

  return (
    <>
      {/* Mobile App Experience */}
      <div className="md:hidden">
        <MobileHome />
      </div>

      {/* Desktop Web Experience */}
      <div className="hidden md:flex flex-col min-h-screen bg-official-grey">
        {/* Hero Section - Strict Government Style with Background Image */}
        <section className="relative bg-trust-navy text-white py-32 border-b-4 border-accent-gold overflow-hidden">
          {/* Background Image */}
          <div className="absolute inset-0 z-0">
            <Image
              src="/bg-hero.png"
              alt="US Visa Center Building"
              fill
              className="object-cover object-center opacity-40"
              priority
            />
          </div>

          <div className="container mx-auto px-4 text-center relative z-10">
            <div className="inline-flex items-center gap-2 bg-white/10 px-4 py-1 rounded-sm text-sm font-medium mb-6 backdrop-blur-sm border border-white/10">
              <ShieldCheck className="w-4 h-4 text-white" />
              <span className="uppercase tracking-wider text-xs text-white">Professional Visa Assistance</span>
            </div>
            <h1 className="text-5xl font-sans font-bold mb-6 tracking-tight drop-shadow-md text-white">
              {t('HomePage.title')}
            </h1>
            <p className="text-lg text-white/90 max-w-3xl mx-auto mb-8 font-light leading-relaxed drop-shadow-sm">
              {t('HomePage.subtitle')}
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
              <Link href="/services">
                <Button size="lg" className="bg-success-green hover:bg-success-green/90 text-white font-bold px-8 py-6 text-lg shadow-lg transform transition hover:scale-105">
                  {t('HomePage.cta')}
                </Button>
              </Link>
            </div>
          </div>
        </section>

        {/* Trust Indicators */}
        <TrustSection />

        {/* Free Resources Section */}
        <section className="py-12 bg-white border-b border-gray-100">
          <div className="container mx-auto px-4 text-center">
            <h2 className="text-2xl font-bold text-trust-navy mb-4">{t('FreeResources.title')}</h2>
            <p className="text-gray-600 mb-8 max-w-2xl mx-auto">
              {t('FreeResources.desc')}
            </p>
            <div className="flex justify-center">
              <SafeInterviewGuideButton />
            </div>
          </div>
        </section>

        {/* Service Fork (The Bifurcation) */}
        <section className="py-16 bg-official-grey">
          <div className="container mx-auto px-4 max-w-6xl">
            <div className="grid md:grid-cols-3 gap-6 items-stretch">
              {/* Option A - DIY */}
              <ServiceCard
                title={t('Services.OptionA.title')}
                subtitle={t('Services.OptionA.subtitle')}
                description={t('Services.OptionA.desc')}
                price={t('Services.OptionA.price')}
                features={[
                  t('Services.OptionA.feature1'),
                  t('Services.OptionA.feature2'),
                  t('Services.OptionA.feature3')
                ]}
                customCta={
                  <ServiceCheckoutButton
                    label={t('Services.OptionA.cta')}
                    price={t('Services.OptionA.price')}
                    basePriceNumeric={39}
                    plan="diy"
                    variant="outline"
                  />
                }
                note={t('Services.OptionA.note')}
              />

              {/* Option B - Full Service */}
              <ServiceCard
                variant="featured"
                isRecommended={true}
                title={t('Services.OptionB.title')}
                subtitle={t('Services.OptionB.subtitle')}
                description={t('Services.OptionB.desc')}
                price={t('Services.OptionB.price')}
                features={[
                  t('Services.OptionB.feature1'),
                  t('Services.OptionB.feature2'),
                  t('Services.OptionB.feature3')
                ]}
                customCta={
                  <ServiceCheckoutButton
                    label={t('Services.OptionB.cta')}
                    price={t('Services.OptionB.price')}
                    basePriceNumeric={99}
                    plan="full"
                    variant="featured"
                  />
                }
              />

              {/* Option C - Simulator */}
              <ServiceCard
                variant="simulator"
                title={t('Services.OptionC.title')}
                subtitle={t('Services.OptionC.subtitle')}
                description={t('Services.OptionC.desc')}
                price={t('Services.OptionC.price')}
                features={[
                  t('Services.OptionC.feature1'),
                  t('Services.OptionC.feature2'),
                  t('Services.OptionC.feature3')
                ]}
                customCta={
                  <ServiceCheckoutButton
                    label={t('Services.OptionC.cta')}
                    price={t('Services.OptionC.price')}
                    basePriceNumeric={29}
                    plan="simulator"
                    variant="outline"
                  />
                }
              />
            </div>
          </div>
        </section>
      </div>
    </>
  );
}
