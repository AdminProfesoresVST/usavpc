import { ChatInterface } from "@/components/chat/ChatInterface";
import { DownloadReportButton } from "@/components/pdf/DownloadButton";
import { CheckoutButton } from "@/components/checkout/CheckoutButton";
import { useTranslations } from 'next-intl';

export default function Home() {
  const t = useTranslations('HomePage');

  return (
    <div className="container mx-auto px-4 py-8 md:py-12">
      <div className="text-center mb-8">
        <h1 className="text-3xl md:text-4xl font-serif font-bold text-primary mb-4">
          {t('title')}
        </h1>
        <p className="text-muted-foreground max-w-2xl mx-auto mb-8">
          {t('subtitle')}
        </p>
        <CheckoutButton />
      </div>
      <ChatInterface />
      <div className="mt-8">
        <p className="text-center text-sm text-muted-foreground mb-2">{t('devMode')}</p>
        <DownloadReportButton />
      </div>
    </div>
  );
}
