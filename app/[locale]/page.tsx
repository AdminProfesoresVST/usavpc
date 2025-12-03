import { useTranslations } from 'next-intl';
import { ShieldCheck, Clock, FileCheck } from "lucide-react";
import Image from "next/image";
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import { SafeDownloadButton } from "@/components/pdf/SafeDownloadButton";

export default function Home() {
  const t = useTranslations('HomePage');

  return (
    <div className="flex flex-col min-h-screen bg-official-grey">
      {/* Hero Section - Strict Government Style with Background Image */}
      <section className="relative bg-trust-navy text-white py-20 md:py-32 border-b-4 border-accent-gold overflow-hidden">
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
            <span className="uppercase tracking-wider text-xs text-white">Official Visa Assistance</span>
          </div>
          <h1 className="text-3xl md:text-5xl font-serif font-bold mb-6 tracking-tight drop-shadow-md text-white">
            {t('title')}
          </h1>
          <p className="text-lg text-white/90 max-w-3xl mx-auto mb-8 font-light leading-relaxed drop-shadow-sm">
            {t('subtitle')}
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Link href="/services">
              <Button size="lg" className="bg-success-green hover:bg-success-green/90 text-white font-bold px-8 py-6 text-lg shadow-lg transform transition hover:scale-105">
                {t('cta')}
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Main Content Area - Removed Chatbot, now just Trust Indicators */}

      {/* Trust Indicators */}
      {/* Trust Indicators */}
      <section className="container mx-auto px-4 py-12 mb-12">
        <div className="grid md:grid-cols-3 gap-8 text-center">
          <div className="bg-white p-6 rounded-lg shadow-sm border border-border">
            <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
              <ShieldCheck className="w-6 h-6 text-primary" />
            </div>
            <h3 className="font-serif font-bold text-lg mb-2">{t('Trust.encryption')}</h3>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-sm border border-border">
            <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
              <Clock className="w-6 h-6 text-primary" />
            </div>
            <h3 className="font-serif font-bold text-lg mb-2">{t('Trust.speed')}</h3>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-sm border border-border">
            <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
              <FileCheck className="w-6 h-6 text-primary" />
            </div>
            <h3 className="font-serif font-bold text-lg mb-2">{t('Trust.ai')}</h3>
          </div>
        </div>
      </section>

      {/* Service Fork (The Bifurcation) */}
      <section className="py-16 bg-official-grey">
        <div className="container mx-auto px-4 max-w-5xl">
          <div className="grid md:grid-cols-2 gap-8 items-stretch">
            {/* Option A - DIY (De-emphasized) */}
            <div className="bg-gray-50 rounded-lg shadow-sm border border-border p-8 flex flex-col opacity-80 hover:opacity-100 transition-opacity">
              <h3 className="text-xl font-bold text-trust-navy mb-2">{t('Fork.optionA.title')}</h3>
              <p className="text-muted-foreground mb-6 flex-grow italic">
                "{t('Fork.optionA.desc')}"
              </p>
              <div className="text-4xl font-bold text-gray-400 mb-6">{t('Fork.optionA.price')}</div>
              <Link href="/assessment?plan=diy">
                <Button className="w-full" variant="outline">{t('Fork.optionA.cta')}</Button>
              </Link>
            </div>

            {/* Option B - Full Service (Highlighted) */}
            <div className="bg-trust-navy text-white rounded-lg shadow-2xl border-2 border-accent-gold p-8 relative overflow-hidden flex flex-col transform md:-translate-y-4 z-10">
              <div className="absolute top-0 right-0 bg-accent-gold text-trust-navy text-xs font-bold px-3 py-1 uppercase tracking-wider shadow-md">
                Most Popular
              </div>
              <h3 className="text-2xl font-bold mb-2 text-accent-gold">{t('Fork.optionB.title')}</h3>
              <p className="text-white/90 mb-6 flex-grow italic text-lg">
                "{t('Fork.optionB.desc')}"
              </p>
              <div className="text-5xl font-bold text-white mb-6 drop-shadow-md">{t('Fork.optionB.price')}</div>
              <Link href="/assessment?plan=full">
                <Button className="w-full bg-accent-gold hover:bg-accent-gold/90 text-trust-navy font-bold text-lg py-6 shadow-lg border-none">
                  {t('Fork.optionB.cta')}
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>


    </div>
  );
}
