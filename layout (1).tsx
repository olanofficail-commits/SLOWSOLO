import React from 'react';
import Link from 'next/link';

export default function StoreLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: { locale: string };
}) {
  const locale = params.locale || 'lo';
  return (
    <div className="flex flex-col min-h-screen">
      <header className="border-b border-sand-200 bg-white/80 backdrop-blur sticky top-0 z-50">
        <div className="max-w-5xl mx-auto px-4 h-16 flex items-center justify-between">
          <Link href={`/${locale}`} className="text-xl font-bold tracking-tight text-brand-900">
            SLOWSOLO
          </Link>
          <nav className="flex items-center gap-6 text-sm font-medium text-gray-600">
            <Link href={`/${locale}`} className="hover:text-brand-700">หน้าแรก</Link>
            <Link href={`/${locale}/cart`} className="hover:text-brand-700">ตะกร้า</Link>
            <Link href={`/${locale}/track/SD-EXAMPLE`} className="hover:text-brand-700">ติดตามสถานะ</Link>
            <div className="flex gap-2 text-xs border-l pl-4 border-sand-300">
              <Link href="/lo" className={locale === 'lo' ? 'font-bold text-brand-700' : 'text-gray-400'}>ລາວ</Link>
              <span>/</span>
              <Link href="/th" className={locale === 'th' ? 'font-bold text-brand-700' : 'text-gray-400'}>ไทย</Link>
              <span>/</span>
              <Link href="/en" className={locale === 'en' ? 'font-bold text-brand-700' : 'text-gray-400'}>EN</Link>
            </div>
          </nav>
        </div>
      </header>
      <main className="flex-1 max-w-5xl mx-auto px-4 py-8 w-full">
        {children}
      </main>
      <footer className="border-t border-sand-200 py-8 bg-sand-100 text-center text-sm text-gray-500">
        <p>© 2026 SLOWSOLO. สินค้านำเข้าจากจีน คัดสรรพิเศษ เพื่อชีวิตที่เรียบง่าย</p>
      </footer>
    </div>
  );
}
