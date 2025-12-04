import { useTranslations } from 'next-intl';

export function Footer() {
    const t = useTranslations('About');
    return (
        <footer className="bg-white border-t border-border py-8 text-sm text-muted-foreground">
            <div className="container mx-auto px-4 md:px-6">
                <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4">
                    <div>
                        <span className="font-sans font-bold text-xl tracking-tight text-white">US Visa Processing Center</span>
                        <p className="mb-4">
                            Professional assistance for your B1/B2 visa application. Secure, accurate, and efficient processing.
                        </p>
                    </div>
                    <div>
                        <h4 className="mb-4 font-bold text-foreground">Services</h4>
                        <ul className="space-y-2">
                            <li>Eligibility Review</li>
                            <li>Full Processing</li>
                            <li>Interview Preparation</li>
                        </ul>
                    </div>
                    <div>
                        <h4 className="mb-4 font-bold text-foreground">Legal</h4>
                        <ul className="space-y-2">
                            <li>Privacy Policy</li>
                            <li>Terms of Service</li>
                            <li>Refund Policy</li>
                        </ul>
                    </div>
                    <div>
                        <h4 className="mb-4 font-bold text-foreground">Contact</h4>
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
                        <span className="ml-2 text-xs text-gray-400 font-mono">v1.5.0 (Triage Live)</span>
                    </div>
                </div>
            </div>
        </footer>
    );
}
