import type { Metadata } from "next";
import { Public_Sans } from "next/font/google";
import "../globals.css";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { MobileNav } from "@/components/layout/MobileNav";
import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';
import { AnalyticsProvider } from "@/components/analytics/AnalyticsProvider";

const publicSans = Public_Sans({
  variable: "--font-sans",
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "US Visa Processing Center",
  description: "Secure US Visa Processing Application",
  viewport: "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "USVPC",
  },
};

export default async function RootLayout({
  children,
  params
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const messages = await getMessages();

  return (
    <html lang={locale}>
      <body
        className={`${publicSans.variable} antialiased font-sans bg-background text-foreground flex flex-col h-[100dvh] overflow-hidden`}
      >
        <NextIntlClientProvider messages={messages}>
          <AnalyticsProvider>
            {/* Header stays top */}
            <Header />

            {/* Main takes remaining space, absolutely no scroll allowed on container */}
            <main className="flex-1 relative overflow-hidden flex flex-col">
              {children}
            </main>

            {/* Mobile Nav fixed at bottom */}
            <MobileNav />
          </AnalyticsProvider>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
