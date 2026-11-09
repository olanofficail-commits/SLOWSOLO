import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'SLOWSOLO',
  description: 'Curated goods imported from China for a mindful lifestyle',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="lo">
      <body className="bg-sand-50 text-gray-900 antialiased min-h-screen">
        {children}
      </body>
    </html>
  );
}
