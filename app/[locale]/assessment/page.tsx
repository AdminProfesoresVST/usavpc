import { ChatInterface } from "@/components/chat/ChatInterface";
import { useTranslations } from 'next-intl';
import Image from "next/image";

export default function AssessmentPage() {
    const t = useTranslations('Chat');

    return (
        <div className="relative min-h-screen flex flex-col bg-official-grey">
            <div className="absolute inset-0 z-0 h-64 bg-trust-navy overflow-hidden">
                <Image
                    src="/bg-hero.png"
                    alt="Background"
                    fill
                    className="object-cover object-center opacity-20"
                    priority
                />
            </div>
            <div className="container mx-auto px-4 py-8 relative z-10">
                <div className="max-w-4xl mx-auto">
                    <h1 className="text-2xl font-serif font-bold mb-6 text-white">{t('title')}</h1>
                    <ChatInterface />
                </div>
            </div>
        </div>
    );
}
