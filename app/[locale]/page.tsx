import { useTranslations } from 'next-intl';
import { ShieldCheck, Clock, FileCheck, Zap, BrainCircuit } from "lucide-react";
import Image from "next/image";
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import { ServiceCard } from "@/components/services/ServiceCard";
import { ServiceCheckoutButton } from "@/components/services/ServiceCheckoutButton";
import { MobileHome } from "@/components/mobile/MobileHome";
import { SafeInterviewGuideButton } from "@/components/pdf/SafeInterviewGuideButton";

export default function Home() {
  const t = useTranslations();

  return (
    <>
      {/* Mobile App Experience (Using new Zero Scroll Mobile Component) */}
      <div className="lg:hidden h-screen overflow-hidden">
        <MobileHome />
      </div>

      {/* Desktop Web Experience (Senior Dashboard Standard Layout) */}
      <div className="hidden lg:flex min-h-screen w-full bg-official-grey flex-col">
        {/* Row 1: Hero */}
        <section className="relative w-full flex-none flex items-center justify-center bg-trust-navy text-white border-b-4 border-accent-gold overflow-hidden">
          {/* Background Image */}
          {/* Background Image - Adjusted to not be "giant" */}
          <div className="absolute inset-0 z-0">
            <Image
              src="/bg-hero.png"
              alt="US Visa Center Building"
              fill
              className="object-cover object-[center_30%] opacity-40 mix-blend-overlay"
              priority
            />
            {/* Subtle gradient to ensure text contrast */}
            <div className="absolute inset-0 bg-gradient-to-r from-trust-navy/95 via-trust-navy/80 to-trust-navy/60"></div>
          </div>

          <div className="container mx-auto px-4 relative z-10 flex flex-col items-center justify-center h-full">
            <div className="inline-flex items-center gap-2 bg-white/10 px-4 py-1 rounded-full text-xs uppercase tracking-widest font-bold mb-4 border border-white/20 text-accent-gold invisible lg:visible">
              <ShieldCheck className="w-3.5 h-3.5" />
              <span>Official Visa Assistance</span>
            </div>
            <h1 className="text-4xl lg:text-6xl font-sans font-black mb-3 tracking-tight drop-shadow-2xl text-center leading-tight text-white">
              {t('HomePage.title')}
            </h1>
            <p className="text-lg text-white/90 max-w-3xl text-center font-light leading-relaxed">
              {t('HomePage.subtitle')}
            </p>
          </div>
        </section>

        {/* Row 2: Services Grid (Natural Height) */}
        <section className="w-full bg-gray-50 flex items-center justify-center relative py-12 flex-1">
          {/* Architectural element */}
          <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-b from-gray-100/50 to-transparent pointer-events-none"></div>

          <div className="w-full max-w-7xl grid grid-cols-3 gap-8 px-8 h-[85%] items-center">
            {/* Option A */}
            <ServiceCard
              stepNumber="01"
              title={t('Services.OptionA.title')}
              subtitle={t('Services.OptionA.subtitle')}
              description={t('Services.OptionA.desc')}
              price={t('Services.OptionA.price')}
              features={[t('Services.OptionA.feature1'), t('Services.OptionA.feature2'), t('Services.OptionA.feature3')]}
              customCta={
                <ServiceCheckoutButton label={t('Services.OptionA.cta')} price={t('Services.OptionA.price')} basePriceNumeric={39} plan="diy" variant="outline" className="py-3" />
              }
              note={t('Services.OptionA.note')}
            />

            {/* Option B (Featured) */}
            <ServiceCard
              stepNumber="02"
              variant="featured"
              isRecommended={true}
              title={t('Services.OptionB.title')}
              subtitle={t('Services.OptionB.subtitle')}
              description={t('Services.OptionB.desc')}
              price={t('Services.OptionB.price')}
              features={[t('Services.OptionB.feature1'), t('Services.OptionB.feature2'), t('Services.OptionB.feature3')]}
              customCta={
                <ServiceCheckoutButton label={t('Services.OptionB.cta')} price={t('Services.OptionB.price')} basePriceNumeric={99} plan="full" variant="featured" className="py-5 text-lg" />
              }
            />

            {/* Option C */}
            <ServiceCard
              stepNumber="03"
              variant="simulator"
              title={t('Services.OptionC.title')}
              subtitle={t('Services.OptionC.subtitle')}
              description={t('Services.OptionC.desc')}
              price={t('Services.OptionC.price')}
              features={[t('Services.OptionC.feature1'), t('Services.OptionC.feature2'), t('Services.OptionC.feature3')]}
              customCta={
                <ServiceCheckoutButton label={t('Services.OptionC.cta')} price={t('Services.OptionC.price')} basePriceNumeric={29} plan="simulator" variant="outline" className="py-3" />
              }
            />
          </div>
        </section>

        {/* Row 3: Bottom Bar */}
        <section className="h-12 bg-white border-t border-gray-200 flex-none flex items-center px-8 justify-between text-xs text-gray-500 z-20 shadow-[0_-5px_15px_-5px_rgba(0,0,0,0.05)]">
          <div className="flex gap-8">
            <span className="flex items-center gap-2 font-medium tracking-wide"><ShieldCheck className="w-4 h-4 text-trust-navy" /> 256-bit Encryption</span>
            <span className="flex items-center gap-2 font-medium tracking-wide"><Zap className="w-4 h-4 text-accent-gold" /> 24h Processing</span>
            <span className="flex items-center gap-2 font-medium tracking-wide"><BrainCircuit className="w-4 h-4 text-success-green" /> AI Approved</span>
          </div>
          <div className="flex gap-4 items-center">
            <span className="font-mono font-bold text-accent-gold tracking-wider">v1.5.5</span>
          </div>
        </section>
      </div>
    </>
  );
}
