import type { Metadata } from "next";
import { Public_Sans } from "next/font/google";
import "../globals.css";
import { Header } from "@/components/layout/Header";
import { MobileNav } from "@/components/layout/MobileNav";
import { MobileOnlyGuard } from "@/components/layout/MobileOnlyGuard";
import { DevToolbar } from "@/components/dev/DevToolbar";
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
        className={`${publicSans.variable} antialiased font-sans bg-background text-foreground flex flex-col h-screen overflow-hidden`}
      >
        <NextIntlClientProvider messages={messages}>
          <AnalyticsProvider>
            {/* Header stays top */}
            <Header />

            {/* 
              [SCROLL ARCHITECTURE] 
              Date: 2025-12-15
              Context: Decoupling document scroll from body. 
              Enforcement: overflow-y-auto on main, while body is fixed.
              Netlify Impact: Enables internal scrolling within fixed viewport.
            */}
            <main className="flex-1 flex flex-col overflow-y-auto no-scrollbar relative w-full h-full">
              {children}
            </main>

            {/* Mobile Nav fixed at bottom (Hidden on XL) */}
            <div className="xl:hidden">
              <MobileNav />
            </div>

            <MobileOnlyGuard />
            <DevToolbar />
          </AnalyticsProvider>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
