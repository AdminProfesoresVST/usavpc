import { useTranslations } from 'next-intl';
import { ShieldCheck, Clock, FileCheck } from "lucide-react";
import Image from "next/image";
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import { SafeDownloadButton } from "@/components/pdf/SafeDownloadButton";
import { ServiceCard } from "@/components/services/ServiceCard";
import { ServiceCheckoutButton } from "@/components/services/ServiceCheckoutButton";
import { TrustSection } from "@/components/landing/TrustSection";

export default function Home() {
  const t = useTranslations();

  return (
    <div className="flex flex-col min-h-screen bg-official-grey">
      {/* Hero Section - Strict Government Style with Background Image */}
      <section className="relative bg-trust-navy text-white py-12 md:py-32 border-b-4 border-accent-gold overflow-hidden">
        {/* Background Image - Hidden on Mobile for cleaner app look */}
        <div className="absolute inset-0 z-0 hidden md:block">
          <Image
            src="/bg-hero.png"
            alt="US Visa Center Building"
            fill
            className="object-cover object-center opacity-40"
            priority
          />
        </div>

        <div className="container mx-auto px-4 text-center relative z-10">
          <div className="inline-flex items-center gap-2 bg-white/10 px-3 py-1 rounded-full text-xs font-medium mb-4 backdrop-blur-sm border border-white/10">
            <ShieldCheck className="w-3 h-3 text-white" />
            <span className="uppercase tracking-wider text-[10px] text-white">Official Visa Assistance</span>
          </div>
          <h1 className="text-2xl md:text-5xl font-serif font-bold mb-4 tracking-tight drop-shadow-md text-white leading-tight">
            {t('HomePage.title')}
          </h1>
          <p className="text-sm md:text-lg text-white/90 max-w-3xl mx-auto mb-6 font-light leading-relaxed drop-shadow-sm px-4">
            {t('HomePage.subtitle')}
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Link href="/services" className="w-full sm:w-auto">
              <Button size="lg" className="w-full sm:w-auto bg-success-green hover:bg-success-green/90 text-white font-bold px-8 py-6 text-lg shadow-lg transform transition hover:scale-105 rounded-xl">
                {t('HomePage.cta')}
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Main Content Area - Removed Chatbot, now just Trust Indicators */}

      {/* Trust Indicators */}
      <TrustSection />

      {/* Service Fork (The Bifurcation) */}
      <section className="py-16 bg-official-grey">
        <div className="container mx-auto px-4 max-w-6xl">
          {/* Mobile: Horizontal Scroll / Desktop: Grid */}
          <div className="flex md:grid md:grid-cols-3 gap-4 md:gap-6 overflow-x-auto md:overflow-visible snap-x snap-mandatory pb-4 md:pb-0 -mx-4 px-4 md:mx-0 md:px-0 scrollbar-hide">
            {/* Option A - DIY */}
            <div className="min-w-[85vw] md:min-w-0 snap-center">
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
            </div>

            {/* Option B - Full Service */}
            <div className="min-w-[85vw] md:min-w-0 snap-center">
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
            </div>

            {/* Option C - Simulator */}
            <div className="min-w-[85vw] md:min-w-0 snap-center">
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
        </div>
      </section>


    </div>
  );
}
