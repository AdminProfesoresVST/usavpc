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
      <div className="md:hidden h-screen overflow-hidden">
        <MobileHome />
      </div>

      {/* Desktop Web Experience (Zero Scroll Dashboard Layout) */}
      <div className="hidden md:flex flex-col h-full w-full overflow-hidden bg-official-grey">
        {/* Top Section: Hero (Flexible 35%) */}
        <section className="relative h-[35%] flex-none flex items-center justify-center bg-trust-navy text-white border-b-4 border-accent-gold overflow-hidden">
          {/* Background Image */}
          <div className="absolute inset-0 z-0">
            <Image
              src="/bg-hero.png"
              alt="US Visa Center Building"
              fill
              className="object-cover object-center opacity-30"
              priority
            />
          </div>

          <div className="container mx-auto px-4 relative z-10 flex flex-col items-center justify-center h-full">
            <div className="inline-flex items-center gap-2 bg-white/10 px-3 py-0.5 rounded-full text-[10px] uppercase tracking-widest font-bold mb-2 border border-white/20 text-accent-gold">
              <ShieldCheck className="w-3 h-3" />
              <span>Official Visa Assistance</span>
            </div>
            <h1 className="text-3xl lg:text-5xl font-sans font-extrabold mb-2 tracking-tight drop-shadow-lg text-center leading-tight">
              {t('HomePage.title')}
            </h1>
            <p className="text-base text-white/80 max-w-2xl text-center font-light leading-snug">
              {t('HomePage.subtitle')}
            </p>
          </div>
        </section>

        {/* Middle Section: Services Grid (Take Remaining Space) */}
        <section className="flex-1 bg-gray-50 p-4 flex items-center justify-center overflow-hidden min-h-0">
          <div className="w-full max-w-7xl grid grid-cols-3 gap-4 h-full items-center">
            {/* Option A */}
            <ServiceCard
              stepNumber="01"
              title={t('Services.OptionA.title')}
              subtitle={t('Services.OptionA.subtitle')}
              description={t('Services.OptionA.desc')}
              price={t('Services.OptionA.price')}
              features={[t('Services.OptionA.feature1'), t('Services.OptionA.feature2'), t('Services.OptionA.feature3')]}
              customCta={
                <ServiceCheckoutButton label={t('Services.OptionA.cta')} price={t('Services.OptionA.price')} basePriceNumeric={39} plan="diy" variant="outline" className="py-3 text-sm" />
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
                <ServiceCheckoutButton label={t('Services.OptionB.cta')} price={t('Services.OptionB.price')} basePriceNumeric={99} plan="full" variant="featured" className="py-4 text-base" />
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
                <ServiceCheckoutButton label={t('Services.OptionC.cta')} price={t('Services.OptionC.price')} basePriceNumeric={29} plan="simulator" variant="outline" className="py-3 text-sm" />
              }
            />
          </div>
        </section>

        {/* Bottom Bar: Status / Trust (Fixed Height) */}
        <section className="h-10 bg-white border-t border-gray-200 flex-none flex items-center px-6 justify-between text-[10px] text-gray-500">
          <div className="flex gap-6">
            <span className="flex items-center gap-1.5"><ShieldCheck className="w-3 h-3 text-trust-navy" /> 256-bit Encryption</span>
            <span className="flex items-center gap-1.5"><Zap className="w-3 h-3 text-accent-gold" /> 24h Processing</span>
            <span className="flex items-center gap-1.5"><BrainCircuit className="w-3 h-3 text-success-green" /> AI Approved</span>
          </div>
          <div className="flex gap-4 items-center">
            <span className="font-bold text-accent-gold">v1.5.3 (Redesign)</span>
          </div>
        </section>
      </div>
    </>
  );
}
