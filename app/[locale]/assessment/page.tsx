import { ChatInterface } from "@/components/chat/ChatInterface";
import { useTranslations } from 'next-intl';

export default function AssessmentPage() {
    const t = useTranslations('Chat');

    return (
        <div className="container mx-auto px-4 py-8 min-h-screen">
            <div className="max-w-4xl mx-auto">
                <h1 className="text-2xl font-serif font-bold mb-6 text-trust-navy">{t('title')}</h1>
                <ChatInterface />
            </div>
        </div>
    );
}
