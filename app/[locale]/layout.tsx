import type { Metadata } from "next";
import { Public_Sans } from "next/font/google";
import "../globals.css";
import { MobileNav } from "@/components/layout/MobileNav";
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
        className={`${publicSans.variable} antialiased font-sans bg-[#F0F2F5] text-foreground flex justify-center h-screen overflow-hidden`}
      >
        <NextIntlClientProvider messages={messages}>
          <AnalyticsProvider>

            {/* Mobile Frame Container */}
            <div className="w-full max-w-[420px] bg-white h-full flex flex-col relative shadow-2xl overflow-hidden">

              {/* Main Content Area */}
              <main className="flex-1 flex flex-col overflow-y-auto no-scrollbar relative bg-[#F0F2F5]">
                {children}
              </main>

              {/* Mobile Nav fixed at bottom of container */}
              <MobileNav />
            </div>

            <DevToolbar />
          </AnalyticsProvider>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
