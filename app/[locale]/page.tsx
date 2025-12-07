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
    <>
      {/* 2. Desktop Block (Visible on Desktop xl+) */}
      <div className="hidden xl:flex flex-col min-h-screen">
        <DesktopBlocker />
      </div>

      {/* 3. Mobile/Tablet App (Hidden on xl+) */}
      <div className="xl:hidden w-full h-[100dvh]">
        <MobileHome />
      </div>
    </>
  );
}
