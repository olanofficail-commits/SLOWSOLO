import React from 'react';

export default function CartPage() {
  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">ตะกร้าสินค้า (Cart)</h1>
      <div className="bg-white border border-sand-200 rounded-xl p-6 shadow-sm text-center text-gray-500">
        ยังไม่มีสินค้าในตะกร้า
      </div>
    </div>
  );
}
