import React from 'react';
import Link from 'next/link';

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-gray-50">
      <aside className="w-64 bg-gray-900 text-gray-300 flex flex-col p-4 space-y-6">
        <div className="text-xl font-bold text-white tracking-wide">
          SLOWSOLO Admin
        </div>
        <nav className="flex-1 space-y-1 text-sm">
          <Link href="/admin/dashboard" className="block px-3 py-2 rounded bg-gray-800 text-white">ภาพรวม (Dashboard)</Link>
          <Link href="/admin/orders" className="block px-3 py-2 rounded hover:bg-gray-800">ออเดอร์ (Orders)</Link>
          <Link href="/admin/products" className="block px-3 py-2 rounded hover:bg-gray-800">สินค้า (Products)</Link>
          <Link href="/admin/finance" className="block px-3 py-2 rounded hover:bg-gray-800">การเงิน (Finance)</Link>
          <Link href="/admin/approvals" className="block px-3 py-2 rounded hover:bg-gray-800">คิวอนุมัติ (Approvals)</Link>
          <Link href="/admin/settings" className="block px-3 py-2 rounded hover:bg-gray-800">ตั้งค่า (Settings)</Link>
        </nav>
        <div className="text-xs text-gray-500 border-t border-gray-800 pt-4">
          Logged in as Owner
        </div>
      </aside>
      <main className="flex-1 p-8">
        {children}
      </main>
    </div>
  );
}
