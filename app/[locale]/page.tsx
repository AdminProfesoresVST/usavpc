import { useTranslations } from 'next-intl';
import { ShieldCheck, Clock, FileCheck, Zap, BrainCircuit } from "lucide-react";
import Image from "next/image";
import { Link } from "@/src/i18n/routing";
import { Button } from "@/components/ui/button";
import { ServiceCard } from "@/components/services/ServiceCard";
import { ServiceCheckoutButton } from "@/components/services/ServiceCheckoutButton";
import { MobileHome } from "@/components/mobile/MobileHome";
import { SafeInterviewGuideButton } from "@/components/pdf/SafeInterviewGuideButton";
import { DesktopBlocker } from "@/components/layout/DesktopBlocker";

export default function Home() {
  const t = useTranslations();

  return (
    <div className="w-full h-full">
      <MobileHome />
    </div>
  );
}
