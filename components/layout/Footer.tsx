import { useTranslations } from 'next-intl';

export function Footer() {
    const t = useTranslations('About');
    return (
        <footer className="bg-white border-t border-border py-8 text-sm text-muted-foreground">
            <div className="container mx-auto px-4 md:px-6">
                <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4">
                    <div>
                        <span className="font-sans font-bold text-xl tracking-tight text-white">{t('title')}</span>
                        <p className="mb-4">
                            {t('description')}
                        </p>
                    </div>
                    <div>
                        <h4 className="mb-4 font-bold text-foreground">{t('servicesTitle')}</h4>
                        <ul className="space-y-2">
                            <li>{t('servicesList.eligibility')}</li>
                            <li>{t('servicesList.full')}</li>
                            <li>{t('servicesList.interview')}</li>
                        </ul>
                    </div>
                    <div>
                        <h4 className="mb-4 font-bold text-foreground">{t('legalTitle')}</h4>
                        <ul className="space-y-2">
                            <li>{t('legalList.privacy')}</li>
                            <li>{t('legalList.terms')}</li>
                            <li>{t('legalList.refund')}</li>
                        </ul>
                    </div>
                    <div>
                        <h4 className="mb-4 font-bold text-foreground">{t('contactTitle')}</h4>
                        <ul className="space-y-2">
                            <li>{t('contactEmail')}</li>
                            <li>{t('contactPhone')}</li>
                        </ul>
                    </div>
                </div>
                <div className="mt-8 border-t border-border pt-8 text-center md:text-left">
                    <div className="rounded-sm bg-muted p-4 text-[10px] leading-relaxed text-muted-foreground border border-border">
                        <p className="font-bold mb-1">DISCLAIMER:</p>
                        <p>
                            {t('disclaimerDesc')}
                        </p>
                    </div>
                    <div className="text-sm text-muted-foreground">
                        © {new Date().getFullYear()} US Visa Processing Center. All rights reserved.
                        <span className="ml-2 text-xs text-accent-gold font-mono font-bold">v1.5.1 (Live Update)</span>
                    </div>
                </div>
            </div>
        </footer>
    );
}
