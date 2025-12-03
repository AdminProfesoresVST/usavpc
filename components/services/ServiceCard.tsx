import { Button } from "@/components/ui/button";
import { Link } from "@/src/i18n/routing";
import { CheckCircle2, AlertTriangle, Brain, ShieldCheck, FileText } from "lucide-react";
import { cn } from "@/lib/utils";

interface ServiceCardProps {
    title: string;
    subtitle: string;
    description: string;
    price: string;
    features: string[];
    ctaLabel?: string;
    ctaLink?: string;
    onCtaClick?: () => void;
    customCta?: React.ReactNode;
    variant?: 'default' | 'featured' | 'simulator';
    isRecommended?: boolean;
    note?: string;
}

export function ServiceCard({
    title,
    subtitle,
    description,
    price,
    features,
    ctaLabel,
    ctaLink,
    onCtaClick,
    customCta,
    variant = 'default',
    isRecommended = false,
    note
}: ServiceCardProps) {
    const isFeatured = variant === 'featured';

    return (
        <div className={cn(
            "rounded-lg flex flex-col relative transition-all duration-300",
            // Sizing: Reduced padding from p-8 to p-6
            "p-6",
            isFeatured
                ? "bg-trust-navy text-white shadow-2xl border-2 border-accent-gold transform md:-translate-y-2 z-10"
                : "bg-white text-trust-navy shadow-md border border-border hover:shadow-lg"
        )}>
            {isRecommended && (
                <div className="absolute top-0 right-0 bg-accent-gold text-trust-navy text-[10px] font-bold px-3 py-1 uppercase tracking-wider shadow-sm rounded-bl-lg">
                    Recommended
                </div>
            )}

            <div className="mb-4">
                <h3 className={cn(
                    "font-serif font-bold mb-1 leading-tight",
                    isFeatured ? "text-xl text-accent-gold" : "text-lg text-trust-navy"
                )}>
                    {title}
                </h3>
                <p className={cn(
                    "text-xs font-bold uppercase tracking-wider mb-3",
                    isFeatured ? "text-white/80" : "text-accent-gold"
                )}>
                    {subtitle}
                </p>
                <p className={cn(
                    "italic text-sm border-l-2 pl-3 leading-relaxed",
                    isFeatured ? "text-white/90 border-accent-gold/50" : "text-muted-foreground border-gray-200"
                )}>
                    "{description}"
                </p>
            </div>

            <ul className="space-y-2 mb-6 text-sm flex-grow">
                {features.map((feature, idx) => (
                    <li key={idx} className="flex items-start gap-2">
                        {isFeatured ? (
                            <CheckCircle2 className="w-4 h-4 text-accent-gold shrink-0 mt-0.5" />
                        ) : (
                            <div className="w-4 h-4 shrink-0 mt-0.5 text-trust-navy">
                                {idx === 0 && <Brain size={16} />}
                                {idx === 1 && <AlertTriangle size={16} />}
                                {idx === 2 && <FileText size={16} />}
                            </div>
                        )}
                        <span className={isFeatured ? "text-white/90" : "text-gray-700"}>
                            {feature}
                        </span>
                    </li>
                ))}
            </ul>

            <div className="mt-auto">
                <div className={cn(
                    "font-bold mb-1",
                    isFeatured ? "text-3xl text-white" : "text-2xl text-primary"
                )}>
                    {price}
                </div>
                {note && (
                    <p className="text-[10px] text-red-500 font-medium mb-4 leading-tight">{note}</p>
                )}

                {customCta ? (
                    customCta
                ) : onCtaClick ? (
                    <Button
                        onClick={onCtaClick}
                        className={cn(
                            "w-full font-bold shadow-md",
                            isFeatured
                                ? "bg-accent-gold hover:bg-accent-gold/90 text-trust-navy border-none"
                                : "bg-white hover:bg-gray-50 text-trust-navy border border-input"
                        )}
                    >
                        {ctaLabel}
                    </Button>
                ) : (
                    <Link href={ctaLink || '#'}>
                        <Button
                            className={cn(
                                "w-full font-bold shadow-md",
                                isFeatured
                                    ? "bg-accent-gold hover:bg-accent-gold/90 text-trust-navy border-none"
                                    : "bg-white hover:bg-gray-50 text-trust-navy border border-input"
                            )}
                        >
                            {ctaLabel}
                        </Button>
                    </Link>
                )}
            </div>
        </div>
    );
}
