import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({ variable: "--font-geist-sans", subsets: ["latin"] });
const geistMono = Geist_Mono({ variable: "--font-geist-mono", subsets: ["latin"] });

export const metadata: Metadata = {
  metadataBase: new URL("https://bross.naturalcarr.com"),
  title: "Natural Carr | Home IT & Smart Home Support",
  description: "Straightforward freelance IT help for Home Assistant, home networks, remote support, and onsite assistance.",
  openGraph: { title: "Home tech, handled. | Natural Carr", description: "Practical help for smart homes, home networks, and the tech that keeps your household running.", type: "website", images: [{ url: "/og.png", width: 1729, height: 910, alt: "Home tech, handled. Practical IT support for smart homes and home networks." }] },
  twitter: { card: "summary_large_image", title: "Home tech, handled. | Natural Carr", description: "Practical freelance IT support without the jargon.", images: ["/og.png"] },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body className={`${geistSans.variable} ${geistMono.variable} antialiased`}>{children}</body></html>;
}



