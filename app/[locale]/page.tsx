import { DownloadReportButton } from "@/components/pdf/DownloadButton";
import { useTranslations } from 'next-intl';
import { ShieldCheck, Clock, FileCheck } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { Button } from "@/components/ui/button";

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
            <span className="uppercase tracking-wider text-xs text-white">Visa Eligibility & Strategy Review</span>
          </div>
          <h1 className="text-3xl md:text-5xl font-serif font-bold mb-6 tracking-tight drop-shadow-md text-white">
            Visa Eligibility & Strategy Review
          </h1>
          <p className="text-lg text-white/90 max-w-3xl mx-auto mb-8 font-light leading-relaxed drop-shadow-sm">
            {t('subtitle')}
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Link href="/assessment">
              <Button size="lg" className="bg-success-green hover:bg-success-green/90 text-white font-bold px-8 py-6 text-lg shadow-lg transform transition hover:scale-105">
                {t('nav.start')}
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Main Content Area - Removed Chatbot, now just Trust Indicators */}

      {/* Trust Indicators */}
      <section className="container mx-auto px-4 py-12 mb-12">
        <div className="grid md:grid-cols-3 gap-8 text-center">
          <div className="bg-white p-6 rounded-lg shadow-sm border border-border">
            <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
              <ShieldCheck className="w-6 h-6 text-primary" />
            </div>
            <h3 className="font-serif font-bold text-lg mb-2">AI-Powered Analysis</h3>
            <p className="text-muted-foreground text-sm">
              Our advanced algorithms compare your profile against thousands of successful cases.
            </p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-sm border border-border">
            <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
              <Clock className="w-6 h-6 text-primary" />
            </div>
            <h3 className="font-serif font-bold text-lg mb-2">Instant Results</h3>
            <p className="text-muted-foreground text-sm">
              Get your VisaScore™ and personalized strategy report in under 5 minutes.
            </p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-sm border border-border">
            <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
              <FileCheck className="w-6 h-6 text-primary" />
            </div>
            <h3 className="font-serif font-bold text-lg mb-2">Document Pre-Check</h3>
            <p className="text-muted-foreground text-sm">
              Identify missing documents and red flags before you submit your DS-160.
            </p>
          </div>
        </div>
      </section>

      <div className="container mx-auto px-4 pb-16 text-center">
        <p className="text-sm text-muted-foreground mb-4">{t('devMode')}</p>
        <DownloadReportButton />
      </div>
    </div>
  );
}
